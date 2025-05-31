/// Enum for background music files
enum BgmSound {
  childrenLearning('children_learning.m4a'),
  cozyLofiFireside('cozy lofi fireside short 30.m4a'),
  curiousSituation('curious_situation.m4a'),
  curious('curious.m4a'),
  birdsSinging('mixkit-little-birds-singing-in-the-trees-17.wav'),
  fluteNotification('mixkit-melodical-flute-music-notification-2310.wav');

  const BgmSound(this.fileName);
  final String fileName;
}

/// Enum for click sound files
enum ClickSound {
  gameClick('mixkit-game-click-1114.wav'),
  selectClick('mixkit-select-click-1109.wav');

  const ClickSound(this.fileName);
  final String fileName;
}

/// Enum for sound effect files (placeholder for future SFX files)
enum SfxSound {
  // Add your SFX files here when available
  // example: explosion('explosion.wav');

  // Placeholder - remove when actual SFX files are added
  placeholder('placeholder.wav');

  const SfxSound(this.fileName);
  final String fileName;
}

/// Enum for notification sound files (placeholder for future notification files)
enum NotificationSound {
  // Add your notification files here when available
  // example: success('success.wav');

  // Placeholder - remove when actual notification files are added
  placeholder('placeholder.wav');

  const NotificationSound(this.fileName);
  final String fileName;
}