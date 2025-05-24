import 'sound_enums.dart';

const _assetPrefix = 'packages/helper_animation/';

/// Class to manage sound asset paths
class SoundPaths {
  // Singleton pattern
  static final SoundPaths instance = SoundPaths._internal();
  factory SoundPaths() => instance;
  SoundPaths._internal();

  // Map asset paths for each sound enum
  final Map<ClickSound, String> clickSoundPaths = {
    ClickSound.gameClick:
        '${_assetPrefix}assets/sounds/click/mixkit-game-click-1114.wav',
    ClickSound.selectClick:
        '${_assetPrefix}assets/sounds/click/mixkit-select-click-1109.wav',
  };

  final Map<BGMSound, String> bgmSoundPaths = {
    BGMSound.birdsSinging:
        '${_assetPrefix}assets/sounds/bgm/children_learning.m4a',
    BGMSound.fluteMusic:
        '${_assetPrefix}assets/sounds/bgm/cozy lofi fireside short 30.m4a',
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

  /// Get the sound path for a given category and sound
  String? getSoundPath(SoundCategory category, dynamic sound) {
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

  /// Get all sound paths for preloading
  List<String> getAllSoundPaths() {
    return [
      ...clickSoundPaths.values,
      ...bgmSoundPaths.values,
      ...sfxSoundPaths.values,
      ...notificationSoundPaths.values,
    ];
  }
}
