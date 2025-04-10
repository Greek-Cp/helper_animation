import '../factory/animator_factory.dart';
import '../animators/effect_animator.dart';
import '../constants/enums.dart';
import '../painters/effect_painter.dart';
import '../utils/position_calculator.dart';
import 'package:flutter/material.dart';

// Controller class untuk mentrigger animasi dari luar
class EffectAnimationController {
  VoidCallback? _startAnimationCallback;

  // Method untuk mentrigger animasi
  void triggerAnimation() {
    if (_startAnimationCallback != null) {
      _startAnimationCallback!();
    }
  }

  // Method internal untuk mengeset callback
  void _setCallback(VoidCallback callback) {
    _startAnimationCallback = callback;
  }
}

class EffectAnimation extends StatefulWidget {
  final Widget child;
  final Color effectColor;
  final Duration duration;
  final bool repeatWhenDrag;
  final bool autoAnimate;
  final AnimationType animationType;
  final double?
      radiusMultiplier; // Jarak/ukuran animasi relatif terhadap widget
  final AnimationPosition position; // Posisi animasi relatif terhadap widget
  final Offset? customOffset; // Untuk override posisi jika diperlukan
  final EffectAnimationController? controller; // Controller baru
  final bool touchEnabled; // Flag untuk mengaktifkan/menonaktifkan respons tap

  const EffectAnimation({
    Key? key,
    required this.child,
    this.effectColor = const Color(0xFF8BB3C5),
    this.duration = const Duration(milliseconds: 2400),
    this.repeatWhenDrag = true,
    this.autoAnimate = false,
    this.animationType = AnimationType.firework,
    this.radiusMultiplier,
    this.position = AnimationPosition.outside,
    this.customOffset,
    this.controller,
    this.touchEnabled = true, // Default-nya aktif
  }) : super(key: key);

  @override
  State<EffectAnimation> createState() => _EffectAnimationState();
}

class _EffectAnimationState extends State<EffectAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final GlobalKey _widgetKey = GlobalKey();
  bool _isAnimating = false;
  Size _childSize = Size.zero;
  bool _isDragging = false;
  late EffectAnimator _animator;

  @override
  void initState() {
    super.initState();

    // Inisialisasi animator berdasarkan type
    _animator = AnimatorFactory.createAnimator(widget.animationType);

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_isDragging && widget.repeatWhenDrag) {
          _controller.forward(from: 0.0);
        } else {
          setState(() {
            _isAnimating = false;
          });
          _controller.reset();
        }
      }
    });

    // Setup controller jika ada
    if (widget.controller != null) {
      widget.controller!._setCallback(_startAnimation);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateChildSize();

      // Hanya setup drag detection jika touchEnabled
      if (widget.touchEnabled) {
        _setupDragDetection();
      }

      if (widget.autoAnimate) {
        _startAnimation();
      }
    });
  }

  @override
  void didUpdateWidget(EffectAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animator jika jenisnya berubah
    if (oldWidget.animationType != widget.animationType) {
      _animator = AnimatorFactory.createAnimator(widget.animationType);
    }

    // Update controller callback jika controller berubah
    if (widget.controller != null &&
        widget.controller != oldWidget.controller) {
      widget.controller!._setCallback(_startAnimation);
    }

    // Handle perubahan touchEnabled
    if (widget.touchEnabled != oldWidget.touchEnabled) {
      if (widget.touchEnabled) {
        _setupDragDetection();
      }
      // Sayangnya tidak ada cara langsung untuk "unregister" global route
      // Tapi kita akan mengecek flag touchEnabled di dalam handler
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateChildSize() {
    if (_widgetKey.currentContext != null) {
      final RenderBox renderBox =
          _widgetKey.currentContext!.findRenderObject() as RenderBox;
      setState(() {
        _childSize = renderBox.size;
      });
    }
  }

  void _startAnimation() {
    _updateChildSize();
    setState(() {
      _isAnimating = true;
    });
    _controller.forward(from: 0.0);
  }

  void _setupDragDetection() {
    WidgetsBinding.instance.pointerRouter.addGlobalRoute((event) {
      // Skip jika touchEnabled = false
      if (!widget.touchEnabled) return;

      if (event is PointerDownEvent) {
        if (_widgetKey.currentContext != null) {
          final RenderBox box =
              _widgetKey.currentContext!.findRenderObject() as RenderBox;
          final Offset localPosition = box.globalToLocal(event.position);
          if (box.size.contains(localPosition)) {
            setState(() {
              _isDragging = true;
              _isAnimating = true;
            });
            _controller.forward(from: 0.0);
          }
        }
      } else if (event is PointerUpEvent || event is PointerCancelEvent) {
        setState(() {
          _isDragging = false;
        });
      }
    });
  }

  Offset _getPositionOffset() {
    // Jika ada customOffset yang diberikan, gunakan itu
    if (widget.customOffset != null) {
      return widget.customOffset!;
    }

    // Jika tidak, hitung berdasarkan AnimationPosition
    AnimationPosition position = widget.position;
    if (position == AnimationPosition.outside) {
      // Gunakan posisi default dari animator jika 'outside'
      position = _animator.getDefaultPosition();
    }

    return PositionCalculator.calculatePosition(
        position, _childSize, _animator);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        if (_isAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    size: Size(_childSize.width, _childSize.height),
                    painter: EffectPainter(
                      progress: _controller.value,
                      center:
                          Offset(_childSize.width / 2, _childSize.height / 2),
                      color: widget.effectColor,
                      childSize: _childSize,
                      animator: _animator,
                      radiusMultiplier: widget.radiusMultiplier ??
                          _animator.getDefaultRadiusMultiplier(),
                      positionOffset: _getPositionOffset(),
                    ),
                  );
                },
              ),
            ),
          ),
        GestureDetector(
          key: _widgetKey,
          // Hanya jalankan _startAnimation jika touchEnabled = true
          onTap: widget.touchEnabled ? _startAnimation : null,
          child: widget.child,
        ),
      ],
    );
  }
}

extension EffectAnimationExtension on Widget {
  Widget withEffectAnimation({
    Color effectColor = const Color(0xFF8BB3C5),
    Duration duration = const Duration(milliseconds: 2400),
    bool repeatWhenDrag = true,
    bool autoAnimate = false,
    AnimationType animationType = AnimationType.firework,
    double? radiusMultiplier,
    AnimationPosition position = AnimationPosition.outside,
    Offset? customOffset,
    EffectAnimationController? controller,
    bool touchEnabled = true, // Parameter baru dengan default true
  }) {
    return EffectAnimation(
      effectColor: effectColor,
      duration: duration,
      repeatWhenDrag: repeatWhenDrag,
      autoAnimate: autoAnimate,
      animationType: animationType,
      radiusMultiplier: radiusMultiplier,
      position: position,
      customOffset: customOffset,
      controller: controller,
      touchEnabled: touchEnabled, // Tambahkan ke constructor
      child: this,
    );
  }
}
