import 'dart:async';
import 'dart:math' as math;

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:helper_animation/sound_manager/sound_enums.dart';
import 'package:helper_animation/sound_manager/sound_paths.dart';
import 'package:shared_preferences/shared_preferences.dart';

final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();

/// Type of sound to be played
enum SoundType {
  /// Sound played on click/tap
  click,

  /// Sound effect played on widget appear
  sfx,

  /// Notification sound
  notification,
}

/// ─────────────────────────────────────────────────────────────────────────────
///  UTIL
String _relative(String full) {
  debugPrint('[PATH] Converting path: $full');

  // Untuk package assets, pastikan konsisten
  if (full.startsWith('packages/helper_animation/assets/')) {
    final result = full.replaceFirst('packages/helper_animation/assets/', '');
    debugPrint('[PATH] Package path converted to: $result');
    return result;
  } else if (full.startsWith('packages/helper_animation/')) {
    final result = full.replaceFirst('packages/helper_animation/', '');
    debugPrint('[PATH] Package root converted to: $result');
    return result;
  } else if (full.startsWith('assets/')) {
    final result = full.replaceFirst('assets/', '');
    debugPrint('[PATH] Assets path converted to: $result');
    return result;
  }

  debugPrint('[PATH] Path unchanged: $full');
  return full;
}

/// Helper untuk convert path ke format yang tepat untuk AudioPlayer
String _getAudioPlayerPath(String originalPath) {
  if (originalPath.startsWith('assets/')) {
    return 'packages/helper_animation/$originalPath';
  }
  return originalPath;
}

void _logVol(double v) =>
    debugPrint('[BGM] 🔊 volume → ${v.toStringAsFixed(2)}');

