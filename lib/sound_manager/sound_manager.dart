import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'sound_controller.dart';
import 'sound_enums.dart';
import 'sound_paths.dart';

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

class SoundManager {
  // Singleton pattern
  static final SoundManager instance = SoundManager._internal();
  factory SoundManager() => instance;
  SoundManager._internal();

  // Store all active widget sound controllers
  final Map<Key, _WidgetSoundData> _widgetSoundControllers = {};

  // Store all active BGM controllers with their original volumes
  final Map<SoundController, double> _bgmOriginalVolumes = {};
  final Set<SoundController> _uniqueBGMControllers = {};
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
  static const Duration _fadeStepDuration = Duration(milliseconds: 16);
  static const Duration _volumeTransitionDuration = Duration(milliseconds: 300);
  static const double _duckingVolume = 0.0;

  // Crossfade properties
  AudioPlayer? _nextBgmPlayer;
  static const Duration _crossfadeDuration = Duration(milliseconds: 1000);
  bool _isCrossfading = false;

  /// Get the sound path for a given category and sound
  String? _getSoundPath(SoundCategory category, dynamic sound) {
    return SoundPaths.instance.getSoundPath(category, sound);
  }

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
    debugPrint('🎵 Route changed to: $_currentRoute');

    // Find the BGM controller and path for the current route
    final routeController = _bgmControllers[_currentRoute];

    if (routeController != null && routeController.currentPath != null) {
      debugPrint('🎵 Found BGM for route: $_currentRoute');

      // Play the route-specific BGM
      await playBGM(
        routeController.currentPath!,
        volume: routeController.volume,
      );
    } else {
      // If no route-specific BGM, check for global BGM
      final globalController = _bgmControllers['global'];
      if (globalController != null && globalController.currentPath != null) {
        debugPrint('🎵 Using global BGM');
        await playBGM(
          globalController.currentPath!,
          volume: globalController.volume,
        );
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
    await _bgmPlayer?.dispose();
    await _nextBgmPlayer?.dispose();
    _duckingTimer = null;
    _fadeTimer = null;
    _bgmPlayer = null;
    _nextBgmPlayer = null;
    _isDucking = false;
    _isCrossfading = false;

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

  /// Smoothly transition between BGM tracks
  Future<void> _crossfadeBGM(String newPath, {double volume = 1.0}) async {
    if (_isCrossfading) return;
    _isCrossfading = true;

    try {
      // Create new BGM player
      _nextBgmPlayer = await FlameAudio.loop(newPath, volume: 0.0);

      // Start crossfade
      final totalSteps =
          (_crossfadeDuration.inMilliseconds / _fadeStepDuration.inMilliseconds)
              .round();
      int currentStep = 0;

      void updateVolumes() async {
        currentStep++;
        if (currentStep >= totalSteps) {
          _fadeTimer?.cancel();
          _fadeTimer = null;

          // Cleanup old player
          await _bgmPlayer?.stop();
          await _bgmPlayer?.dispose();

          // Switch to new player
          _bgmPlayer = _nextBgmPlayer;
          _nextBgmPlayer = null;
          _currentBGMVolume = volume;

          _isCrossfading = false;
          return;
        }

        // Calculate fade progress with smooth easing
        final progress = currentStep / totalSteps;
        final easedProgress = -0.5 * (cos(pi * progress) - 1);

        // Fade out current BGM
        if (_bgmPlayer != null) {
          final oldVolume = _currentBGMVolume * (1 - easedProgress);
          await _bgmPlayer?.setVolume(oldVolume);
        }

        // Fade in new BGM
        if (_nextBgmPlayer != null) {
          final newVolume = volume * easedProgress;
          await _nextBgmPlayer?.setVolume(newVolume);
        }
      }

      _fadeTimer?.cancel();
      _fadeTimer = Timer.periodic(_fadeStepDuration, (_) => updateVolumes());
    } catch (e) {
      debugPrint('Error during BGM crossfade: $e');
      _isCrossfading = false;

      // Cleanup on error
      await _nextBgmPlayer?.dispose();
      _nextBgmPlayer = null;
    }
  }

  /// Play BGM with crossfade
  @override
  Future<void> playBGM(String path, {double volume = 1.0}) async {
    if (_bgmPlayer != null) {
      // If we already have a BGM playing, crossfade to the new one
      await _crossfadeBGM(path,
          volume: _isDucking ? volume * _duckingVolume : volume);
    } else {
      // If no BGM is playing, start normally
      _bgmPlayer = await FlameAudio.loop(path,
          volume: _isDucking ? volume * _duckingVolume : volume);
      _currentBGMVolume = volume;
    }
  }
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
        SoundPaths.instance.getSoundPath(widget.category, widget.sound);
    if (path == null) return;

    // Store the path in the controller for later use
    await _controller.playSound(
      category: widget.category,
      sound: widget.sound,
      autoPlay: false, // Don't auto play yet
    );

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

    // Register BGM with its route
    if (widget.route != null || widget.global) {
      SoundManager.instance.registerBGM(
        _controller,
        route: widget.global ? 'global' : widget.route,
      );
    }

    // Only play if this is the current route's BGM
    if (widget.autoPlay &&
        (widget.global || widget.route == SoundManager.instance.currentRoute)) {
      await SoundManager.instance.playBGM(
        path,
        volume: widget.volume,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bgm) {
      return widget.child;
    }

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
