import 'dart:async';

import '../factory/animator_factory.dart';
import '../animators/effect_animator.dart';
import '../constants/enums.dart';
import '../painters/effect_painter.dart';
import '../utils/position_calculator.dart';
import 'package:flutter/material.dart';

// Controller class untuk mentrigger animasi dari luar dengan listener
class EffectAnimationController {
  VoidCallback? _startAnimationCallback;
  List<Function(AnimationStatus)> _statusListeners = [];
  bool _isDisposed = false;
  Completer<void>? _animationCompleter;

  // Method untuk mentrigger animasi dan menunggu sampai selesai
  Future<void> triggerAnimation() {
    if (_isDisposed) {
      return Future.value(); // Return completed future if disposed
    }

    // Buat completer baru setiap kali animasi ditrigger
    if (_animationCompleter != null && !_animationCompleter!.isCompleted) {
      _animationCompleter!.complete();
    }

    // Selalu buat Completer baru
    _animationCompleter = Completer<void>();

    if (_startAnimationCallback != null) {
      _startAnimationCallback!();
    } else {
      // Jika callback belum diset, langsung complete future
      // untuk menghindari future yang tidak pernah selesai
      _animationCompleter!.complete();
    }

    // Aman dari null check karena kita baru saja membuatnya
    return _animationCompleter!.future;
  }

  // Method internal untuk mengeset callback
  void _setCallback(VoidCallback callback) {
    _startAnimationCallback = callback;
  }

  // Method untuk menambahkan listener status animasi
  void addStatusListener(Function(AnimationStatus) listener) {
    if (!_isDisposed) {
      _statusListeners.add(listener);
    }
  }

  // Method untuk menghapus listener status animasi
  void removeStatusListener(Function(AnimationStatus) listener) {
    if (!_isDisposed) {
      _statusListeners.remove(listener);
    }
  }

  // Method internal untuk mentrigger listener
  void _notifyStatusListeners(AnimationStatus status) {
    if (_isDisposed) return;

    // Buat copy dari list untuk menghindari concurrent modification
    final listeners = List<Function(AnimationStatus)>.from(_statusListeners);

    // Notifikasi semua listener menggunakan copy list
    for (var listener in listeners) {
      if (!_isDisposed) {
        listener(status);
      }
    }

    // Complete future when animation is completed
    if ((status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) &&
        _animationCompleter != null &&
        !_animationCompleter!.isCompleted) {
      _animationCompleter!.complete();
    }
  }

  // Method untuk membersihkan resources
  void dispose() {
    _isDisposed = true;
    _statusListeners.clear();
    _startAnimationCallback = null;

    if (_animationCompleter != null && !_animationCompleter!.isCompleted) {
      _animationCompleter!.complete();
    }
    _animationCompleter = null;
  }
}

class EffectAnimation extends StatefulWidget {
  final Widget child;
  final Color effectColor;
  final Duration duration;
  final bool repeatWhenDrag;
  final bool autoAnimate;
  final AnimationUndergroundType animationType;
  final double?
      radiusMultiplier; // Jarak/ukuran animasi relatif terhadap widget
  final AnimationPosition position; // Posisi animasi relatif terhadap widget
  final Offset? customOffset; // Untuk override posisi jika diperlukan
  final EffectAnimationController? controller; // Controller baru
  final bool touchEnabled; // Flag untuk mengaktifkan/menonaktifkan respons tap
  final bool mixedColor;
  // Warna partikel kustom (khususnya untuk PixelExplosionAnimator)
  final List<Color>? particleColors;

