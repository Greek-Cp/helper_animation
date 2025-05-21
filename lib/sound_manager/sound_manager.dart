import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

/// Enum for click event sounds
enum ClickSound {
  gameClick,
  selectClick,
}

/// Enum for background music
enum BGMSound {
  birdsSinging,
  fluteMusic,
}

/// Enum for sound effects
enum SFXSound {
  airWoosh,
}

/// Enum for notification sounds
enum NotificationSound {
  retroArcade,
  mysteryAlert,
}

/// Main sound category enum
enum SoundCategory {
  clickEvent,
  bgm,
  sfx,
  notification,
}

/// Class to control sound playback
class SoundController {
  dynamic _player;
  bool _autoPlay;
  double _volume;
  bool _loop;

  String? _currentPath;
  dynamic _currentSound;
  SoundCategory? _currentCategory;
  bool _isPlaying = false;

  final _state = StreamController<String>.broadcast();
  Stream<String> get soundState => _state.stream;

  SoundController({
    bool autoPlay = false,
    double volume = 1.0,
    bool loop = false,
  })  : _autoPlay = autoPlay,
        _volume = volume,
        _loop = loop;

  /* ─────────────────────── PLAY SOUND ─────────────────────── */

  Future<void> playSound({
    required SoundCategory category,
    required dynamic sound,
    bool? autoPlay,
    double? volume,
    bool? loop,
  }) async {
    try {
      final path = _getSoundPath(category, sound);
      if (path == null) return;

      if (volume != null) _volume = volume;
      if (loop != null) _loop = loop;

      _currentPath = path;
      _currentSound = sound;
      _currentCategory = category;

      /* ---------- BGM memakai FlameAudio.bgm ---------- */
      if (category == SoundCategory.bgm) {
        await FlameAudio.bgm.stop();
        final shouldPlay = autoPlay ?? _autoPlay;
        await FlameAudio.bgm.play(path, volume: _volume);
        _isPlaying = true;
        if (!shouldPlay) {
          await FlameAudio.bgm.pause();
          _isPlaying = false;
        }
        _state.add('playing');
        return;
      }

      /* ---------- SFX / Click / Notification ---------- */
      _isPlaying = true;
      _state.add('playing');

      if (_loop) {
        _player = await FlameAudio.loop(path, volume: _volume);
      } else {
        _player = await FlameAudio.play(path, volume: _volume);
        // Add completion listener
        _player?.onPlayerComplete.listen((_) {
          _isPlaying = false;
          _state.add('completed');
        });
      }
    } catch (e) {
      debugPrint('Sound error (playSound): $e');
      _state.add('error:$e');
    }
  }

  /* ───────────── GENERIC CONTROLS (play/pause/…) ──────────── */

  Future<void> play() async {
    if (_currentCategory == SoundCategory.bgm) {
      await FlameAudio.bgm.resume();
    } else {
      await _player?.resume();
    }
    _isPlaying = true;
    _state.add('playing');
  }

  Future<void> pause() async {
    if (_currentCategory == SoundCategory.bgm) {
      await FlameAudio.bgm.pause();
    } else {
      await _player?.pause();
    }
    _isPlaying = false;
    _state.add('paused');
  }

  Future<void> stop() async {
    if (_currentCategory == SoundCategory.bgm) {
      await FlameAudio.bgm.stop();
    } else {
      await _player?.stop();
    }
    _isPlaying = false;
    _state.add('stopped');
  }

  /* ──────────────────── setVolume / setLoop ───────────────── */

  Future<void> setVolume(double v) async {
    _volume = v.clamp(0.0, 1.0);
    debugPrint('🔊 Setting volume to: $_volume');
    if (_currentCategory == SoundCategory.bgm) {
      if (_isPlaying) {
        await FlameAudio.bgm.play(_currentPath!, volume: _volume);
        debugPrint('🔊 BGM volume set to: $_volume');
      }
    } else {
      await _player?.setVolume(_volume);
      debugPrint('🔊 SFX volume set to: $_volume');
    }
    _state.add('volume_changed');
  }

  /// Mengganti looping: stop player lama, putar ulang dengan/ tanpa loop.
  Future<void> setLoop(bool loop) async {
    if (_currentCategory == SoundCategory.bgm) {
      // BGM diputar terus oleh FlameAudio.bgm; biarkan pengguna kontrol di luar.
      _loop = loop;
      _state.add('loop_changed');
      return;
    }

    if (_loop == loop) return; // tidak berubah
    _loop = loop;
    if (_currentPath == null) return;

    // Re-create player dengan mode baru
    await _player?.stop();
    await _player?.dispose();
    _player = _loop
        ? await FlameAudio.loop(_currentPath!, volume: _volume)
        : await FlameAudio.play(_currentPath!, volume: _volume);

    _state.add('loop_changed');
  }

