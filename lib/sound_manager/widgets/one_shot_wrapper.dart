import 'package:flutter/material.dart';
import '../utils/sound_utils.dart';

class OneShotOnInitWrapper extends StatefulWidget {
  final Widget child;
  final String path;
  final double volume;

  const OneShotOnInitWrapper({
    super.key,
    required this.child,
    required this.path,
    this.volume = 1.0,
  });

  @override
  State<OneShotOnInitWrapper> createState() => _OneShotOnInitWrapperState();
}

class _OneShotOnInitWrapperState extends State<OneShotOnInitWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      playOneShot(widget.path, volume: widget.volume);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
