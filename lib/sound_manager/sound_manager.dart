import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'sound_enums.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal() {
    // Set empty prefix for FlameAudio to handle package assets correctly
    FlameAudio.audioCache.prefix = '';
  }

  // Volume controls
  double _bgmVolume = 1.0;
  double _sfxVolume = 1.0;
  double _clickVolume = 1.0;
  double _notificationVolume = 1.0;

  // Current playing BGM
  String? _currentBgm;

  // Getters for volumes
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;
  double get clickVolume => _clickVolume;
  double get notificationVolume => _notificationVolume;

  // Set volumes
  void setBgmVolume(double volume) {
    _bgmVolume = volume.clamp(0.0, 1.0);
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }

  void setClickVolume(double volume) {
    _clickVolume = volume.clamp(0.0, 1.0);
  }

  void setNotificationVolume(double volume) {
    _notificationVolume = volume.clamp(0.0, 1.0);
  }

  void setMasterVolume(double volume) {
    final clampedVolume = volume.clamp(0.0, 1.0);
    setBgmVolume(clampedVolume);
    setSfxVolume(clampedVolume);
    setClickVolume(clampedVolume);
    setNotificationVolume(clampedVolume);
  }

  // BGM Methods
  Future<void> playBgm(String fileName, {bool loop = true}) async {
    try {
      await stopBgm();
      final path = 'packages/helper_animation/assets/sounds/bgm/$fileName';
      if (loop) {
        await FlameAudio.bgm.play(path, volume: _bgmVolume);
      } else {
        await FlameAudio.play(path, volume: _bgmVolume);
      }
      _currentBgm = fileName;
    } catch (e) {
      print('Error playing BGM: $e');
    }
  }

  // BGM Methods with Enum
  Future<void> playBgmFromEnum(BgmSound bgmSound, {bool loop = true}) async {
    await playBgm(bgmSound.fileName, loop: loop);
  }

  Future<void> pauseBgm() async {
    try {
      await FlameAudio.bgm.pause();
    } catch (e) {
      print('Error pausing BGM: $e');
    }
  }

  Future<void> resumeBgm() async {
    try {
      await FlameAudio.bgm.resume();
    } catch (e) {
      print('Error resuming BGM: $e');
    }
  }

  Future<void> stopBgm() async {
    try {
      await FlameAudio.bgm.stop();
      _currentBgm = null;
    } catch (e) {
      print('Error stopping BGM: $e');
    }
  }

  String? get currentBgm => _currentBgm;

  // SFX Methods
  Future<void> playSfx(String fileName) async {
    try {
      final path = 'packages/helper_animation/assets/sounds/sfx/$fileName';
      await FlameAudio.play(path, volume: _sfxVolume);
    } catch (e) {
      print('Error playing SFX: $e');
    }
  }

  // SFX Methods with Enum
  Future<void> playSfxFromEnum(SfxSound sfxSound) async {
    await playSfx(sfxSound.fileName);
  }

  // Click Sound Methods
  Future<void> playClick(String fileName) async {
    try {
      final path = 'packages/helper_animation/assets/sounds/click/$fileName';
      await FlameAudio.play(path, volume: _clickVolume);
    } catch (e) {
      print('Error playing click sound: $e');
    }
  }

  // Click Sound Methods with Enum
  Future<void> playClickFromEnum(ClickSound clickSound) async {
    await playClick(clickSound.fileName);
  }

  // Notification Sound Methods
  Future<void> playNotification(String fileName) async {
    try {
      final path =
          'packages/helper_animation/assets/sounds/notification/$fileName';
      await FlameAudio.play(path, volume: _notificationVolume);
    } catch (e) {
      print('Error playing notification sound: $e');
    }
  }

  // Notification Sound Methods with Enum
  Future<void> playNotificationFromEnum(
      NotificationSound notificationSound) async {
    await playNotification(notificationSound.fileName);
  }

  // Utility Methods
  Future<void> stopAllSounds() async {
    try {
      await FlameAudio.bgm.stop();
      // Note: FlameAudio doesn't have a direct way to stop all SFX
      // Individual SFX sounds will stop naturally when they finish
      _currentBgm = null;
    } catch (e) {
      print('Error stopping all sounds: $e');
    }
  }

  // Preload sounds for better performance
  Future<void> preloadBgm(String fileName) async {
    try {
      final path = 'packages/helper_animation/assets/sounds/bgm/$fileName';
      await FlameAudio.audioCache.load(path);
    } catch (e) {
      print('Error preloading BGM: $e');
    }
  }

  Future<void> preloadSfx(String fileName) async {
    try {
      final path = 'packages/helper_animation/assets/sounds/sfx/$fileName';
      await FlameAudio.audioCache.load(path);
    } catch (e) {
      print('Error preloading SFX: $e');
    }
  }

  Future<void> preloadClick(String fileName) async {
    try {
      final path = 'packages/helper_animation/assets/sounds/click/$fileName';
      await FlameAudio.audioCache.load(path);
    } catch (e) {
      print('Error preloading click sound: $e');
    }
  }

  Future<void> preloadNotification(String fileName) async {
    try {
      final path =
          'packages/helper_animation/assets/sounds/notification/$fileName';
      await FlameAudio.audioCache.load(path);
    } catch (e) {
      print('Error preloading notification sound: $e');
    }
  }

  // Preload sounds with Enum
  Future<void> preloadBgmFromEnum(BgmSound bgmSound) async {
    await preloadBgm(bgmSound.fileName);
  }

  Future<void> preloadSfxFromEnum(SfxSound sfxSound) async {
    await preloadSfx(sfxSound.fileName);
  }

  Future<void> preloadClickFromEnum(ClickSound clickSound) async {
    await preloadClick(clickSound.fileName);
  }

  Future<void> preloadNotificationFromEnum(
      NotificationSound notificationSound) async {
    await preloadNotification(notificationSound.fileName);
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      FlameAudio.audioCache.clearAll();
    } catch (e) {
      print('Error clearing audio cache: $e');
    }
  }
}