  void setAutoPlay(bool auto) {
    _autoPlay = auto;
    _state.add('autoplay_changed');
  }

  Future<void> replay() async {
    if (_currentCategory == SoundCategory.bgm) {
      await FlameAudio.bgm.stop();
      await FlameAudio.bgm.play(_currentPath!, volume: _volume);
    } else {
      await _player?.seek(Duration.zero);
      await _player?.play();
    }
    _state.add('replaying');
  }

  Future<void> dispose() async {
    await _player?.dispose();
    await _state.close();
    if (_currentCategory == SoundCategory.bgm) {
      await FlameAudio.bgm.stop();
    }
    _isPlaying = false;
  }

  /* ───────────────────────── GETTERS ───────────────────────── */

  bool get isPlaying => _isPlaying;

  double get volume => _volume;
  bool get autoPlay => _autoPlay;
  bool get loop => _loop;
  String? get currentPath => _currentPath;
  dynamic get currentSound => _currentSound;
  SoundCategory? get currentCategory => _currentCategory;

  /* ──────────────────────── INTERNAL ──────────────────────── */

  String? _getSoundPath(SoundCategory c, dynamic s) {
    switch (c) {
      case SoundCategory.clickEvent:
        return (s is ClickSound)
            ? SoundManager.instance.clickSoundPaths[s]
            : null;
      case SoundCategory.bgm:
        return (s is BGMSound) ? SoundManager.instance.bgmSoundPaths[s] : null;
      case SoundCategory.sfx:
        return (s is SFXSound) ? SoundManager.instance.sfxSoundPaths[s] : null;
      case SoundCategory.notification:
        return (s is NotificationSound)
            ? SoundManager.instance.notificationSoundPaths[s]
            : null;
    }
  }
}

const _assetPrefix = 'packages/helper_animation/';

class SoundManager {
  // Singleton pattern
  static final SoundManager instance = SoundManager._internal();
  factory SoundManager() => instance;
  SoundManager._internal();

  // Map asset paths for each sound enum
  final Map<ClickSound, String> clickSoundPaths = {
    ClickSound.gameClick:
        '${_assetPrefix}assets/sounds/click/mixkit-game-click-1114.wav',
    ClickSound.selectClick:
        '${_assetPrefix}assets/sounds/click/mixkit-select-click-1109.wav',
  };

  final Map<BGMSound, String> bgmSoundPaths = {
    BGMSound.birdsSinging:
        '${_assetPrefix}assets/sounds/bgm/mixkit-little-birds-singing-in-the-trees-17.wav',
    BGMSound.fluteMusic:
        '${_assetPrefix}assets/sounds/bgm/mixkit-melodical-flute-music-notification-2310.wav',
  };

  final Map<SFXSound, String> sfxSoundPaths = {
    SFXSound.airWoosh:
        '${_assetPrefix}assets/sounds/sfx/mixkit-air-woosh-1489.wav',
  };

  final Map<NotificationSound, String> notificationSoundPaths = {
    NotificationSound.retroArcade:
        '${_assetPrefix}assets/sounds/notification/mixkit-retro-arcade-casino-notification-211.wav',
    NotificationSound.mysteryAlert:
        '${_assetPrefix}assets/sounds/notification/mixkit-video-game-mystery-alert-234.wav',
  };

  // Store all active widget sound controllers
  final Map<Key, _WidgetSoundData> _widgetSoundControllers = {};

  // Store all active BGM controllers with their original volumes
  final Map<SoundController, double> _bgmOriginalVolumes = {};
  final Set<SoundController> _uniqueBGMControllers =
      {}; // Track unique controllers
  final Map<String, SoundController> _bgmControllers = {};

  // Current active route
  String _currentRoute = '/';

  // General settings
  bool _isMuted = false;
  double _masterVolume = 1.0;

  // Ducking properties
  bool _isDucking = false;
  Timer? _duckingTimer;
  Timer? _fadeTimer;
  AudioPlayer? _bgmPlayer;
  double _currentBGMVolume = 1.0;
  static const Duration _duckingDelay = Duration(milliseconds: 500);
  static const Duration _fadeStepDuration =
      Duration(milliseconds: 16); // ~60fps for smooth transition
  static const Duration _volumeTransitionDuration = Duration(milliseconds: 300);
  static const double _duckingVolume = 0.2;

