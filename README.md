# Helper Animation

A simple animation helper library for Flutter widgets with integrated sound management.

## Features

- 🎵 **Sound Management**: Complete audio system with background music, sound effects, click sounds, and notifications
- 🎛️ **Volume Controls**: Individual volume controls for different sound categories
- 📦 **Asset Management**: Automatic handling of package assets
- 🔄 **Preloading**: Sound preloading for better performance
- 🎯 **Easy Integration**: Simple singleton pattern for easy access

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  helper_animation: ^0.1.2
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Setup

```dart
import 'package:helper_animation/helper_animation.dart';

// Get the sound manager instance
final soundManager = SoundManager();
```

### Playing Background Music

```dart
// Play background music (loops by default)
await soundManager.playBgm('your_music.mp3');

// Play background music without looping
await soundManager.playBgm('your_music.mp3', loop: false);

// Control BGM playback
await soundManager.pauseBgm();
await soundManager.resumeBgm();
await soundManager.stopBgm();

// Check current playing BGM
String? currentBgm = soundManager.currentBgm;
```

### Playing Sound Effects

```dart
// Play sound effects
await soundManager.playSfx('explosion.wav');
await soundManager.playSfx('powerup.wav');
```

### Playing Click Sounds

```dart
// Play click sounds for UI interactions
await soundManager.playClick('button_click.wav');
await soundManager.playClick('menu_select.wav');
```

### Playing Notification Sounds

```dart
// Play notification sounds
await soundManager.playNotification('success.wav');
await soundManager.playNotification('error.wav');
```

### Volume Controls

```dart
// Set individual volumes (0.0 to 1.0)
soundManager.setBgmVolume(0.8);
soundManager.setSfxVolume(0.6);
soundManager.setClickVolume(0.4);
soundManager.setNotificationVolume(0.7);

// Set master volume (affects all categories)
soundManager.setMasterVolume(0.5);

// Get current volumes
double bgmVol = soundManager.bgmVolume;
double sfxVol = soundManager.sfxVolume;
```

### Performance Optimization

```dart
// Preload sounds for better performance
await soundManager.preloadBgm('background_music.mp3');
await soundManager.preloadSfx('explosion.wav');
await soundManager.preloadClick('button_click.wav');
await soundManager.preloadNotification('success.wav');

// Clear audio cache when needed
await soundManager.clearCache();
```

### Utility Functions

```dart
// Stop all currently playing sounds
await soundManager.stopAllSounds();
```

## Asset Structure

Organize your audio files in the following structure within your library:

```
assets/
└── sounds/
    ├── bgm/              # Background music files
    │   ├── menu_music.mp3
    │   └── game_music.mp3
    ├── sfx/              # Sound effects
    │   ├── explosion.wav
    │   ├── powerup.wav
    │   └── coin.wav
    ├── click/            # UI click sounds
    │   ├── button_click.wav
    │   ├── menu_select.wav
    │   └── tap.wav
    └── notification/     # Notification sounds
        ├── success.wav
        ├── error.wav
        └── alert.wav
```

## Supported Audio Formats

- MP3
- WAV
- OGG
- M4A

## Example

Check out the example app in the `example/` directory for a complete demonstration of all features.

```dart
import 'package:flutter/material.dart';
import 'package:helper_animation/helper_animation.dart';

class MyApp extends StatelessWidget {
  final soundManager = SoundManager();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Sound Demo')),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () => soundManager.playBgm('background.mp3'),
                child: Text('Play Background Music'),
              ),
              ElevatedButton(
                onPressed: () => soundManager.playSfx('explosion.wav'),
                child: Text('Play Explosion'),
              ),
              ElevatedButton(
                onPressed: () => soundManager.playClick('button.wav'),
                child: Text('Play Click Sound'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Package Assets

The sound manager automatically handles package asset paths. When you call:

```dart
soundManager.playBgm('music.mp3');
```

It automatically resolves to:

```
packages/helper_animation/assets/sounds/bgm/music.mp3
```

## Error Handling

The sound manager includes built-in error handling and will print helpful error messages to the console if audio files are not found or cannot be played.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.