  const EffectAnimation({
    Key? key,
    required this.child,
    this.effectColor = const Color(0xFF8BB3C5),
    this.duration = const Duration(milliseconds: 2400),
    this.repeatWhenDrag = true,
    this.autoAnimate = false,
    this.animationType = AnimationUndergroundType.firework,
    this.radiusMultiplier,
    this.position = AnimationPosition.outside,
    this.customOffset,
    this.controller,
    this.mixedColor = false,
    this.touchEnabled = true, // Default-nya aktif
    this.particleColors,
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

  // Untuk tracking pointer yang aktif
  int? _activePointerId;

  // Untuk memeriksa apakah event handler sudah di-setup
  bool _dragDetectionSetup = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    // Inisialisasi animator berdasarkan type
    _animator = AnimatorFactory.createAnimator(
      widget.animationType,
      enableMixedColor: widget.mixedColor,
      particleColors: widget.particleColors,
    );

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addStatusListener(_handleAnimationStatus);

    // Setup controller jika ada
    if (widget.controller != null) {
      widget.controller!._setCallback(_startAnimation);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateChildSize();

        // Hanya setup drag detection jika touchEnabled
        if (widget.touchEnabled && !_dragDetectionSetup) {
          _setupDragDetection();
          _dragDetectionSetup = true;
        }

        if (widget.autoAnimate) {
          _startAnimation();
        }
      }
    });
  }

  void _handleAnimationStatus(AnimationStatus status) {
    // Notifikasi listener pada controller
    if (widget.controller != null) {
      widget.controller!._notifyStatusListeners(status);
    }

    // Logika untuk menangani completion
    if (status == AnimationStatus.completed) {
      if (_isDragging && widget.repeatWhenDrag) {
        _controller.forward(from: 0.0);
      } else {
        if (mounted) {
          setState(() {
            _isAnimating = false;
          });
          _controller.reset();
        }
      }
    }
  }

  @override
  void didUpdateWidget(EffectAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animator jika jenisnya berubah
    if (oldWidget.animationType != widget.animationType ||
        oldWidget.mixedColor != widget.mixedColor) {
      _animator = AnimatorFactory.createAnimator(
        widget.animationType,
        enableMixedColor: widget.mixedColor,
        particleColors: widget.particleColors,
      );
    }

    // Update duration jika berubah
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }

    // Update controller callback jika controller berubah
    if (widget.controller != null &&
        widget.controller != oldWidget.controller) {
      widget.controller!._setCallback(_startAnimation);
    }

    // Handle perubahan touchEnabled
    if (widget.touchEnabled != oldWidget.touchEnabled) {
      if (widget.touchEnabled && !_dragDetectionSetup) {
        _setupDragDetection();
        _dragDetectionSetup = true;
      }
      // Jika dinonaktifkan, pointer event akan diperiksa di handler
    }
  }

  @override
  void dispose() {
    // Membersihkan listener dan controller
    _controller.removeStatusListener(_handleAnimationStatus);
    _controller.dispose();

    // Reset variabel pointer tracking
    _activePointerId = null;
    _dragDetectionSetup = false;

    super.dispose();
  }

  void _updateChildSize() {
    if (_widgetKey.currentContext != null && mounted) {
      final RenderBox renderBox =
          _widgetKey.currentContext!.findRenderObject() as RenderBox;
      setState(() {
        _childSize = renderBox.size;
      });
    }
  }

  void _startAnimation() {
    if (!mounted) return;

    // Dispose old controller and animator
    _controller.dispose();

    // Create new animation controller and animator
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addStatusListener(_handleAnimationStatus);
    _animator = AnimatorFactory.createAnimator(
      widget.animationType,
      enableMixedColor: widget.mixedColor,
      particleColors: widget.particleColors,
    );

    _updateChildSize();
    setState(() {
      _isAnimating = true;
    });
    _controller.forward(from: 0.0);
  }

  void _setupDragDetection() {
    WidgetsBinding.instance.pointerRouter.addGlobalRoute((event) {
      // Skip jika widget tidak aktif, tidak mounted, atau touchEnabled = false
      if (!widget.touchEnabled || !mounted) return;

      if (event is PointerDownEvent) {
        if (_widgetKey.currentContext != null) {
          final RenderBox box =
              _widgetKey.currentContext!.findRenderObject() as RenderBox;
          final Offset localPosition = box.globalToLocal(event.position);
          if (box.size.contains(localPosition)) {
            // Simpan pointer aktif
            _activePointerId = event.pointer;

            if (mounted) {
              setState(() {
                _isDragging = true;
                _isAnimating = true;
              });
              _controller.forward(from: 0.0);
            }
          }
        }
      } else if (event is PointerUpEvent || event is PointerCancelEvent) {
        // Hanya tangani pointer yang kita track
        if (_activePointerId == event.pointer) {
          _activePointerId = null;

          if (mounted) {
            setState(() {
              _isDragging = false;
            });
          }
        }
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
    AnimationUndergroundType animationType = AnimationUndergroundType.firework,
    double? radiusMultiplier,
    AnimationPosition position = AnimationPosition.outside,
    Offset? customOffset,
    EffectAnimationController? controller,
    bool touchEnabled = true,
    bool enableMixedColor = false,
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
      touchEnabled: touchEnabled,
      child: this,
      mixedColor: enableMixedColor,
    );
  }

  // Versi baru khusus Pixel Explosion dengan daftar warna per partikel
  Widget withEffectAnimationNew({
    required List<Color> listColor,
    Color effectColor = const Color(0xFF8BB3C5),
    Duration duration = const Duration(milliseconds: 2400),
    bool repeatWhenDrag = true,
    bool autoAnimate = false,
    double? radiusMultiplier,
    AnimationPosition position = AnimationPosition.outside,
    Offset? customOffset,
    EffectAnimationController? controller,
    bool touchEnabled = true,
  }) {
    return EffectAnimation(
      effectColor: effectColor,
      duration: duration,
      repeatWhenDrag: repeatWhenDrag,
      autoAnimate: autoAnimate,
      animationType: AnimationUndergroundType.pixelExplosion,
      radiusMultiplier: radiusMultiplier,
      position: position,
      customOffset: customOffset,
      controller: controller,
      touchEnabled: touchEnabled,
      child: this,
      mixedColor: false, // gunakan listColor, bukan hue tilt
      particleColors: listColor,
    );
  }
}