  /// Smoothly fade BGM volume
  Future<void> _smoothVolumeFade(double targetVolume) async {
    if (_bgmPlayer == null) return;

    // Cancel any ongoing fade
    _fadeTimer?.cancel();

    final startVolume = _currentBGMVolume;
    final totalSteps = (_volumeTransitionDuration.inMilliseconds /
            _fadeStepDuration.inMilliseconds)
        .round();
    final volumeDiff = targetVolume - startVolume;
    int currentStep = 0;

    debugPrint(
        '🔊 Starting fade from ${startVolume.toStringAsFixed(3)} to ${targetVolume.toStringAsFixed(3)}');

    void updateVolume() async {
      currentStep++;
      if (currentStep >= totalSteps) {
        _fadeTimer?.cancel();
        _fadeTimer = null;
        _currentBGMVolume = targetVolume;
        await _bgmPlayer?.setVolume(targetVolume);
        debugPrint('🔊 Fade completed: ${targetVolume.toStringAsFixed(3)}');
        return;
      }

      // Smooth easing function
      final progress = currentStep / totalSteps;
      final easedProgress =
          -0.5 * (cos(pi * progress) - 1); // Smoother sinusoidal easing
      final newVolume = startVolume + (volumeDiff * easedProgress);

      _currentBGMVolume = newVolume;
      await _bgmPlayer?.setVolume(newVolume);
    }

    _fadeTimer = Timer.periodic(_fadeStepDuration, (_) => updateVolume());
  }

  /// Handle ducking of BGM
  Future<void> _handleDucking() async {
    if (!_isDucking) {
      _isDucking = true;
      debugPrint('🔊 -------- DUCKING START --------');

      // Store original volume if not already stored
      for (final controller in _bgmControllers.values) {
        if (controller.isPlaying) {
          _bgmOriginalVolumes[controller] = controller.volume;
        }
      }

      // Smoothly duck to target volume
      final targetVolume = _currentBGMVolume * _duckingVolume;
      await _smoothVolumeFade(targetVolume);
    }

    // Reset existing timer
    _duckingTimer?.cancel();

    // Start new timer to restore volume
    _duckingTimer = Timer(_duckingDelay, () async {
      await _checkAndRestoreVolume();
    });
  }

  /// Check if we can restore volume and do so if possible
  Future<void> _checkAndRestoreVolume() async {
    bool otherSoundsPlaying = false;
    for (final data in _widgetSoundControllers.values) {
      if (data.controller.isPlaying && data.category != SoundCategory.bgm) {
        otherSoundsPlaying = true;
        break;
      }
    }

    if (!otherSoundsPlaying) {
      debugPrint('🔊 -------- VOLUME RESTORE --------');

      // Find the original volume to restore to
      double originalVolume = 1.0;
      for (final entry in _bgmControllers.entries) {
        if (entry.value.isPlaying) {
          originalVolume =
              _bgmOriginalVolumes[entry.value] ?? entry.value.volume;
          break;
        }
      }

      // Smoothly restore volume
      await _smoothVolumeFade(originalVolume);
      _isDucking = false;
    }
  }

  /// Register a widget sound controller
  void registerWidgetSound(Key key, _WidgetSoundData data) {
    _widgetSoundControllers[key] = data;

    // Add listener for sound state to handle ducking
    if (data.category != SoundCategory.bgm) {
      data.controller.soundState.listen((state) {
        if (state == 'playing') {
          debugPrint('🔊 Sound effect started playing, triggering duck');
          _handleDucking();
        } else if (state == 'completed') {
          debugPrint('🔊 Sound effect completed, checking for volume restore');
          _checkAndRestoreVolume();
        }
      });
    } else {
      // If it's a BGM, store it in our BGM controllers
      _uniqueBGMControllers.add(data.controller);
    }
  }

  /// Register a BGM controller
  void registerBGM(SoundController controller, {String? route}) {
    final key = route ?? 'global';

    // Only store original volume if this is a new controller
    if (_uniqueBGMControllers.add(controller)) {
      // Returns true if controller was added
      _bgmOriginalVolumes[controller] = controller.volume;
      debugPrint('🔊 Stored original BGM volume: ${controller.volume}');
    }

    _bgmControllers[key] = controller;
  }