/// ─────────────────────────────────────────────────────────────────────────────
///  ONE-SHOT PLAY + DUCKING HOOK
Future<void> playOneShot(String absPath, {double volume = 1}) async {
  debugPrint('[SFX] 🎵 Playing one-shot: $absPath (volume: $volume)');

  try {
    BgmManager.instance.duckStart();

    // ==================== KEY FIX: Consistent path handling ====================
    String relPath;
    if (absPath.startsWith('packages/helper_animation/assets/')) {
      relPath = absPath.replaceFirst('packages/helper_animation/assets/', '');
    } else if (absPath.startsWith('assets/')) {
      // Convert to package path first
      final packagePath = SoundPaths.instance.getAudioPlayerPath(absPath);
      relPath = _relative(packagePath);
    } else {
      relPath = absPath;
    }

    debugPrint('[SFX] 🎵 Converted relative path: $relPath');

    AudioPlayer? player;

    try {
      player = AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);

      await player.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );

      // ==================== KEY FIX: Use same path logic as BGM ====================
      try {
        await player.setSource(AssetSource(relPath));
        debugPrint('[SFX] 🎵 ✅ AudioPlayer source set successfully');
      } catch (e) {
        debugPrint(
            '[SFX] 🎵 ❌ AudioPlayer failed, trying FlameAudio fallback: $e');

        // Fallback ke FlameAudio dengan consistent prefix
        player.dispose();
        FlameAudio.audioCache.prefix = 'packages/helper_animation/assets/';
        final flamePlayer = await FlameAudio.play(relPath, volume: volume);

        bool hasRestored = false;
        void restoreBgm() {
          if (!hasRestored) {
            hasRestored = true;
            BgmManager.instance.duckEnd();
          }
        }

        Timer(const Duration(milliseconds: 500), restoreBgm);
        flamePlayer.onPlayerComplete.listen((_) => restoreBgm());
        return;
      }

      await player.setVolume(volume);
      await player.resume();

      // Rest of playOneShot logic (unchanged)
      bool hasRestored = false;
      Timer? fallbackTimer;
      StreamSubscription? subscription;

      void restoreBgm() {
        if (!hasRestored) {
          hasRestored = true;
          BgmManager.instance.duckEnd();
          fallbackTimer?.cancel();
          subscription?.cancel();
          player?.dispose();
        }
      }

      subscription = player.onPlayerComplete.listen((_) => restoreBgm());

      try {
        final duration = await player.getDuration();
        final fallbackDuration = duration?.inMilliseconds ?? 400;
        fallbackTimer =
            Timer(Duration(milliseconds: fallbackDuration + 100), restoreBgm);
      } catch (e) {
        fallbackTimer = Timer(const Duration(milliseconds: 400), restoreBgm);
      }
    } catch (e) {
      debugPrint('[SFX] 🎵 ❌ AudioPlayer creation failed: $e');
      BgmManager.instance.duckEnd();
    }
  } catch (e) {
    debugPrint('[SFX] 🎵 ❌ Error playing sound: $e');
    BgmManager.instance.duckEnd();
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
///  EXTENSIONS
// ─────────────────────────────────────────────────────────────────────────────
//  EXTENSIONS
extension SoundExtension on Widget {
  /// [sound]         → enum sesuai `type`
  /// [type]          → click | sfx | notification
  /// [volume]        → 0.0 – 1.0  (default 1.0)
  /// [isDragWidget]  → true jika widget ini Draggable/sejenis
  Widget addSound(
    dynamic sound,
    SoundType type, {
    double volume = 1.0,
    bool isDragWidget = false,
  }) {
    // Ambil path sesuai tipe
    String path;
    switch (type) {
      case SoundType.click:
        path = SoundPaths.instance.clickSoundPaths[sound as ClickSound]!;
        break;
      case SoundType.sfx:
        path = SoundPaths.instance.sfxSoundPaths[sound as SFXSound]!;
        break;
      case SoundType.notification:
        path = SoundPaths
            .instance.notificationSoundPaths[sound as NotificationSound]!;
        break;
    }

    // Draggable → Listener (tidak mengganggu gesture internal)
    if (isDragWidget) {
      return Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => playOneShot(path, volume: volume),
        child: this,
      );
    }

    // Default (tap)
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => playOneShot(path, volume: volume),
      child: this,
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
///  BGM EXTENSION
extension BgmExtension on Widget {
  Widget addBGM(BGMSound bgm) => _BgmWrapper(child: this, bgm: bgm);
}

/// ─────────────────────────────────────────────────────────────────────────────
///  BGM GLOBAL EXTENSION
extension BgmGlobalExtension on Widget {
  Widget addBGMGlobal(List<BGMSound> listSound) => _BgmGlobalWrapper(
        child: this,
        listSound: listSound,
      );
}

class _BgmWrapper extends StatefulWidget {
  const _BgmWrapper({required this.child, required this.bgm});
  final Widget child;
  final BGMSound bgm;
  @override
  State<_BgmWrapper> createState() => _BgmWrapperState();
}

class _BgmWrapperState extends State<_BgmWrapper> with RouteAware {
  @override
  void initState() {
    super.initState();
    BgmManager.instance.push(widget.bgm);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    BgmManager.instance.pop(widget.bgm);
    super.dispose();
  }

  @override
  void didPushNext() {
    // Ketika page ini di-push oleh page lain, pause BGM
    BgmManager.instance.pauseForNavigation();
  }

  @override
  void didPopNext() {
    // Ketika kembali ke page ini, resume BGM
    BgmManager.instance.resumeFromNavigation();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _BgmGlobalWrapper extends StatefulWidget {
  const _BgmGlobalWrapper({
    required this.child,
    required this.listSound,
  });
  final Widget child;
  final List<BGMSound> listSound;
  @override
  State<_BgmGlobalWrapper> createState() => _BgmGlobalWrapperState();
}

class _BgmGlobalWrapperState extends State<_BgmGlobalWrapper> with RouteAware {
  @override
  void initState() {
    super.initState();
    BgmManager.instance.setGlobalBGM(widget.listSound);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    BgmManager.instance.clearGlobalBGM();
    super.dispose();
  }

  @override
  void didPushNext() {
    // Ketika page ini di-push oleh page lain, pause global BGM
    BgmManager.instance.pauseForNavigation();
  }

  @override
  void didPopNext() {
    // Ketika kembali ke page ini, resume global BGM
    BgmManager.instance.resumeFromNavigation();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// ─────────────────────────────────────────────────────────────────────────────
///  BGM MANAGER  (stack-aware + ducking + global BGM)
class BgmManager {
  BgmManager._();
  static final BgmManager instance = BgmManager._();

  final _stack = <BGMSound>[];
  AudioPlayer? _current;
  BGMSound? _currentSound;

  // Global BGM state
  List<BGMSound> _globalBGMList = [];
  int _globalCounterSound = 0;
  int _currentTrackIndex = 0;
  bool _isGlobalBGMActive = false;
  AudioPlayer? _globalPlayer;
  BGMSound? _globalCurrentSound;

  /* cross-fade antar-halaman */
  final _xFade = const Duration(milliseconds: 600);

  /* ducking untuk SFX - IMPROVED */
  int _duckCounter = 0;
  double _baseVolume = 1.0; // Volume dasar BGM
  double _currentVol = 1.0; // Volume aktual saat ini
  double _duckVolume =
      0.6; // Volume saat di-duck (60% - lebih tinggi dari sebelumnya)

  /* navigation state */
  bool _isPausedForNavigation = false;

  /* volume animation state */
  Timer? _volumeAnimationTimer;

  // SharedPreferences keys
  static const String _currentTrackKey = 'bgm_current_track_index';
  static const String _counterSoundKey = 'bgm_counter_sound';

  /* ── GLOBAL BGM API ── */
  Future<void> setGlobalBGM(List<BGMSound> listSound) async {
    debugPrint('[BGM] 🌍 Setting global BGM with ${listSound.length} tracks');
    _globalBGMList = listSound;

    if (listSound.isNotEmpty) {
      // Load saved state
      await _loadGlobalBGMState();
      _isGlobalBGMActive = true;

      // Start global BGM if no specific BGM is playing
      if (_stack.isEmpty) {
        await _startGlobalBGM();
      }
    }
  }

  void clearGlobalBGM() {
    debugPrint('[BGM] 🌍 Clearing global BGM');
    _isGlobalBGMActive = false;
    _stopGlobalBGM();
    _globalBGMList.clear();
  }

  Future<void> _loadGlobalBGMState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentTrackIndex = prefs.getInt(_currentTrackKey) ?? 0;
      _globalCounterSound = prefs.getInt(_counterSoundKey) ?? 0;

      // Ensure indices are valid
      if (_currentTrackIndex >= _globalBGMList.length) {
        _currentTrackIndex = 0;
      }

      debugPrint(
          '[BGM] 🌍 Loaded state - Track: $_currentTrackIndex, Counter: $_globalCounterSound');
    } catch (e) {
      debugPrint('[BGM] 🌍 Error loading global BGM state: $e');
      _currentTrackIndex = 0;
      _globalCounterSound = 0;
    }
  }

  Future<void> _saveGlobalBGMState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_currentTrackKey, _currentTrackIndex);
      await prefs.setInt(_counterSoundKey, _globalCounterSound);
      debugPrint(
          '[BGM] 🌍 Saved state - Track: $_currentTrackIndex, Counter: $_globalCounterSound');
    } catch (e) {
      debugPrint('[BGM] 🌍 Error saving global BGM state: $e');
    }
  }

  Future<void> _startGlobalBGM() async {
    if (!_isGlobalBGMActive || _globalBGMList.isEmpty) return;

    try {
      debugPrint('[BGM] 🌍 Starting global BGM - Track $_currentTrackIndex');

      final newSound = _globalBGMList[_currentTrackIndex];
      await _switchToGlobalBgm(newSound);
    } catch (e) {
      debugPrint('[BGM] 🌍 Error starting global BGM: $e');
    }
  }

  Future<void> _stopGlobalBGM() async {
    if (_globalPlayer != null) {
      debugPrint('[BGM] 🌍 Stopping global BGM');
      _volumeAnimationTimer?.cancel();
      await _globalPlayer!.stop();
      await _globalPlayer!.dispose();
      _globalPlayer = null;
      _globalCurrentSound = null;
    }
  }

  Future<void> _switchToGlobalBgm(BGMSound newBgm) async {
    try {
      await _stopGlobalBGM();

      final newPlayer = AudioPlayer();

      // Audio context setup (unchanged)
      try {
        await newPlayer.setAudioContext(
          AudioContext(
            android: AudioContextAndroid(
              isSpeakerphoneOn: false,
              stayAwake: true,
              contentType: AndroidContentType.music,
              usageType: AndroidUsageType.game,
              audioFocus: AndroidAudioFocus.gain,
            ),
          ),
        );
      } catch (e) {
        debugPrint('[BGM] 🌍 Audio context not supported: $e');
      }

      await newPlayer.setReleaseMode(ReleaseMode.loop);

      // ==================== KEY FIX: Same path handling as specific BGM ====================
      final originalPath = SoundPaths.instance.bgmSoundPaths[newBgm]!;
      final packagedPath = SoundPaths.instance.getAudioPlayerPath(originalPath);
      final assetSourcePath = _relative(packagedPath);

      debugPrint('[BGM] 🌍 Original path: $originalPath');
      debugPrint('[BGM] 🌍 Packaged path: $packagedPath');
      debugPrint('[BGM] 🌍 AssetSource path: $assetSourcePath');

      try {
        await newPlayer.setSource(AssetSource(assetSourcePath));
        debugPrint('[BGM] 🌍 ✅ Successfully set global audio source');
      } catch (e) {
        debugPrint(
            '[BGM] 🌍 ❌ Failed with AssetSource, trying alternative: $e');

        final altPath = 'packages/helper_animation/$originalPath';
        final altAssetPath = _relative(altPath);
        debugPrint('[BGM] 🌍 Trying alternative path: $altAssetPath');

        await newPlayer.setSource(AssetSource(altAssetPath));
        debugPrint('[BGM] 🌍 ✅ Alternative path worked');
      }

      // Apply current duck state
      final initialVolume = _duckCounter > 0 ? _duckVolume : _baseVolume;
      await newPlayer.setVolume(initialVolume);
      await newPlayer.resume();

      _globalPlayer = newPlayer;
      _globalCurrentSound = newBgm;
      _currentVol = initialVolume;

      debugPrint('[BGM] 🌍 ✅ Global BGM switched to: $newBgm');
    } catch (e) {
      debugPrint('[BGM] 🌍 ❌ Error switching global BGM: $e');
      debugPrint('[BGM] 🌍 Stack trace: ${StackTrace.current}');
    }
  }

  void _incrementCounter() {
    _globalCounterSound++;
    if (_globalBGMList.isNotEmpty) {
      _currentTrackIndex = _globalCounterSound % _globalBGMList.length;
      debugPrint(
          '[BGM] 🌍 Counter incremented: $_globalCounterSound, Track: $_currentTrackIndex');
      _saveGlobalBGMState();
    }
  }

  /* ── PUBLIC API untuk wrapper ── */
  void push(BGMSound s) {
    debugPrint('[BGM] Push: $s');
    _stack.add(s);

    // Increment counter when entering page with specific BGM
    if (_isGlobalBGMActive) {
      _incrementCounter();
    }

    _queueRefresh();
  }

  void pop(BGMSound s) {
    debugPrint('[BGM] Pop: $s');
    _stack.remove(s);
    _queueRefresh();
  }

  /* ── NAVIGATION CONTROL ── */
  void pauseForNavigation() {
    debugPrint('[BGM] Pause for navigation');
    _isPausedForNavigation = true;
    _current?.pause();
    _globalPlayer?.pause();
  }

  void resumeFromNavigation() {
    debugPrint('[BGM] Resume from navigation');
    _isPausedForNavigation = false;
    if (_current != null && _currentSound != null) {
      _current!.resume();
    } else if (_globalPlayer != null && _globalCurrentSound != null) {
      _globalPlayer!.resume();
    }
  }

  /* ── IMPROVED DUCK API (untuk SFX) ── */
  void duckStart() {
    _duckCounter++;
    debugPrint('[BGM] 🦆 Duck start (counter: $_duckCounter)');
    debugPrint('[BGM] 🦆 Current volume before duck: $_currentVol');
    debugPrint('[BGM] 🦆 Target duck volume: $_duckVolume');

    if (_duckCounter == 1) {
      // Pertama kali di-duck, turunkan volume tapi pastikan tetap playing
      final activePlayer = _current ?? _globalPlayer;
      if (activePlayer != null) {
        debugPrint('[BGM] 🦆 Player exists, starting duck...');
        _setVolumeSmooth(_duckVolume, fast: true);

        // Pastikan BGM tidak di-pause oleh sistem
        if (!_isPausedForNavigation) {
          activePlayer.resume(); // Force resume jika terpause
          debugPrint('[BGM] 🦆 Force resumed BGM player');
        }
      } else {
        debugPrint('[BGM] 🦆 ❌ No current player to duck!');
      }
    } else {
      debugPrint('[BGM] 🦆 Already ducked, counter: $_duckCounter');
    }
  }

  void duckEnd() {
    if (_duckCounter > 0) {
      _duckCounter--;
      debugPrint('[BGM] 🦆 Duck end (counter: $_duckCounter)');
      debugPrint('[BGM] 🦆 Current volume before restore: $_currentVol');
      debugPrint('[BGM] 🦆 Target restore volume: $_baseVolume');

      if (_duckCounter == 0) {
        final activePlayer = _current ?? _globalPlayer;
        if (activePlayer != null) {
          debugPrint('[BGM] 🦆 Player exists, restoring volume...');

          // Delay sedikit sebelum restore untuk memastikan SFX benar-benar selesai
          Timer(const Duration(milliseconds: 50), () {
            // Kembali ke volume normal
            _setVolumeSmooth(_baseVolume, fast: false);

            // Pastikan BGM masih playing
            if (!_isPausedForNavigation && activePlayer != null) {
              activePlayer.resume();
              debugPrint('[BGM] 🦆 Force resumed BGM after restore');
            }
          });
        } else {
          debugPrint('[BGM] 🦆 ❌ No current player to restore!');
        }
      } else {
        debugPrint('[BGM] 🦆 Still ducked, counter: $_duckCounter');
      }
    } else {
      debugPrint('[BGM] 🦆 ❌ Duck end called but counter is 0!');
    }
  }

  /* ── IMPROVED Volume animation helper ── */
  void _setVolumeSmooth(double targetVol, {bool fast = false}) {
    debugPrint(
        '[BGM] 🔊 Volume smooth: ${_currentVol.toStringAsFixed(2)} → ${targetVol.toStringAsFixed(2)} (fast: $fast)');

    // Cancel existing animation
    _volumeAnimationTimer?.cancel();

    // Get active player (specific BGM takes priority over global)
    final activePlayer = _current ?? _globalPlayer;

    // Kalau belum ada BGM, simpan target saja
    if (activePlayer == null) {
      debugPrint('[BGM] 🔊 ❌ No current player for volume change');
      _currentVol = targetVol;
      _baseVolume = targetVol;
      return;
    }

    // Jika volume sudah sama, skip animation
    if ((_currentVol - targetVol).abs() < 0.01) {
      debugPrint('[BGM] 🔊 ✅ Volume already at target, skipping animation');
      return;
    }

    // Try direct volume set first as fallback mechanism
    try {
      activePlayer.setVolume(targetVol);
      _currentVol = targetVol;
      debugPrint(
          '[BGM] 🔊 ⚡ Direct volume set successful: ${targetVol.toStringAsFixed(2)}');
      _logVol(_currentVol);

      // Still do animation for smooth effect, but we have direct set as backup
    } catch (e) {
      debugPrint('[BGM] 🔊 ❌ Direct volume set failed: $e');
      return; // If direct set fails, don't bother with animation
    }

    // Untuk ducking yang cepat, gunakan less steps
    final steps = fast ? 4 : 8;
    final stepDuration = Duration(milliseconds: fast ? 8 : 12);

    final startVol = _currentVol;
    int currentStep = 0;

    debugPrint(
        '[BGM] 🔊 Starting volume animation: $steps steps, ${stepDuration.inMilliseconds}ms each');

    void animate() {
      final currentActivePlayer = _current ?? _globalPlayer;
      if (currentActivePlayer == null) {
        debugPrint('[BGM] 🔊 ❌ Player disappeared during animation');
        return;
      }

      currentStep++;
      final progress = currentStep / steps;

      if (progress >= 1.0) {
        // Animasi selesai - ensure final volume is set
        _currentVol = targetVol;
        try {
          currentActivePlayer.setVolume(_currentVol);
          debugPrint(
              '[BGM] 🔊 ✅ Animation complete: ${_currentVol.toStringAsFixed(2)}');
          _logVol(_currentVol);
        } catch (e) {
          debugPrint('[BGM] 🔊 ❌ Error setting final volume: $e');
        }
        return;
      }

      // Smooth curve untuk transisi yang lebih natural
      final easedProgress = _easeInOutCubic(progress);
      final newVol = startVol + (targetVol - startVol) * easedProgress;

      try {
        currentActivePlayer.setVolume(newVol);
        _currentVol = newVol;
        debugPrint(
            '[BGM] 🔊 Step $currentStep/$steps: ${_currentVol.toStringAsFixed(2)}');
        _logVol(_currentVol);
      } catch (e) {
        debugPrint('[BGM] 🔊 ❌ Error setting volume step $currentStep: $e');
        // Animation failed, but direct set already worked, so we're good
        return;
      }

      _volumeAnimationTimer = Timer(stepDuration, animate);
    }

    // Only animate if direct set worked
    animate();
  }

  // Easing function untuk transisi volume yang lebih smooth
  double _easeInOutCubic(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;
  }

  /* ── REFRESH stack (cross-fade) ── */
  bool _refreshQueued = false;
  void _queueRefresh() {
    if (!_refreshQueued) {
      _refreshQueued = true;
      scheduleMicrotask(() {
        _refreshQueued = false;
        _refresh();
      });
    }
  }

  Future<void> _refresh() async {
    try {
      if (_stack.isEmpty) {
        debugPrint('[BGM] Stack empty, checking for global BGM');
        await _stopCurrent();

        // Start global BGM if available and no specific BGM
        if (_isGlobalBGMActive && _globalBGMList.isNotEmpty) {
          await _startGlobalBGM();
        }
        return;
      }

      final top = _stack.last;
      if (top == _currentSound) {
        debugPrint('[BGM] Same BGM already playing: $top');
        return;
      }

      debugPrint('[BGM] Switching to: $top');

      // Stop global BGM when specific BGM starts
      if (_globalPlayer != null) {
        await _stopGlobalBGM();
      }

      await _switchToBgm(top);
    } catch (e) {
      debugPrint('[BGM] Error in refresh: $e');
    }
  }

  Future<void> _stopCurrent() async {
    if (_current != null) {
      _volumeAnimationTimer?.cancel();
      await _current!.stop();
      await _current!.dispose();
      _current = null;
      _currentSound = null;
      _currentVol = _baseVolume;
    }
  }

  Future<void> _switchToBgm(BGMSound newBgm) async {
    try {
      final newPlayer = AudioPlayer();

      // Audio context setup (unchanged)
      try {
        await newPlayer.setAudioContext(
          AudioContext(
            android: AudioContextAndroid(
              isSpeakerphoneOn: false,
              stayAwake: true,
              contentType: AndroidContentType.music,
              usageType: AndroidUsageType.game,
              audioFocus: AndroidAudioFocus.gain,
            ),
          ),
        );
      } catch (e) {
        debugPrint('[BGM] Audio context not supported: $e');
      }

      await newPlayer.setReleaseMode(ReleaseMode.loop);

      // ==================== KEY FIX: Correct Path Handling ====================
      final originalPath = SoundPaths.instance.bgmSoundPaths[newBgm]!;

      // CRITICAL: Use packages prefix for AudioPlayer
      final packagedPath = SoundPaths.instance.getAudioPlayerPath(originalPath);
      final assetSourcePath = _relative(packagedPath);

      debugPrint('[BGM] Original path: $originalPath');
      debugPrint('[BGM] Packaged path: $packagedPath');
      debugPrint('[BGM] AssetSource path: $assetSourcePath');

      // Try to use packaged path directly first
      try {
        await newPlayer.setSource(AssetSource(assetSourcePath));
        debugPrint('[BGM] ✅ Successfully set audio source');
      } catch (e) {
        debugPrint('[BGM] ❌ Failed with AssetSource, trying alternative: $e');

        // Alternative: try with different path format
        final altPath = 'packages/helper_animation/$originalPath';
        final altAssetPath = _relative(altPath);
        debugPrint('[BGM] Trying alternative path: $altAssetPath');

        await newPlayer.setSource(AssetSource(altAssetPath));
        debugPrint('[BGM] ✅ Alternative path worked');
      }

      await newPlayer.setVolume(0); // Start dengan volume 0
      await newPlayer.resume();

      // Cross-fade logic (unchanged)
      final oldPlayer = _current;
      _current = newPlayer;
      _currentSound = newBgm;

      if (oldPlayer != null) {
        await _crossFade(oldPlayer, newPlayer);
      } else {
        await _fadeIn(newPlayer);
      }

      debugPrint('[BGM] ✅ Successfully switched to: $newBgm');
    } catch (e) {
      debugPrint('[BGM] ❌ Error switching BGM: $e');
      debugPrint('[BGM] Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> _crossFade(AudioPlayer oldPlayer, AudioPlayer newPlayer) async {
    const steps = 15;
    final stepDuration = Duration(milliseconds: _xFade.inMilliseconds ~/ steps);

    for (int i = 0; i <= steps; i++) {
      final progress = i / steps;
      final oldVol = (1 - progress) * _currentVol;

      // Apply current duck state to new volume
      final targetNewVol = _duckCounter > 0 ? _duckVolume : _baseVolume;
      final newVol = progress * targetNewVol;

      try {
        await oldPlayer.setVolume(oldVol);
        await newPlayer.setVolume(newVol);

        if (i == steps) {
          // Cross-fade selesai
          _currentVol = targetNewVol;
          await oldPlayer.stop();
          await oldPlayer.dispose();
          debugPrint('[BGM] Cross-fade completed');
        } else {
          await Future.delayed(stepDuration);
        }
      } catch (e) {
        debugPrint('[BGM] Error during cross-fade step $i: $e');
        break;
      }
    }
  }

  Future<void> _fadeIn(AudioPlayer player) async {
    const steps = 10;
    const stepDuration = Duration(milliseconds: 30);

    // Apply current duck state
    final targetVol = _duckCounter > 0 ? _duckVolume : _baseVolume;

    for (int i = 0; i <= steps; i++) {
      final progress = i / steps;
      final vol = progress * targetVol;

      try {
        await player.setVolume(vol);
        if (i < steps) {
          await Future.delayed(stepDuration);
        }
      } catch (e) {
        debugPrint('[BGM] Error during fade-in step $i: $e');
        break;
      }
    }

    _currentVol = targetVol;
    debugPrint('[BGM] Fade-in completed');
  }

  /* ── PRELOAD ── */
  Future<void> preloadAll() async {
    try {
      // Debug paths first
      SoundPaths.instance.debugAllPaths();

      final allPaths = SoundPaths.instance.getAllRelativePaths();
      debugPrint('[BGM] Preloading ${allPaths.length} sound files...');

      // CRITICAL: Set consistent prefix for FlameAudio
      FlameAudio.audioCache.prefix = 'packages/helper_animation/assets/';

      // Load files individually with detailed logging
      int successCount = 0;
      for (final path in allPaths) {
        try {
          final fullPath = 'packages/helper_animation/assets/$path';
          debugPrint('[BGM] Loading: $path -> $fullPath');
          await FlameAudio.audioCache.load(path);
          successCount++;
          debugPrint('[BGM] ✅ Successfully loaded: $path');
        } catch (e) {
          debugPrint('[BGM] ❌ Failed to load $path: $e');
        }
      }

      debugPrint(
          '[BGM] Preload completed - $successCount/${allPaths.length} files loaded');
    } catch (e) {
      debugPrint('[BGM] Error during preload: $e');
    }
  }

  /// Manual control untuk debugging
  void setBaseVolume(double volume) {
    _baseVolume = volume.clamp(0.0, 1.0);
    if (_duckCounter == 0) {
      _setVolumeSmooth(_baseVolume);
    }
  }

  void pause() {
    _current?.pause();
    _globalPlayer?.pause();
  }

  void resume() {
    if (!_isPausedForNavigation) {
      _current?.resume();
      _globalPlayer?.resume();
    }
  }

  /// Debug method untuk check current state
  void debugState() {
    debugPrint('[BGM] Current state:');
    debugPrint('  - Stack: $_stack');
    debugPrint('  - Current sound: $_currentSound');
    debugPrint('  - Duck counter: $_duckCounter');
    debugPrint('  - Current volume: $_currentVol');
    debugPrint('  - Base volume: $_baseVolume');
    debugPrint('  - Is paused for navigation: $_isPausedForNavigation');
    debugPrint('  - Global BGM active: $_isGlobalBGMActive');
    debugPrint('  - Global BGM list: $_globalBGMList');
    debugPrint('  - Global current sound: $_globalCurrentSound');
    debugPrint('  - Global counter: $_globalCounterSound');
    debugPrint('  - Current track index: $_currentTrackIndex');
  }

  /// Force BGM to resume if it gets paused unexpectedly
  void forceResume() {
    if (!_isPausedForNavigation) {
      if (_current != null) {
        debugPrint('[BGM] Force resume specific BGM');
        _current!.resume();
      } else if (_globalPlayer != null) {
        debugPrint('[BGM] Force resume global BGM');
        _globalPlayer!.resume();
      }
    }
  }

  /// Get current player state for debugging
  Future<void> checkPlayerState() async {
    final activePlayer = _current ?? _globalPlayer;
    if (activePlayer != null) {
      try {
        final state = activePlayer.state;
        final position = await activePlayer.getCurrentPosition();
        final duration = await activePlayer.getDuration();
        debugPrint('[BGM] 🎮 Player state: $state');
        debugPrint(
            '[BGM] 🎮 Position: ${position?.inMilliseconds}ms / ${duration?.inMilliseconds}ms');
        debugPrint('[BGM] 🎮 Current volume in manager: $_currentVol');
        debugPrint('[BGM] 🎮 Base volume: $_baseVolume');
        debugPrint('[BGM] 🎮 Duck counter: $_duckCounter');
        debugPrint('[BGM] 🎮 Is global: ${_current == null ? 'YES' : 'NO'}');
      } catch (e) {
        debugPrint('[BGM] 🎮 ❌ Error checking player state: $e');
      }
    } else {
      debugPrint('[BGM] 🎮 ❌ No current player');
    }
  }

  /// Test volume setting directly
  Future<void> testVolume(double vol) async {
    final activePlayer = _current ?? _globalPlayer;
    if (activePlayer != null) {
      try {
        debugPrint('[BGM] 🧪 Testing direct volume set: $vol');
        await activePlayer.setVolume(vol);
        _currentVol = vol;
        debugPrint('[BGM] 🧪 ✅ Direct volume set successful');
      } catch (e) {
        debugPrint('[BGM] 🧪 ❌ Direct volume set failed: $e');
      }
    } else {
      debugPrint('[BGM] 🧪 ❌ No player to test volume');
    }
  }

  /// Manual duck test
  void testDuck() {
    debugPrint('[BGM] 🧪 Manual duck test');
    duckStart();
    Timer(const Duration(seconds: 2), () {
      debugPrint('[BGM] 🧪 Manual duck restore');
      duckEnd();
    });
  }

  /// Manual control untuk global BGM track
  Future<void> nextGlobalTrack() async {
    if (_globalBGMList.isNotEmpty && _isGlobalBGMActive) {
      _currentTrackIndex = (_currentTrackIndex + 1) % _globalBGMList.length;
      await _saveGlobalBGMState();

      // If currently playing global BGM, switch to new track
      if (_stack.isEmpty && _globalPlayer != null) {
        await _startGlobalBGM();
      }
      debugPrint('[BGM] 🌍 Manually switched to track: $_currentTrackIndex');
    }
  }

  Future<void> previousGlobalTrack() async {
    if (_globalBGMList.isNotEmpty && _isGlobalBGMActive) {
      _currentTrackIndex = (_currentTrackIndex - 1 + _globalBGMList.length) %
          _globalBGMList.length;
      await _saveGlobalBGMState();

      // If currently playing global BGM, switch to new track
      if (_stack.isEmpty && _globalPlayer != null) {
        await _startGlobalBGM();
      }
      debugPrint('[BGM] 🌍 Manually switched to track: $_currentTrackIndex');
    }
  }

  /// Get current global track info
  Map<String, dynamic> getGlobalTrackInfo() {
    return {
      'isActive': _isGlobalBGMActive,
      'currentTrackIndex': _currentTrackIndex,
      'totalTracks': _globalBGMList.length,
      'currentSound': _currentTrackIndex < _globalBGMList.length
          ? _globalBGMList[_currentTrackIndex]
          : null,
      'counterSound': _globalCounterSound,
      'isPlaying': _globalPlayer != null && _stack.isEmpty,
    };
  }
}
