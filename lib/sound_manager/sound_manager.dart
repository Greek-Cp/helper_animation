import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'sound_controller.dart';
import 'sound_enums.dart';
import 'sound_paths.dart';
// sound_manager.dart
import 'dart:async';
import 'dart:math';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'sound_controller.dart';
import 'sound_enums.dart';
import 'sound_paths.dart';

/// --------------------------- internal struct ---------------------------
class _WidgetSoundData {
  final SoundController controller;
  final bool external;
  final SoundCategory? category;
  final dynamic sound;
  _WidgetSoundData({
    required this.controller,
    this.external = false,
    this.category,
    this.sound,
  });
}

/// ------------------------------ manager -------------------------------
class SoundManager {
  SoundManager._internal();
  static final SoundManager instance = SoundManager._internal();

  /* ─────── NEW FIELDS ─────── */
  String? _currentTrackPath; // path BGM yg sedang diputar
  String? _bgmRouteBackupPath; // path BGM halaman yg diback-up
  AudioPlayer? _bgmRouteBackup; // player halaman (opsional, bisa null)
  double _bgmRouteBackupVol = 1;

  /* ───────── stores ───────── */
  final _widgets = <Key, _WidgetSoundData>{};
  final _bgmOriginal = <SoundController, double>{};
  final _bgmPerRoute = <String, SoundController>{};
  String _currentRoute = '';
// 3️⃣  di overlay helper
  Future<void> pushOverlayBGM(String path, {double volume = .8}) async {
    if (_bgmRouteBackup == null && _bgm != null) {
      _bgmRouteBackup = _bgm;
      _bgmRouteBackupVol = _bgmVol;
      _bgmRouteBackupPath = _currentTrackPath; // ← simpan path lama
    }
    await _playBgm(path, volume: volume);
  }

  Future<void> popOverlayBGM() async {
    if (_bgmRouteBackupPath == null) return; // tak ada overlay
    await _playBgm(_bgmRouteBackupPath!, // ← gunakan path lama
        volume: _bgmRouteBackupVol);
    _bgmRouteBackup = null;
    _bgmRouteBackupPath = null;
  }

  /* ───────── global flags ───────── */
  bool _muted = false;
  double _masterVol = 1.0;

  /* ───────── ducking config ───────── */
  static const _duckVolFactor = .5;
  static const _duckDelay = Duration(milliseconds: 500);
  static const _fadeStep = Duration(milliseconds: 16);
  static const _fadeDur = Duration(milliseconds: 300);
  Timer? _duckTimer;
  Timer? _fadeTimer;
  bool _isDucking = false;

  /* ───────── bgm players ───────── */
  AudioPlayer? _bgm;
  AudioPlayer? _bgmNext;
  double _bgmVol = 1.0;
  static const _crossDur = Duration(seconds: 1);
  bool _crossing = false;

  /* =====================  PUBLIC API  ===================== */

  Future<void> setMuted(bool v) async {
    _muted = v;
    _applyMasterVolume();
  }

  Future<void> setMasterVolume(double v) async {
    _masterVol = v.clamp(0, 1);
    _applyMasterVolume();
  }

  /// dipanggil SoundRouteObserver
  Future<void> setCurrentRoute(String name) async {
    if (name == _currentRoute) return;
    _currentRoute = name;
    final c = _bgmPerRoute[name] ?? _bgmPerRoute['global'];
    if (c?.currentPath != null) {
      await _playBgm(c!.currentPath!, volume: c.volume);
    }
  }

  /// widget menelepon untuk mendaftarkan BGM-nya
  void registerBgmForRoute(String routeName, SoundController controller) async {
    if (!_bgmPerRoute.containsKey(routeName)) {
      _bgmOriginal[controller] = controller.volume;
    }
    _bgmPerRoute[routeName] = controller;
  }

  void registerWidgetSound(Key key, _WidgetSoundData data) {
    _widgets[key] = data;

    if (data.category != SoundCategory.bgm) {
      data.controller.soundState.listen((e) {
        if (e == 'playing') _startDuck();
        if (e == 'completed') _tryRestore();
      });
    }
  }