  /// Unregister a widget sound controller
  Future<void> unregisterWidgetSound(Key key) async {
    if (_widgetSoundControllers.containsKey(key)) {
      final data = _widgetSoundControllers[key]!;
      if (!data.isExternalController) {
        await data.controller.dispose();
      }
      _widgetSoundControllers.remove(key);

      // Also remove from BGM tracking if it was a BGM
      if (data.category == SoundCategory.bgm) {
        _bgmOriginalVolumes.remove(data.controller);
        _uniqueBGMControllers.remove(data.controller);
        _bgmControllers
            .removeWhere((_, controller) => controller == data.controller);
      }
    }
  }

  /// Set current route and handle BGM accordingly
  Future<void> setCurrentRoute(String route) async {
    _currentRoute = route;
    _handleRouteChange();
  }

  Future<void> _handleRouteChange() async {
    // Handle route-specific BGM changes
    for (final entry in _bgmControllers.entries) {
      final isGlobal = entry.key == 'global';
      final isCurrentRoute = entry.key == _currentRoute;

      if (isGlobal || isCurrentRoute) {
        await entry.value.play();
      } else {
        await entry.value.pause();
      }
    }
  }

  /// Set master volume
  Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume.clamp(0.0, 1.0);

    // If we're currently ducking, adjust the ducked volume
    if (_isDucking) {
      final adjustedVolume = _masterVolume * _duckingVolume;
      await _smoothVolumeFade(adjustedVolume);
    } else {
      await _smoothVolumeFade(_masterVolume);
    }

    // Update non-BGM sounds immediately
    for (final data in _widgetSoundControllers.values) {
      if (data.category != SoundCategory.bgm) {
        await data.controller.setVolume(data.controller.volume * _masterVolume);
      }
    }
  }

  /// Mute/unmute all sounds
  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    final effectiveVolume = _isMuted ? 0.0 : _masterVolume;

    for (final data in _widgetSoundControllers.values) {
      await data.controller.setVolume(data.controller.volume * effectiveVolume);
    }
  }

  /// Dispose all controllers
  Future<void> disposeAll() async {
    _duckingTimer?.cancel();
    _fadeTimer?.cancel();
    _bgmPlayer?.dispose();
    _duckingTimer = null;
    _fadeTimer = null;
    _bgmPlayer = null;
    _isDucking = false;

    for (final data in _widgetSoundControllers.values) {
      if (!data.isExternalController) {
        await data.controller.dispose();
      }
    }
    _widgetSoundControllers.clear();
    _bgmControllers.clear();
    _bgmOriginalVolumes.clear();
    _uniqueBGMControllers.clear();
  }

  /// Check if a sound is playing for a specific widget
  bool isPlayingForWidget(Key key) {
    return _widgetSoundControllers.containsKey(key) &&
        _widgetSoundControllers[key]!.controller.isPlaying;
  }

  /// Get current route
  String get currentRoute => _currentRoute;

  /// Get master volume
  double get masterVolume => _masterVolume;

  /// Check if audio is muted
  bool get isMuted => _isMuted;

  /// Play BGM with the current AudioPlayer
  Future<void> playBGM(String path, {double volume = 1.0}) async {
    _bgmPlayer?.stop();
    _bgmPlayer?.dispose();

    _bgmPlayer = await FlameAudio.loop(path,
        volume: _isDucking ? volume * _duckingVolume : volume);
    _currentBGMVolume = volume;
  }

  /// Get the sound path for a given category and sound
  String? _getSoundPath(SoundCategory category, dynamic sound) {
    switch (category) {
      case SoundCategory.clickEvent:
        return (sound is ClickSound) ? clickSoundPaths[sound] : null;
      case SoundCategory.bgm:
        return (sound is BGMSound) ? bgmSoundPaths[sound] : null;
      case SoundCategory.sfx:
        return (sound is SFXSound) ? sfxSoundPaths[sound] : null;
      case SoundCategory.notification:
        return (sound is NotificationSound)
            ? notificationSoundPaths[sound]
            : null;
    }
  }
}

/// Internal class to store widget sound data
class _WidgetSoundData {
  final SoundController controller;
  final bool isExternalController;
  final SoundCategory? category;
  final dynamic sound;

  _WidgetSoundData({
    required this.controller,
    this.isExternalController = false,
    this.category,
    this.sound,
  });
}

