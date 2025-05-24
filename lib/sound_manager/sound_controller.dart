import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'sound_enums.dart';
import 'sound_paths.dart';

const String _LOG_TAG = "🎵 SOUND_LIBRARY";

void _log(String message) {
  debugPrint('$_LOG_TAG: $message');
}

void _logError(String message, dynamic error, [StackTrace? stackTrace]) {
  debugPrint('$_LOG_TAG ❌ ERROR: $message');
  debugPrint('$_LOG_TAG ❌ Details: $error');
  if (stackTrace != null) {
    debugPrint('$_LOG_TAG ❌ Stack trace:');
    debugPrint(stackTrace
        .toString()
        .split('\n')
        .map((line) => '$_LOG_TAG ❌ $line')
        .join('\n'));
  }
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
        _loop = loop {
    try {
      _log(
          'SoundController created (autoPlay: $autoPlay, volume: $volume, loop: $loop)');
    } catch (e, stackTrace) {
      _logError('Error creating SoundController', e, stackTrace);
    }
  }

  /* ─────────────────────── PLAY SOUND ─────────────────────── */

  Future<void> playSound({
    required SoundCategory category,
    required dynamic sound,
    bool? autoPlay,
    double? volume,
    bool? loop,
  }) async {
    try {
      final path = SoundPaths.instance.getSoundPath(category, sound);
      if (path == null) {
        _logError('Invalid sound path', 'Category: $category, Sound: $sound');
        return;
      }

      _log('Playing sound: $path (category: $category)');
      if (volume != null) _volume = volume;
      if (loop != null) _loop = loop;

      _currentPath = path;
      _currentSound = sound;
      _currentCategory = category;

      if (category == SoundCategory.bgm) {
        await _handleBGMPlayback(path, autoPlay ?? _autoPlay);
      } else {
        await _handleSFXPlayback(path);
      }
    } catch (e, stackTrace) {
      _logError('Error playing sound', e, stackTrace);
      _state.add('error:$e');
      await _cleanup();
    }
  }

  Future<void> _handleBGMPlayback(String path, bool shouldPlay) async {
    try {
      _log('Playing BGM: $path');
      await FlameAudio.bgm.stop();
      await FlameAudio.bgm.play(path, volume: _volume);
      _isPlaying = true;

      if (!shouldPlay) {
        _log('Auto-pausing BGM (autoPlay: false)');
        await FlameAudio.bgm.pause();
        _isPlaying = false;
      }
      _state.add('playing');
    } catch (e, stackTrace) {
      _logError('Error in BGM playback', e, stackTrace);
      throw e; // Rethrow to be handled by caller
    }
  }

  Future<void> _handleSFXPlayback(String path) async {
    try {
      _log('Playing SFX: $path');
      _isPlaying = true;
      _state.add('playing');

      if (_loop) {
        _log('Starting loop playback');
        _player = await FlameAudio.loop(path, volume: _volume);
      } else {
        _log('Starting single playback');
        _player = await FlameAudio.play(path, volume: _volume);
        _player?.onPlayerComplete.listen((_) {
          _log('Playback completed');
          _isPlaying = false;
          _state.add('completed');
        });
      }
    } catch (e, stackTrace) {
      _logError('Error in SFX playback', e, stackTrace);
      throw e;
    }
  }

  Future<void> _cleanup() async {
    try {
      _log('Cleaning up after error');
      await _player?.stop();
      await _player?.dispose();
      _player = null;
      _isPlaying = false;
    } catch (e, stackTrace) {
      _logError('Error during cleanup', e, stackTrace);
    }
  }

  /* ───────────── GENERIC CONTROLS (play/pause/…) ──────────── */

  Future<void> play() async {
    try {
      _log('Resuming playback');
      if (_currentCategory == SoundCategory.bgm) {
        await FlameAudio.bgm.resume();
      } else {
        await _player?.resume();
      }
      _isPlaying = true;
      _state.add('playing');
    } catch (e, stackTrace) {
      _logError('Error resuming playback', e, stackTrace);
    }
  }

  Future<void> pause() async {
    try {
      _log('Pausing playback');
      if (_currentCategory == SoundCategory.bgm) {
        await FlameAudio.bgm.pause();
      } else {
        await _player?.pause();
      }
      _isPlaying = false;
      _state.add('paused');
    } catch (e, stackTrace) {
      _logError('Error pausing playback', e, stackTrace);
    }
  }

  Future<void> stop() async {
    try {
      _log('Stopping playback');
      if (_currentCategory == SoundCategory.bgm) {
        await FlameAudio.bgm.stop();
      } else {
        await _player?.stop();
      }
      _isPlaying = false;
      _state.add('stopped');
    } catch (e, stackTrace) {
      _logError('Error stopping playback', e, stackTrace);
    }
  }

  /* ──────────────────── setVolume / setLoop ───────────────── */

  Future<void> setVolume(double v) async {
    try {
      _volume = v.clamp(0.0, 1.0);
      _log('Setting volume: $_volume');

      if (_currentCategory == SoundCategory.bgm) {
        if (_isPlaying) {
          await FlameAudio.bgm.play(_currentPath!, volume: _volume);
          _log('Applied volume to BGM: $_volume');
        }
      } else {
        await _player?.setVolume(_volume);
        _log('Applied volume to SFX: $_volume');
      }
      _state.add('volume_changed');
    } catch (e, stackTrace) {
      _logError('Error setting volume', e, stackTrace);
    }
  }

  Future<void> setLoop(bool loop) async {
    _log('Setting loop: $loop');
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
    _log('Recreating player with new loop setting');
    await _player?.stop();
    await _player?.dispose();
    _player = _loop
        ? await FlameAudio.loop(_currentPath!, volume: _volume)
        : await FlameAudio.play(_currentPath!, volume: _volume);

    _state.add('loop_changed');
  }

  void setAutoPlay(bool auto) {
    _log('Setting autoPlay: $auto');
    _autoPlay = auto;
    _state.add('autoplay_changed');
  }

  Future<void> replay() async {
    _log('Replaying sound');
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
    try {
      _log('Disposing sound controller');
      _isPlaying = false;
      await _player?.dispose();
      await _state.close();
      if (_currentCategory == SoundCategory.bgm) {
        await FlameAudio.bgm.stop();
      }
    } catch (e, stackTrace) {
      _logError('Error disposing sound controller', e, stackTrace);
    }
  }

  /* ───────────────────────── GETTERS ───────────────────────── */

  bool get isPlaying => _isPlaying;
  double get volume => _volume;
  bool get autoPlay => _autoPlay;
  bool get loop => _loop;
  String? get currentPath => _currentPath;
  dynamic get currentSound => _currentSound;
  SoundCategory? get currentCategory => _currentCategory;
}