  Future<void> unregisterWidgetSound(Key key) async {
    final data = _widgets.remove(key);
    if (data == null) return;
    if (!data.external) await data.controller.dispose();
  }

  /* =====================  DUCKING  ===================== */

  void _startDuck() async {
    _isDucking = true;
    _duckTimer?.cancel();
    _duckTimer = Timer(_duckDelay, _tryRestore);
    await _fadeBgm(_bgmVol * _duckVolFactor);
  }

  void _tryRestore() async {
    if (_widgets.values
        .any((d) => d.category != SoundCategory.bgm && d.controller.isPlaying))
      return;
    _isDucking = false;
    await _fadeBgm(_masterVol);
  }

  /* =====================  FADE HELPERS  ===================== */

  Future<void> _fadeBgm(double target) async {
    if (_bgm == null) return;
    _fadeTimer?.cancel();
    final start = _bgmVol;
    final steps = (_fadeDur.inMilliseconds / _fadeStep.inMilliseconds).round();
    var i = 0;

    _fadeTimer = Timer.periodic(_fadeStep, (_) async {
      i++;
      final t = -0.5 * (cos(pi * i / steps) - 1);
      _bgmVol = start + (target - start) * t;
      await _bgm!.setVolume(_bgmVol * (_muted ? 0 : 1));
      if (i >= steps) _fadeTimer?.cancel();
    });
  }

  void _applyMasterVolume() {
    final v = _masterVol * (_muted ? 0 : 1);
    _bgm?.setVolume(v);
    for (final d in _widgets.values) {
      if (d.category != SoundCategory.bgm) {
        d.controller.setVolume(d.controller.volume * v);
      }
    }
  }

  /* =====================  PLAY / CROSSFADE  ===================== */

  Future<void> _playBgm(String path, {double volume = 1}) async {
    _currentTrackPath = path; // ← baris tambahan
    volume *= _isDucking ? _duckVolFactor : 1;

    /* ── 1.  ABORT CROSSFADE JIKA MASIH BERJALAN ── */
    if (_crossing) {
      _fadeTimer?.cancel();

      // hentikan calon BGM yang belum sempat jadi aktif
      if (_bgmNext != null) {
        await _bgmNext!.stop();
        await _bgmNext!.dispose();
        _bgmNext = null;
      }

      // kembalikan volume player lama ke posisi terakhir agar tidak turun sendiri
      await _bgm?.setVolume(_bgmVol);
      _crossing = false;
    }

    /* ── 2.  JIKA BELUM ADA BGM, MAINKAN LANGSUNG ── */
    if (_bgm == null) {
      _bgm = await FlameAudio.loop(path, volume: volume);
      _bgmVol = volume;
      return;
    }

    /* ── 3.  LAKUKAN CROSSFADE NORMAL ── */
    _bgmNext = await FlameAudio.loop(path, volume: 0);
    final steps = (_crossDur.inMilliseconds / _fadeStep.inMilliseconds).round();
    var i = 0;
    _crossing = true;

    _fadeTimer?.cancel();
    _fadeTimer = Timer.periodic(_fadeStep, (_) async {
      i++;
      final t = -0.5 * (cos(pi * i / steps) - 1);
      await _bgm!.setVolume(_bgmVol * (1 - t));
      await _bgmNext!.setVolume(volume * t);

      if (i >= steps) {
        await _bgm!.stop();
        await _bgm!.dispose();
        _bgm = _bgmNext;
        _bgmVol = volume;
        _bgmNext = null;
        _fadeTimer?.cancel();
        _crossing = false;
      }
    });
  }
}

/* =====================  EXTENSIONS  ===================== */

extension SoundExtension on Widget {
  /// tambahkan efek suara saat tap
  Widget addSound({
    dynamic sound = ClickSound.gameClick,
    SoundCategory category = SoundCategory.clickEvent,
    double volume = 1,
    Key? key,
  }) {
    return _SoundWrapper(
      child: this,
      sound: sound,
      category: category,
      volume: volume,
      widgetKey: key ?? UniqueKey(),
      isBgm: false,
      global: false,
    );
  }

