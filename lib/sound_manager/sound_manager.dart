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

const String _LOG_TAG = "🎵 SOUND_LIBRARY";

void _log(String message) {
  debugPrint('$_LOG_TAG: $message');
}

void _logError(String message, dynamic error, [StackTrace? stackTrace]) {
  debugPrint('$_LOG_TAG ❌ ERROR: $message');
  debugPrint('$_LOG_TAG ❌ Details: $error');
  if (stackTrace != null) {
    debugPrint('$_LOG_TAG ❌ Stack trace:');
    debugPrint(stackTrace
        .toString()
        .split('\n')
        .map((line) => '$_LOG_TAG ❌ $line')
        .join('\n'));
  }
}

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
  SoundManager._internal() {
    try {
      _log('SoundManager initializing...');
      // Add any initialization logic here
      _log('SoundManager initialized successfully');
    } catch (e, stackTrace) {
      _logError('Failed to initialize SoundManager', e, stackTrace);
    }
  }
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
    _log('Pushing overlay BGM: $path (volume: $volume)');
    if (_bgmRouteBackup == null && _bgm != null) {
      _log('Backing up current BGM: $_currentTrackPath');
      _bgmRouteBackup = _bgm;
      _bgmRouteBackupVol = _bgmVol;
      _bgmRouteBackupPath = _currentTrackPath;
    }
    await _playBgm(path, volume: volume);
  }

  Future<void> popOverlayBGM() async {
    if (_bgmRouteBackupPath == null) {
      _log('No overlay BGM to pop');
      return;
    }
    _log('Popping overlay BGM, restoring: $_bgmRouteBackupPath');
    await _playBgm(_bgmRouteBackupPath!, volume: _bgmRouteBackupVol);
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
    _log('Setting muted: $v');
    _muted = v;
    _applyMasterVolume();
  }

  Future<void> setMasterVolume(double v) async {
    _log('Setting master volume: $v');
    _masterVol = v.clamp(0, 1);
    _applyMasterVolume();
  }

  /// dipanggil SoundRouteObserver
  Future<void> setCurrentRoute(String name) async {
    try {
      if (name == _currentRoute) return;
      _log('Route changed: $name');
      _currentRoute = name;
      final c = _bgmPerRoute[name] ?? _bgmPerRoute['global'];
      if (c?.currentPath != null) {
        _log('Playing route BGM: ${c!.currentPath}');
        await _playBgm(c.currentPath!, volume: c.volume);
      }
    } catch (e, stackTrace) {
      _logError('Error changing route', e, stackTrace);
    }
  }

  /// widget menelepon untuk mendaftarkan BGM-nya
  void registerBgmForRoute(String routeName, SoundController controller) {
    try {
      _log('Registering BGM for route: $routeName');
      if (!_bgmPerRoute.containsKey(routeName)) {
        _bgmOriginal[controller] = controller.volume;
      }
      _bgmPerRoute[routeName] = controller;
    } catch (e, stackTrace) {
      _logError('Error registering BGM for route', e, stackTrace);
    }
  }

  void registerWidgetSound(Key key, _WidgetSoundData data) {
    _log('Registering widget sound: ${data.category} - ${data.sound}');
    _widgets[key] = data;

    if (data.category != SoundCategory.bgm) {
      data.controller.soundState.listen((e) {
        _log('Widget sound state changed: $e');
        if (e == 'playing') _startDuck();
        if (e == 'completed') _tryRestore();
      });
    }
  }

  Future<void> unregisterWidgetSound(Key key) async {
    _log('Unregistering widget sound: $key');
    final data = _widgets.remove(key);
    if (data == null) return;
    if (!data.external) await data.controller.dispose();
  }

  /* =====================  DUCKING  ===================== */

  void _startDuck() async {
    _log('Starting audio ducking');
    _isDucking = true;
    _duckTimer?.cancel();
    _duckTimer = Timer(_duckDelay, _tryRestore);
    await _fadeBgm(_bgmVol * _duckVolFactor);
  }

  void _tryRestore() async {
    if (_widgets.values.any(
        (d) => d.category != SoundCategory.bgm && d.controller.isPlaying)) {
      _log('Cannot restore volume - other sounds still playing');
      return;
    }
    _log('Restoring volume after ducking');
    _isDucking = false;
    await _fadeBgm(_masterVol);
  }

  /* =====================  FADE HELPERS  ===================== */

  Future<void> _fadeBgm(double target) async {
    if (_bgm == null) return;
    _log('Fading BGM to volume: $target');
    _fadeTimer?.cancel();
    final start = _bgmVol;
    final steps = (_fadeDur.inMilliseconds / _fadeStep.inMilliseconds).round();
    var i = 0;

    _fadeTimer = Timer.periodic(_fadeStep, (_) async {
      i++;
      final t = -0.5 * (cos(pi * i / steps) - 1);
      _bgmVol = start + (target - start) * t;
      await _bgm!.setVolume(_bgmVol * (_muted ? 0 : 1));
      if (i >= steps) {
        _fadeTimer?.cancel();
        _log('Fade complete. Final volume: $_bgmVol');
      }
    });
  }

  void _applyMasterVolume() {
    final v = _masterVol * (_muted ? 0 : 1);
    _log('Applying master volume: $v (muted: $_muted)');
    _bgm?.setVolume(v);
    for (final d in _widgets.values) {
      if (d.category != SoundCategory.bgm) {
        d.controller.setVolume(d.controller.volume * v);
      }
    }
  }

  /* =====================  PLAY / CROSSFADE  ===================== */

  Future<void> _playBgm(String path, {double volume = 1}) async {
    try {
      _log('Playing BGM: $path (volume: $volume)');
      _currentTrackPath = path;
      volume *= _isDucking ? _duckVolFactor : 1;

      if (_crossing) {
        _log('Aborting previous crossfade');
        await _handleCrossfadeAbort();
      }

      if (_bgm == null) {
        await _handleDirectPlay(path, volume);
        return;
      }

      await _handleCrossfade(path, volume);
    } catch (e, stackTrace) {
      _logError('Error playing BGM', e, stackTrace);
      // Try to recover by stopping any playing audio
      await _cleanupOnError();
    }
  }

  Future<void> _handleCrossfadeAbort() async {
    try {
      _fadeTimer?.cancel();
      if (_bgmNext != null) {
        await _bgmNext!.stop();
        await _bgmNext!.dispose();
        _bgmNext = null;
      }
      await _bgm?.setVolume(_bgmVol);
      _crossing = false;
    } catch (e, stackTrace) {
      _logError('Error aborting crossfade', e, stackTrace);
    }
  }

  Future<void> _handleDirectPlay(String path, double volume) async {
    try {
      _log('No active BGM - playing directly');
      _bgm = await FlameAudio.loop(path, volume: volume);
      _bgmVol = volume;
    } catch (e, stackTrace) {
      _logError('Error in direct BGM playback', e, stackTrace);
      throw e; // Rethrow to be handled by caller
    }
  }

  Future<void> _handleCrossfade(String path, double volume) async {
    try {
      _log('Starting crossfade to new BGM');
      _bgmNext = await FlameAudio.loop(path, volume: 0);
      final steps =
          (_crossDur.inMilliseconds / _fadeStep.inMilliseconds).round();
      var i = 0;
      _crossing = true;

      _fadeTimer?.cancel();
      _fadeTimer = Timer.periodic(_fadeStep, (_) async {
        try {
          i++;
          final t = -0.5 * (cos(pi * i / steps) - 1);
          await _bgm!.setVolume(_bgmVol * (1 - t));
          await _bgmNext!.setVolume(volume * t);

          if (i >= steps) {
            await _finalizeCrossfade(volume);
          }
        } catch (e, stackTrace) {
          _logError('Error during crossfade step', e, stackTrace);
          _fadeTimer?.cancel();
          await _cleanupOnError();
        }
      });
    } catch (e, stackTrace) {
      _logError('Error starting crossfade', e, stackTrace);
      throw e;
    }
  }

  Future<void> _finalizeCrossfade(double volume) async {
    try {
      _log('Finalizing crossfade');
      await _bgm!.stop();
      await _bgm!.dispose();
      _bgm = _bgmNext;
      _bgmVol = volume;
      _bgmNext = null;
      _fadeTimer?.cancel();
      _crossing = false;
      _log('Crossfade completed successfully');
    } catch (e, stackTrace) {
      _logError('Error finalizing crossfade', e, stackTrace);
      await _cleanupOnError();
    }
  }

  Future<void> _cleanupOnError() async {
    _log('Attempting to cleanup after error...');
    try {
      _fadeTimer?.cancel();
      if (_bgmNext != null) {
        await _bgmNext!.stop();
        await _bgmNext!.dispose();
        _bgmNext = null;
      }
      if (_bgm != null) {
        await _bgm!.stop();
        await _bgm!.dispose();
        _bgm = null;
      }
      _crossing = false;
      _bgmVol = 1.0;
      _log('Cleanup completed');
    } catch (e, stackTrace) {
      _logError('Error during cleanup', e, stackTrace);
    }
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