/// Extension for adding sound to widgets
extension SoundExtension on Widget {
  /// Add sound to a widget that will play when tapped
  Widget addSound({
    SoundCategory category = SoundCategory.clickEvent,
    dynamic sound = ClickSound.gameClick,
    SoundController? controller,
    double volume = 1.0,
    bool autoPlay = false,
    bool loop = false,
    Key? key,
  }) {
    return _SoundWidget(
      child: this,
      category: category,
      sound: sound,
      externalController: controller,
      volume: volume,
      autoPlay: autoPlay,
      loop: loop,
      widgetKey: key ?? UniqueKey(),
      bgm: false,
    );
  }

  /// Add background music to a widget
  Widget addBGM({
    BGMSound sound = BGMSound.birdsSinging,
    SoundController? controller,
    double volume = 0.5,
    bool autoPlay = true,
    bool loop = true,
    Key? key,
    String? route,
    bool global = false,
  }) {
    final effectiveKey = key ?? UniqueKey();
    final effectiveController = controller ??
        SoundController(
          autoPlay: autoPlay,
          volume: volume,
          loop: loop,
        );

    // Register the BGM controller
    SoundManager.instance.registerBGM(
      effectiveController,
      route: global ? 'global' : route,
    );

    return _SoundWidget(
      child: this,
      category: SoundCategory.bgm,
      sound: sound,
      externalController: effectiveController,
      volume: volume,
      autoPlay: autoPlay,
      loop: loop,
      widgetKey: effectiveKey,
      bgm: true,
      route: route,
      global: global,
    );
  }
}

/// Internal widget for handling sound
class _SoundWidget extends StatefulWidget {
  final Widget child;
  final SoundCategory category;
  final dynamic sound;
  final SoundController? externalController;
  final double volume;
  final bool autoPlay;
  final bool loop;
  final Key widgetKey;
  final bool bgm;
  final String? route;
  final bool global;

  const _SoundWidget({
    required this.child,
    required this.category,
    required this.sound,
    required this.widgetKey,
    this.externalController,
    this.volume = 1.0,
    this.autoPlay = false,
    this.loop = false,
    this.bgm = false,
    this.route,
    this.global = false,
  });

  @override
  _SoundWidgetState createState() => _SoundWidgetState();
}

class _SoundWidgetState extends State<_SoundWidget> {
  late SoundController _controller;
  bool _isExternalController = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    if (widget.externalController != null) {
      _controller = widget.externalController!;
      _isExternalController = true;
    } else {
      _controller = SoundController(
        autoPlay: widget.autoPlay,
        volume: widget.volume * SoundManager.instance.masterVolume,
        loop: widget.loop,
      );
    }

    // For BGM, set it up differently
    if (widget.bgm) {
      _setupBGM();
    } else {
      // Register in the sound manager
      SoundManager.instance.registerWidgetSound(
        widget.widgetKey,
        _WidgetSoundData(
          controller: _controller,
          isExternalController: _isExternalController,
          category: widget.category,
          sound: widget.sound,
        ),
      );

      // If autoplay is on, play the sound immediately
      if (widget.autoPlay) {
        _controller.playSound(
          category: widget.category,
          sound: widget.sound,
          autoPlay: true,
        );
      }
    }
  }

  void _setupBGM() async {
    final path =
        SoundManager.instance._getSoundPath(widget.category, widget.sound);
    if (path == null) return;

    // Register in the sound manager
    SoundManager.instance.registerWidgetSound(
      widget.widgetKey,
      _WidgetSoundData(
        controller: _controller,
        isExternalController: _isExternalController,
        category: widget.category,
        sound: widget.sound,
      ),
    );

    if (widget.autoPlay) {
      await SoundManager.instance.playBGM(
        path,
        volume: widget.volume,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // For BGM, just return the child as-is
    if (widget.bgm) {
      return widget.child;
    }

    // For regular sounds, wrap in GestureDetector
    return GestureDetector(
      onTap: () {
        _controller.playSound(
          category: widget.category,
          sound: widget.sound,
          autoPlay: true,
          volume: widget.volume,
        );
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    SoundManager.instance.unregisterWidgetSound(widget.widgetKey);
    if (!_isExternalController) {
      _controller.dispose();
    }
    super.dispose();
  }
}

/// Widget that provides route-aware BGM
class SoundRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      SoundManager.instance.setCurrentRoute(route.settings.name!);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute?.settings.name != null) {
      SoundManager.instance.setCurrentRoute(previousRoute!.settings.name!);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute?.settings.name != null) {
      SoundManager.instance.setCurrentRoute(newRoute!.settings.name!);
    }
  }
}