  /// tambahkan BGM yang nempel pada halaman ini
  Widget addBGM({
    BGMSound sound = BGMSound.birdsSinging,
    double volume = .5,
    bool global = false,
    bool overlay = false, // ⬅️ baru!
    Key? key,
  }) {
    return _SoundWrapper(
      child: this,
      sound: sound,
      category: SoundCategory.bgm,
      volume: volume,
      widgetKey: key ?? UniqueKey(),
      isBgm: true,
      global: global,
      overlay: overlay, // ⬅️ oper ke wrapper
    );
  }
}

/* =====================  INTERNAL WRAPPER  ===================== */
class _SoundWrapper extends StatefulWidget {
  final Widget child;
  final dynamic sound;
  final SoundCategory category;
  final double volume;
  final Key widgetKey;
  final bool isBgm;
  final bool global;
  final bool overlay; // ★ NEW

  const _SoundWrapper({
    required this.child,
    required this.sound,
    required this.category,
    required this.volume,
    required this.widgetKey,
    required this.isBgm,
    required this.global,
    this.overlay = false, // ★ NEW
  });

  @override
  State<_SoundWrapper> createState() => _SoundWrapperState();
}

class _SoundWrapperState extends State<_SoundWrapper> {
  late final SoundController _ctrl;
  late final String _routeName;

  @override
  void initState() {
    super.initState();
    _ctrl = SoundController(volume: widget.volume, autoPlay: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _afterBuild());
  }

  void _afterBuild() {
    _routeName =
        ModalRoute.of(context)?.settings.name ?? 'route_${hashCode.toString()}';

    // — register semua widget (agar ducking tetap jalan) —
    SoundManager.instance.registerWidgetSound(
      widget.widgetKey,
      _WidgetSoundData(
        controller: _ctrl,
        category: widget.category,
        sound: widget.sound,
      ),
    );

    if (!widget.isBgm) return;

    /* ──────────────── BGM handling ──────────────── */
    if (widget.overlay) {
      _startOverlayBgm(); // ★ NEW
      return;
    }

    // BGM biasa (route-based atau global)
    SoundManager.instance
        .registerBgmForRoute(widget.global ? 'global' : _routeName, _ctrl);

    if (widget.global || _routeName == SoundManager.instance._currentRoute) {
      _startBgm();
    }
  }

  /* ---------- normal BGM (route) ---------- */
  Future<void> _startBgm() async {
    await _ctrl.playSound(
      category: widget.category,
      sound: widget.sound,
      autoPlay: false,
    );
    final path = _ctrl.currentPath;
    if (path != null) {
      await SoundManager.instance._playBgm(path, volume: widget.volume);
    }
  }

  /* ---------- overlay BGM (dialog dsb.) ---------- */
  Future<void> _startOverlayBgm() async {
    // ★ NEW
    await _ctrl.playSound(
      category: widget.category,
      sound: widget.sound,
      autoPlay: false,
    );
    final path = _ctrl.currentPath;
    if (path != null) {
      await SoundManager.instance.pushOverlayBGM(path, volume: widget.volume);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isBgm) return widget.child; // gesture tak perlu utk BGM
    return GestureDetector(
      onTap: () => _ctrl.playSound(
        category: widget.category,
        sound: widget.sound,
        autoPlay: true,
      ),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    // jika ini overlay, balikan BGM route
    if (widget.isBgm && widget.overlay) {
      // ★ NEW
      SoundManager.instance.popOverlayBGM();
    }

    SoundManager.instance.unregisterWidgetSound(widget.widgetKey);
    _ctrl.dispose();
    super.dispose();
  }
}

/* =====================  ROUTE OBSERVER  ===================== */

class SoundRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? p) =>
      _set(route); // push → halaman baru aktif
  @override
  void didPop(Route route, Route? p) =>
      _set(p); // pop → kembali ke halaman sebelumnya
  @override
  void didReplace({Route? newRoute, Route? oldRoute}) => _set(newRoute);

  void _set(Route? r) {
    final n = r?.settings.name;
    if (n != null) SoundManager.instance.setCurrentRoute(n);
  }
}
