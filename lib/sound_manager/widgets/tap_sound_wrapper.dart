import 'package:flutter/material.dart';
import '../utils/sound_utils.dart';

class TapSoundWrapper extends StatefulWidget {
  final String path;
  final Widget child;
  final double volume;

  const TapSoundWrapper({
    super.key,
    required this.path,
    required this.child,
    this.volume = 1.0,
  });

  @override
  State<TapSoundWrapper> createState() => _TapSoundWrapperState();
}

class _TapSoundWrapperState extends State<TapSoundWrapper> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => playOneShot(widget.path, volume: widget.volume),
      onTap: () => playOneShot(widget.path, volume: widget.volume),
      child: widget.child,
    );
  }
}
