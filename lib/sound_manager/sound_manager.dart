import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';

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
  final AudioPlayer _player;
  bool _autoPlay;
  double _volume;
  bool _loop;
  String? _currentPath;
  dynamic _currentSound;
  SoundCategory? _currentCategory;
  final StreamController<String> _soundStateController =
      StreamController<String>.broadcast();

  Stream<String> get soundState => _soundStateController.stream;

  SoundController({
    bool autoPlay = false,
    double volume = 1.0,
    bool loop = false,
  })  : _player = AudioPlayer(),
        _autoPlay = autoPlay,
        _volume = volume,
        _loop = loop {
    _player.setVolume(_volume);
  }

  /// Play a sound from a specific category and type
  Future<void> playSound({
    required SoundCategory category,
    required dynamic sound,
    bool? autoPlay,
    double? volume,
    bool? loop,
  }) async {
    try {
      String? path = _getSoundPath(category, sound);
      if (path == null) return;

      // Update settings if provided
      if (volume != null) {
        _volume = volume;
        await _player.setVolume(_volume);
      }

      if (loop != null) {
        _loop = loop;
        await _player.setLoopMode(_loop ? LoopMode.one : LoopMode.off);
      }

      // Store current sound info
      _currentPath = path;
      _currentSound = sound;
      _currentCategory = category;

      // Load and play
      await _player.setAsset(path);

      if (autoPlay ?? _autoPlay) {
        await _player.play();
        _soundStateController.add('playing');
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
      _soundStateController.add('error: $e');
    }
  }

  /// Get sound file path from category and sound type
  String? _getSoundPath(SoundCategory category, dynamic sound) {
    try {
      switch (category) {
        case SoundCategory.clickEvent:
          if (sound is ClickSound) {
            return SoundManager.instance.clickSoundPaths[sound];
          }
          break;
        case SoundCategory.bgm:
          if (sound is BGMSound) {
            return SoundManager.instance.bgmSoundPaths[sound];
          }
          break;
        case SoundCategory.sfx:
          if (sound is SFXSound) {
            return SoundManager.instance.sfxSoundPaths[sound];
          }
          break;
        case SoundCategory.notification:
          if (sound is NotificationSound) {
            return SoundManager.instance.notificationSoundPaths[sound];
          }
          break;
      }
    } catch (e) {
      debugPrint('Error getting sound path: $e');
    }
    return null;
  }

  /// Play the current loaded sound
  Future<void> play() async {
    try {
      await _player.play();
      _soundStateController.add('playing');
    } catch (e) {
      debugPrint('Error playing sound: $e');
      _soundStateController.add('error: $e');
    }
  }

  /// Pause the current sound
  Future<void> pause() async {
    try {
      await _player.pause();
      _soundStateController.add('paused');
    } catch (e) {
      debugPrint('Error pausing sound: $e');
    }
  }

  /// Stop the current sound
  Future<void> stop() async {
    try {
      await _player.stop();
      _soundStateController.add('stopped');
    } catch (e) {
      debugPrint('Error stopping sound: $e');
    }
  }

  /// Set the volume
  Future<void> setVolume(double volume) async {
    try {
      _volume = volume.clamp(0.0, 1.0);
      await _player.setVolume(_volume);
      _soundStateController.add('volume_changed');
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  /// Set if sound should loop
  Future<void> setLoop(bool loop) async {
    try {
      _loop = loop;
      await _player.setLoopMode(_loop ? LoopMode.one : LoopMode.off);
      _soundStateController.add('loop_changed');
    } catch (e) {
      debugPrint('Error setting loop: $e');
    }
  }

  /// Set if sound should autoplay
  void setAutoPlay(bool autoPlay) {
    _autoPlay = autoPlay;
    _soundStateController.add('autoplay_changed');
  }

  /// Replay the current sound
  Future<void> replay() async {
    try {
      await _player.seek(Duration.zero);
      await _player.play();
      _soundStateController.add('replaying');
    } catch (e) {
      debugPrint('Error replaying sound: $e');
    }
  }

  /// Dispose the controller and free resources
  Future<void> dispose() async {
    try {
      await _player.dispose();
      await _soundStateController.close();
    } catch (e) {
      debugPrint('Error disposing sound controller: $e');
    }
  }

  /// Check if sound is playing
  bool get isPlaying => _player.playing;

  /// Get current volume
  double get volume => _volume;

  /// Get current autoplay setting
  bool get autoPlay => _autoPlay;

  /// Get current loop setting
  bool get loop => _loop;

  /// Get current sound path
  String? get currentPath => _currentPath;

  /// Get current sound
  dynamic get currentSound => _currentSound;

  /// Get current category
  SoundCategory? get currentCategory => _currentCategory;
}

/// Global sound manager to handle all audio across the app
class SoundManager {
  // Singleton pattern
  static final SoundManager instance = SoundManager._internal();
  factory SoundManager() => instance;
  SoundManager._internal();

  // Map asset paths for each sound enum
  final Map<ClickSound, String> clickSoundPaths = {
    ClickSound.gameClick: 'assets/sounds/click/mixkit-game-click-1114.wav',
    ClickSound.selectClick: 'assets/sounds/click/mixkit-select-click-1109.wav',
  };

  final Map<BGMSound, String> bgmSoundPaths = {
    BGMSound.birdsSinging:
        'assets/sounds/bgm/mixkit-little-birds-singing-in-the-trees-17.wav',
    BGMSound.fluteMusic:
        'assets/sounds/bgm/mixkit-melodical-flute-music-notification-2310.wav',
  };

  final Map<SFXSound, String> sfxSoundPaths = {
    SFXSound.airWoosh: 'assets/sounds/sfx/mixkit-air-woosh-1489.wav',
  };

  final Map<NotificationSound, String> notificationSoundPaths = {
    NotificationSound.retroArcade:
        'assets/sounds/notification/mixkit-retro-arcade-casino-notification-211.wav',
    NotificationSound.mysteryAlert:
        'assets/sounds/notification/mixkit-video-game-mystery-alert-234.wav',
  };

  // Store all active widget sound controllers
  final Map<Key, _WidgetSoundData> _widgetSoundControllers = {};

  // Store global BGM controllers for different routes
  final Map<String, SoundController> _globalBGMControllers = {};

  // Current active route
  String _currentRoute = '/';

  // General settings
  bool _isMuted = false;
  double _masterVolume = 1.0;

  /// Register a widget sound controller
  void registerWidgetSound(Key key, _WidgetSoundData data) {
    _widgetSoundControllers[key] = data;
  }

  /// Unregister a widget sound controller
  Future<void> unregisterWidgetSound(Key key) async {
    if (_widgetSoundControllers.containsKey(key)) {
      final data = _widgetSoundControllers[key]!;
      if (!data.isExternalController) {
        await data.controller.dispose();
      }
      _widgetSoundControllers.remove(key);
    }
  }

  /// Set current route and handle BGM accordingly
  Future<void> setCurrentRoute(String route) async {
    _currentRoute = route;

    // Stop all route-specific BGMs that aren't for this route
    for (final entry in _globalBGMControllers.entries) {
      if (entry.key != route && entry.key != 'global') {
        await entry.value.pause();
      }
    }

    // Play the appropriate BGM for this route
    if (_globalBGMControllers.containsKey(route)) {
      await _globalBGMControllers[route]!.play();
    } else if (_globalBGMControllers.containsKey('global')) {
      await _globalBGMControllers['global']!.play();
    }
  }

  /// Register a global BGM for a specific route
  void registerGlobalBGM(SoundController controller,
      {String route = 'global'}) {
    _globalBGMControllers[route] = controller;

    // If we're on this route, play it immediately
    if (route == 'global' || route == _currentRoute) {
      controller.play();
    }
  }

  /// Unregister a global BGM
  Future<void> unregisterGlobalBGM({String route = 'global'}) async {
    if (_globalBGMControllers.containsKey(route)) {
      await _globalBGMControllers[route]!.dispose();
      _globalBGMControllers.remove(route);
    }
  }

  /// Set master volume
  Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume.clamp(0.0, 1.0);

    // Update all active controllers
    for (final data in _widgetSoundControllers.values) {
      await data.controller.setVolume(data.controller.volume * _masterVolume);
    }

    for (final controller in _globalBGMControllers.values) {
      await controller.setVolume(controller.volume * _masterVolume);
    }
  }

  /// Mute/unmute all sounds
  Future<void> setMuted(bool muted) async {
    _isMuted = muted;

    for (final data in _widgetSoundControllers.values) {
      if (_isMuted) {
        await data.controller.setVolume(0);
      } else {
        await data.controller.setVolume(data.controller.volume);
      }
    }

    for (final controller in _globalBGMControllers.values) {
      if (_isMuted) {
        await controller.setVolume(0);
      } else {
        await controller.setVolume(controller.volume);
      }
    }
  }

  /// Dispose all controllers
  Future<void> disposeAll() async {
    // Dispose all widget sound controllers that we own
    for (final data in _widgetSoundControllers.values) {
      if (!data.isExternalController) {
        await data.controller.dispose();
      }
    }
    _widgetSoundControllers.clear();

    // Dispose all global BGM controllers
    for (final controller in _globalBGMControllers.values) {
      await controller.dispose();
    }
    _globalBGMControllers.clear();
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
    return _SoundWidget(
      child: this,
      category: SoundCategory.bgm,
      sound: sound,
      externalController: controller,
      volume: volume,
      autoPlay: autoPlay,
      loop: loop,
      widgetKey: key ?? UniqueKey(),
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

  void _setupBGM() {
    // Load the BGM
    _controller.playSound(
      category: widget.category,
      sound: widget.sound,
      autoPlay: widget.autoPlay,
      volume: widget.volume,
      loop: widget.loop,
    );

    // If it's a global BGM, register it
    if (widget.global) {
      final route = widget.route ??
          (widget.global ? 'global' : SoundManager.instance.currentRoute);
      SoundManager.instance.registerGlobalBGM(_controller, route: route);
    } else {
      // Otherwise just register as a normal widget sound
      SoundManager.instance.registerWidgetSound(
        widget.widgetKey,
        _WidgetSoundData(
          controller: _controller,
          isExternalController: _isExternalController,
          category: widget.category,
          sound: widget.sound,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // For BGM, just return the child as-is since there's no interaction needed
    if (widget.bgm) {
      return widget.child;
    }

    // For regular sound, wrap in a GestureDetector
    return GestureDetector(
      onTap: () {
        if (!_controller.isPlaying || !widget.loop) {
          _controller.playSound(
            category: widget.category,
            sound: widget.sound,
            autoPlay: true,
          );
        }
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    // Unregister from the sound manager
    SoundManager.instance.unregisterWidgetSound(widget.widgetKey);

    // If we're not using an external controller, dispose ours
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
