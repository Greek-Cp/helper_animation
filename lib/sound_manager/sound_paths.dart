import 'package:flutter/widgets.dart';

import 'sound_enums.dart';

const _assetPrefix = '';

/// Class to manage sound asset paths
/// Class to manage sound asset paths
class SoundPaths {
  SoundPaths._(); // singleton
  static final instance = SoundPaths._();

  static const _packageName = 'helper_animation';
  static const _root = 'assets/sounds/'; // Keep simple path

  final bgmSoundPaths = <BGMSound, String>{
    BGMSound.birdsSinging: '${_root}bgm/children_learning.m4a',
    BGMSound.fluteMusic: '${_root}bgm/cozy_lofi_fireside_short_30.m4a',
  };

  final clickSoundPaths = <ClickSound, String>{
    ClickSound.gameClick: '${_root}click/mixkit-game-click-1114.wav',
    ClickSound.selectClick: '${_root}click/mixkit-select-click-1109.wav',
  };

  final sfxSoundPaths = <SFXSound, String>{
    SFXSound.airWoosh: '${_root}sfx/mixkit-air-woosh-1489.wav',
  };

  final notificationSoundPaths = <NotificationSound, String>{
    NotificationSound.retroArcade:
        '${_root}notification/mixkit-retro-arcade-casino-notification-211.wav',
    NotificationSound.mysteryAlert:
        '${_root}notification/mixkit-video-game-mystery-alert-234.wav',
  };

  String? getSoundPath(SoundCategory cat, dynamic sound) {
    switch (cat) {
      case SoundCategory.clickEvent:
        return clickSoundPaths[sound];
      case SoundCategory.bgm:
        return bgmSoundPaths[sound];
      case SoundCategory.sfx:
        return sfxSoundPaths[sound];
      case SoundCategory.notification:
        return notificationSoundPaths[sound];
    }
  }

  // ==================== KEY FIX: Unified Path Methods ====================

  /// For FlameAudio - remove assets/ prefix, add package prefix via FlameAudio.prefix
  List<String> getAllRelativePaths() => [
        ...bgmSoundPaths.values.map((path) => path.replaceFirst('assets/', '')),
        ...clickSoundPaths.values
            .map((path) => path.replaceFirst('assets/', '')),
        ...sfxSoundPaths.values.map((path) => path.replaceFirst('assets/', '')),
        ...notificationSoundPaths.values
            .map((path) => path.replaceFirst('assets/', '')),
      ];

  /// For AudioPlayer - full package path
  String getAudioPlayerPath(String originalPath) {
    return 'packages/$_packageName/$originalPath';
  }

  /// For AudioPlayer AssetSource - remove packages prefix
  String getAssetSourcePath(String originalPath) {
    final fullPath = 'packages/$_packageName/$originalPath';
    return fullPath; // AssetSource will handle the packages prefix
  }

  /// Debug method
  void debugAllPaths() {
    debugPrint(
        '[PATH DEBUG] ==================== PATH DEBUG ====================');
    final relativePaths = getAllRelativePaths();

    for (int i = 0; i < relativePaths.length && i < 3; i++) {
      final relPath = relativePaths[i];
      final originalPath = bgmSoundPaths.values.toList()[i];
      debugPrint('[PATH DEBUG] Original: $originalPath');
      debugPrint(
          '[PATH DEBUG] FlameAudio: packages/$_packageName/assets/$relPath');
      debugPrint(
          '[PATH DEBUG] AudioPlayer: ${getAudioPlayerPath(originalPath)}');
      debugPrint(
          '[PATH DEBUG] AssetSource: ${getAssetSourcePath(originalPath)}');
      debugPrint('[PATH DEBUG] ---');
    }
    debugPrint('[PATH DEBUG] ================================================');
  }
}
