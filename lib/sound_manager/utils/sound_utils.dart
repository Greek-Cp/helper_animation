import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import '../bgm_manager.dart';

String relative(String full) => full.replaceFirst('assets/', '');

void logVol(double v) =>
    debugPrint('[BGM] 🔊 volume → ${v.toStringAsFixed(2)}');

Future<void> playOneShot(String absPath, {double volume = 1}) async {
  debugPrint('[SFX] 🎵 Playing one-shot: $absPath (volume: $volume)');

  try {
    // Duck BGM sebelum play SFX
    debugPrint('[SFX] 🎵 Calling duck start...');
    BgmManager.instance.duckStart();

    final rel = relative(absPath);

    // Try to create player with proper audio focus settings, fallback if not supported
    AudioPlayer? player;

    try {
      player = AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);

      // Try to set audio context to prevent taking audio focus from BGM
      await player.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none, // Tidak merebut audio focus
          ),
        ),
      );
      debugPrint('[SFX] 🎵 AudioPlayer created with audio context');
    } catch (e) {
      debugPrint('[SFX] 🎵 Audio context not supported, using FlameAudio: $e');
      // Fallback ke FlameAudio jika AudioContext tidak didukung
      try {
        final flamePlayer = await FlameAudio.play(rel, volume: volume)
            .timeout(const Duration(seconds: 5), onTimeout: () {
          debugPrint('[SFX] 🎵 FlameAudio timeout, restoring BGM');
          BgmManager.instance.duckEnd();
          throw TimeoutException('FlameAudio play timeout');
        });

        // Simplified restore logic untuk FlameAudio
        bool hasRestored = false;
        void restoreBgm() {
          if (!hasRestored) {
            hasRestored = true;
            debugPrint('[SFX] 🎵 Restoring BGM volume (FlameAudio)');
            BgmManager.instance.duckEnd();
          }
        }

        // Fallback timer untuk FlameAudio
        Timer(const Duration(milliseconds: 500), () {
          debugPrint('[SFX] 🎵 FlameAudio restore via timer');
          restoreBgm();
        });

        flamePlayer.onPlayerComplete.listen((_) {
          debugPrint('[SFX] 🎵 FlameAudio completed via listener');
          restoreBgm();
        });
        return;
      } catch (e) {
        debugPrint('[SFX] 🎵 ❌ FlameAudio error: $e');
        BgmManager.instance.duckEnd();
        return;
      }
    }

    if (player != null) {
      try {
        await player
            .setSource(AssetSource(rel))
            .timeout(const Duration(seconds: 5), onTimeout: () {
          debugPrint('[SFX] 🎵 Set source timeout');
          throw TimeoutException('Set source timeout');
        });

        await player.setVolume(volume);
        await player.resume();
        debugPrint('[SFX] 🎵 AudioPlayer started playing');

        // Ensure we have a reliable way to restore BGM volume
        bool hasRestored = false;
        Timer? fallbackTimer;
        StreamSubscription? subscription;

        void restoreBgm() {
          if (!hasRestored) {
            hasRestored = true;
            debugPrint('[SFX] 🎵 ✅ Restoring BGM volume');

            // Restore BGM dan pastikan masih playing
            BgmManager.instance.duckEnd();

            // Cleanup
            fallbackTimer?.cancel();
            subscription?.cancel();
            player?.dispose();
          } else {
            debugPrint('[SFX] 🎵 ⚠️ Restore already called, skipping');
          }
        }

        // 1) Listen for completion - primary mechanism
        subscription = player.onPlayerComplete.listen((_) {
          debugPrint('[SFX] 🎵 Audio completed via listener');
          restoreBgm();
        });

        // 2) Fallback timer dengan durasi yang lebih pendek
        try {
          final duration = await player
              .getDuration()
              .timeout(const Duration(seconds: 2), onTimeout: () {
            debugPrint('[SFX] 🎵 Get duration timeout');
            return const Duration(milliseconds: 400);
          });

          if (duration != null && duration.inMilliseconds > 0) {
            // Gunakan durasi aktual + buffer 100ms
            final fallbackDuration = duration.inMilliseconds + 100;
            debugPrint(
                '[SFX] 🎵 Setting fallback timer: ${fallbackDuration}ms');

            fallbackTimer = Timer(Duration(milliseconds: fallbackDuration), () {
              debugPrint('[SFX] 🎵 Audio completed via fallback timer');
              restoreBgm();
            });
          } else {
            // Fallback untuk SFX pendek
            debugPrint('[SFX] 🎵 Using default fallback timer: 400ms');
            fallbackTimer = Timer(const Duration(milliseconds: 400), () {
              debugPrint('[SFX] 🎵 Audio completed via default fallback');
              restoreBgm();
            });
          }
        } catch (e) {
          debugPrint('[SFX] 🎵 Error getting duration: $e');
          // Fallback timer
          fallbackTimer = Timer(const Duration(milliseconds: 400), () {
            debugPrint('[SFX] 🎵 Audio completed via error fallback');
            restoreBgm();
          });
        }
      } catch (e) {
        debugPrint('[SFX] 🎵 ❌ Error playing sound: $e');
        BgmManager.instance.duckEnd();
        player.dispose();
      }
    }
  } catch (e) {
    debugPrint('[SFX] 🎵 ❌ Error playing sound: $e');
    // Pastikan BGM di-restore meski ada error
    BgmManager.instance.duckEnd();
  }
}
