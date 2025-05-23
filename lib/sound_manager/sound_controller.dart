import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'sound_enums.dart';
import 'sound_paths.dart';

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
      final path = SoundPaths.instance.getSoundPath(category, sound);
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
}
