import 'dart:math';

import 'package:flutter/material.dart';
import 'package:helper_animation/helper_animation.dart';

enum DragFeedbackAnim {
  pulse,
  shake,
  fade,
  springSquash,
  hoverFloat,
  colorThrob,
  flip3D,
  neonOutline,
  jellyWobble,
  holographicGlitch,
  magneticPull,
  wobble,
  glow,
  jellyfishBreathing,
  squashStretch, // <-- New animation type
  happyBounce, // <-- New animation type
}

extension AnimationDraggableFeedback on Widget {
  Widget animationDraggableFeedback({
    DragFeedbackAnim type = DragFeedbackAnim.pulse,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeInOut,
    double intensity = 1.0,
  }) {
    switch (type) {
      case DragFeedbackAnim.jellyfishBreathing: // <-- New case
        return _JellyfishBreathingFeedback(
            child: this, duration: duration, curve: curve);
      case DragFeedbackAnim.pulse:
        return _PulseFeedback(child: this, duration: duration);
      case DragFeedbackAnim.shake:
        return _ShakeFeedback(child: this, duration: duration);
      case DragFeedbackAnim.fade:
        return _FadeFeedback(child: this, duration: duration);
      case DragFeedbackAnim.springSquash:
        return _SpringSquashFeedback(
            child: this, duration: duration, curve: curve);
      case DragFeedbackAnim.hoverFloat:
        return _HoverFloatFeedback(
            child: this, duration: duration, curve: curve);
      case DragFeedbackAnim.colorThrob:
        return _ColorThrobFeedback(
            child: this, duration: duration, curve: curve);
      case DragFeedbackAnim.flip3D:
        return _Flip3DFeedback(child: this, duration: duration, curve: curve);
      case DragFeedbackAnim.neonOutline:
        return _NeonOutlineFeedback(
            child: this, duration: duration, curve: curve);
      case DragFeedbackAnim.jellyWobble:
        return _JellyWobbleFeedback(
            child: this, duration: duration, curve: curve);
      case DragFeedbackAnim.holographicGlitch:
        return _HolographicGlitchFeedback(
            child: this, duration: duration, curve: curve);
      case DragFeedbackAnim.magneticPull:
        return _MagneticPullFeedback(
            child: this, duration: duration, curve: curve);
      case DragFeedbackAnim.wobble:
        return _WobbleFeedback(child: this, duration: duration);
      case DragFeedbackAnim.glow:
        // Glow mungkin butuh warna dasar, bisa ditambahkan sbg parameter nanti
        return _GlowFeedback(
            child: this, duration: duration, glowColor: Colors.blue);
      case DragFeedbackAnim.squashStretch: // <-- New case
        // Squash and stretch feels good with elastic curves
        return _SquashStretchFeedback(
            child: this, duration: duration, curve: Curves.elasticOut);
      case DragFeedbackAnim.happyBounce: // <-- New case
        // Bounce feels good with bouncy curves
        return _HappyBounceFeedback(
            child: this, duration: duration, curve: Curves.bounceOut);
    }
  }
}

class _SquashStretchFeedback extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const _SquashStretchFeedback({
    Key? key,
    required this.child,
    required this.duration,
    required this.curve,
  }) : super(key: key);

  @override
  _SquashStretchFeedbackState createState() => _SquashStretchFeedbackState();
}

class _SquashStretchFeedbackState extends State<_SquashStretchFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(
        reverse: true); // Repeat for a continuous squash/stretch while dragging

    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Animate between a slightly squashed state and a slightly stretched state.
        // When animation value is low (0.0), it's more "normal" or slightly squashed.
        // When animation value is high (1.0), it's more stretched.
        // We'll use a curve transformation for a more pronounced effect.
        // The curve (like elasticOut) applied to the _animation already gives us
        // values that overshoot, which is good for squash and stretch.

        // A simple mapping: as value goes 0->1, scaleY goes 1.0->stretch, scaleX goes 1.0->squash
        // Let's make it squash slightly initially, then stretch.
        // With reverse:true, it will squash->stretch->squash->stretch...

        final double baseScale = 1.0;
        final double maxStretch = 1.1; // Max vertical stretch
        final double maxSquash =
            0.9; // Max horizontal squash (when stretched vertically)

        // Example calculation:
        // As _animation.value goes 0 -> 1:
        // Scale Y goes from baseScale towards maxStretch
        // Scale X goes from baseScale towards maxSquash
        // Using the curve ensures it overshoots/bounces.

        // For a simple back-and-forth:
        // When _animation.value is 0 (or near 0), it's normal or slightly squashed initially.
        // When _animation.value is 1 (or near 1), it's stretched vertically and squashed horizontally.

        // Let's try animating around 1.0, with value < 1 being squash and value > 1 being stretch (using curve overshoot)
        // The elasticOut curve goes > 1 then back to 1 then < 1 then back to 1.
        // We can map this: value > 1 stretches Y and squashes X. value < 1 squashes Y and stretches X.
        // Value == 1 is the "normal" state.

        double scaleY = 1.0 +
            (_animation.value - 1.0) *
                0.2; // Stretch up to 1.2, squash down to 0.8 (example)
        double scaleX = 1.0 -
            (_animation.value - 1.0) *
                0.2; // Squash down to 0.8, stretch up to 1.2 (example)

        // Clamp values to prevent flipping
        scaleY = scaleY.clamp(0.5, 1.5); // Adjust clamp values as needed
        scaleX = scaleX.clamp(0.5, 1.5);

        // For a more direct 0-1 mapping where 0 is squashed, 0.5 is normal, 1 is stretched:
        // double scaleY, scaleX;
        // if (_animation.value < 0.5) {
        //   // Squash phase (0 to 0.5)
        //   double t = _animation.value / 0.5; // Normalized 0 to 1 for this phase
        //   scaleY = lerpDouble(0.8, 1.0, t)!; // Squashes Y from 0.8 to 1.0
        //   scaleX = lerpDouble(1.2, 1.0, t)!; // Stretches X from 1.2 to 1.0
        // } else {
        //   // Stretch phase (0.5 to 1.0)
        //   double t = (_animation.value - 0.5) / 0.5; // Normalized 0 to 1 for this phase
        //   scaleY = lerpDouble(1.0, 1.2, t)!; // Stretches Y from 1.0 to 1.2
        //   scaleX = lerpDouble(1.0, 0.8, t)!; // Squashes X from 1.0 to 0.8
        // }

        // Using the first method with elasticOut curve is often simpler and looks good:
        scaleY = 1.0 + (_animation.value - 1.0) * 0.1; // More subtle effect
        scaleX = 1.0 - (_animation.value - 1.0) * 0.1;

        return Transform.scale(
          scaleY: scaleY,
          scaleX: scaleX,
          // Applying scale from the center is usually desired for squash/stretch
          alignment: Alignment.center,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// --- NEW: Happy Bounce Feedback Implementation ---

class _HappyBounceFeedback extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const _HappyBounceFeedback({
    Key? key,
    required this.child,
    required this.duration,
    required this.curve,
  }) : super(key: key);

  @override
  _HappyBounceFeedbackState createState() => _HappyBounceFeedbackState();
}

class _HappyBounceFeedbackState extends State<_HappyBounceFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(); // Repeat for a continuous bounce

    // Animate a vertical offset. BounceOut curve is applied to the controller directly.
    // We are animating the *amount* of bounce from 0 (no bounce) to maxBounceOffset.
    _bounceAnimation = Tween<double>(begin: 0.0, end: -20.0).animate(
      // Bounce upwards (negative Y)
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        // Use Transform.translate to move the widget up and down
        return Transform.translate(
          offset: Offset(0.0, _bounceAnimation.value),
          // Optional: Add a subtle scale pulse for extra bounce feel
          // child: Transform.scale(
          //   scale: 1.0 + _bounceAnimation.value.abs() * 0.005, // Scale slightly when bouncing up
          //   child: child,
          // ),
          child: child, // Use this line if not adding scale
        );
      },
      child: widget.child,
    );
  }
}

class _JellyfishBreathingFeedback extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const _JellyfishBreathingFeedback({
    Key? key,
    required this.child,
    required this.duration,
    required this.curve,
  }) : super(key: key);

  @override
  _JellyfishBreathingFeedbackState createState() =>
      _JellyfishBreathingFeedbackState();
}

class _JellyfishBreathingFeedbackState
    extends State<_JellyfishBreathingFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration, // Use the provided duration
      vsync: this,
    )..repeat(
        reverse: true); // Repeat forward and backward for breathing effect

    // Scale animation: pulses between normal size and slightly larger
    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      // Scale up by 8%
      CurvedAnimation(
          parent: _controller, curve: widget.curve), // Use the provided curve
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _breathingAnimation.value,
          // Optionally, add a subtle opacity change or color overlay here
          // to enhance the effect, like the jellyfish becoming slightly more transparent.
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// Neon Outline Feedback
class _NeonOutlineFeedback extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const _NeonOutlineFeedback({
    Key? key,
    required this.child,
    required this.duration,
    required this.curve,
  }) : super(key: key);

  @override
  _NeonOutlineFeedbackState createState() => _NeonOutlineFeedbackState();
}

class _NeonOutlineFeedbackState extends State<_NeonOutlineFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true); // Repeats the glow effect

    _glowAnimation = Tween<double>(begin: 0.0, end: 5.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        // This is a simplified representation.
        // For a true "neon outline", you might use a custom painter or
        // leverage effects like shaders or stacking blurred copies.
        // This example applies a subtle blur and scaling effect.
        return Transform.scale(
          scale: 1.0 + _glowAnimation.value * 0.01, // Subtle scale effect
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(
                      _glowAnimation.value / 5.0), // Glow color and intensity
                  blurRadius: _glowAnimation.value * 2.0,
                  spreadRadius: _glowAnimation.value * 0.5,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// Jelly Wobble Feedback
class _JellyWobbleFeedback extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const _JellyWobbleFeedback({
    Key? key,
    required this.child,
    required this.duration,
    required this.curve,
  }) : super(key: key);

  @override
  _JellyWobbleFeedbackState createState() => _JellyWobbleFeedbackState();
}

class _JellyWobbleFeedbackState extends State<_JellyWobbleFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _wobbleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true); // Repeats the wobble effect

    _wobbleAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _wobbleAnimation,
      builder: (context, child) {
        // Apply a slight rotation and scaling for a wobble effect
        return Transform.rotate(
          angle: _wobbleAnimation.value * pi, // Rotate slightly
          child: Transform.scale(
            scale: 1.0 +
                _wobbleAnimation.value.abs() *
                    0.1, // Scale up slightly as it rotates
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// Holographic Glitch Feedback
class _HolographicGlitchFeedback extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const _HolographicGlitchFeedback({
    Key? key,
    required this.child,
    required this.duration,
    required this.curve,
  }) : super(key: key);

  @override
  _HolographicGlitchFeedbackState createState() =>
      _HolographicGlitchFeedbackState();
}

class _HolographicGlitchFeedbackState extends State<_HolographicGlitchFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glitchAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(); // Repeats the glitch effect

    // This animation will drive the glitch parameters
    _glitchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glitchAnimation,
      builder: (context, child) {
        // A simple glitch effect using translation and opacity changes.
        // More advanced effects might involve custom shaders or mixing colors.
        final random = Random(_glitchAnimation.value
            .toInt()); // Use animation value for "randomness"
        final offsetX = (random.nextDouble() - 0.5) *
            20.0 *
            _glitchAnimation.value; // Horizontal shift
        final offsetY = (random.nextDouble() - 0.5) *
            20.0 *
            _glitchAnimation.value; // Vertical shift
        final opacity = 1.0 -
            (random.nextDouble() *
                0.3 *
                _glitchAnimation.value); // Random opacity changes

        return Transform.translate(
          offset: Offset(offsetX, offsetY),
          child: Opacity(
            opacity: opacity,
            child: ColorFiltered(
              // Simulate color shifting
              colorFilter: ColorFilter.mode(
                Colors.primaries[random.nextInt(Colors.primaries.length)]
                    .withOpacity(_glitchAnimation.value * 0.1),
                BlendMode.screen, // or BlendMode.difference, BlendMode.overlay
              ),
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

// Magnetic Pull Feedback
class _MagneticPullFeedback extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const _MagneticPullFeedback({
    Key? key,
    required this.child,
    required this.duration,
    required this.curve,
  }) : super(key: key);

  @override
  _MagneticPullFeedbackState createState() => _MagneticPullFeedbackState();
}

class _MagneticPullFeedbackState extends State<_MagneticPullFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pullAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..forward(from: 0.0); // Animates once when feedback starts

    _pullAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pullAnimation,
      builder: (context, child) {
        // Simulate a pull effect by scaling and slightly translating towards a "center"
        // (Here, just scaling and a subtle upward translation).
        final scale = 1.0 + _pullAnimation.value * 0.1; // Scales up
        final translateY = -_pullAnimation.value * 10.0; // Moves slightly up

        return Transform.translate(
          offset: Offset(0.0, translateY),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// 3. Implementasi _WobbleFeedback
class _WobbleFeedback extends StatefulWidget {
  final Widget child;
  final Duration duration;
  const _WobbleFeedback({required this.child, required this.duration});

  @override
  State<_WobbleFeedback> createState() => _WobbleFeedbackState();
}

class _WobbleFeedbackState extends State<_WobbleFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true);

  // Tentukan seberapa jauh goyangan rotasi (dalam radian)
  // pi radian = 180 derajat. 0.1 radian sekitar 5.7 derajat.
  final double _wobbleAngle = 0.1; // Sesuaikan nilai ini

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      alignment: Alignment.center, // Putar pada tengah
      turns: Tween(
              begin: -_wobbleAngle / (2 * pi), end: _wobbleAngle / (2 * pi))
          .animate(CurvedAnimation(
              parent: _ctl,
              curve: Curves.easeInOut)), // Gunakan turns (1 turn = 360 derajat)
      // Jika menggunakan Transform.rotate, gunakan angle dalam radian:
      // angle: Tween(begin: -_wobbleAngle, end: _wobbleAngle).animate(...).value
      child: widget.child,
    );
  }
}

// 4. Implementasi _GlowFeedback
class _GlowFeedback extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color glowColor; // Warna dasar untuk glow

  const _GlowFeedback({
    required this.child,
    required this.duration,
    this.glowColor = Colors.yellow, // Default glow color
  });

  @override
  State<_GlowFeedback> createState() => _GlowFeedbackState();
}

class _GlowFeedbackState extends State<_GlowFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true);

  // Definisikan Tween untuk properti shadow
  late final Animation<Color?> _colorAnimation = ColorTween(
    begin: widget.glowColor.withOpacity(0.0), // Mulai dari transparan
    end: widget.glowColor.withOpacity(0.7), // Mencapai opacity tertentu
  ).animate(CurvedAnimation(
      parent: _ctl, curve: Curves.easeIn)); // EaseIn agar cepat muncul

  late final Animation<double> _blurAnimation = Tween<double>(
    begin: 2.0, // Blur awal
    end: 12.0, // Blur maksimum saat glow
  ).animate(CurvedAnimation(parent: _ctl, curve: Curves.easeIn));

  late final Animation<double> _spreadAnimation = Tween<double>(
    begin: 1.0, // Spread awal
    end: 4.0, // Spread maksimum saat glow
  ).animate(CurvedAnimation(parent: _ctl, curve: Curves.easeIn));

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctl,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            // Penting: Bentuk shadow mengikuti bentuk container.
            // Jika child punya sudut, sebaiknya atur shape/borderRadius di sini juga
            // agar shadow cocok. Contoh: shape: BoxShape.circle jika child bulat.
            // Atau copy BorderRadius dari child jika memungkinkan.
            // Untuk simple case, kita anggap kotak:
            shape: BoxShape.rectangle, // atau BoxShape.circle, dll.
            // borderRadius: BorderRadius.circular(10), // Contoh jika child rounded

            boxShadow: [
              BoxShadow(
                color: _colorAnimation.value ?? Colors.transparent,
                blurRadius: _blurAnimation.value,
                spreadRadius: _spreadAnimation.value,
              ),
            ],
          ),
          child: child, // Widget asli diletakkan di dalam Container
        );
      },
      child: widget.child, // Widget asli diteruskan ke builder
    );
  }
}
// Existing implementations (pulse, shake, fade) remain same as original...

// ========== New Animations ========== //

class _SpringSquashFeedback extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  const _SpringSquashFeedback(
      {required this.child, required this.duration, required this.curve});

  @override
  State<_SpringSquashFeedback> createState() => _SpringSquashFeedbackState();
}

class _SpringSquashFeedbackState extends State<_SpringSquashFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctl,
      builder: (_, child) {
        final scaleY = Tween(begin: 1.0, end: 0.9).animate(_ctl).value;
        final scaleX = Tween(begin: 1.0, end: 1.05).animate(_ctl).value;
        return Transform.scale(
          scaleX: scaleX,
          scaleY: scaleY,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _HoverFloatFeedback extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  const _HoverFloatFeedback(
      {required this.child, required this.duration, required this.curve});

  @override
  State<_HoverFloatFeedback> createState() => _HoverFloatFeedbackState();
}

class _HoverFloatFeedbackState extends State<_HoverFloatFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctl,
      builder: (_, child) {
        final dy = Tween(begin: -8.0, end: 8.0)
            .animate(CurvedAnimation(parent: _ctl, curve: widget.curve))
            .value;

        return Transform.translate(
          offset: Offset(0, dy),
          child: DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(Tween(begin: 0.0, end: 0.2).evaluate(_ctl)),
                  spreadRadius: Tween(begin: 1.0, end: 3.0).evaluate(_ctl),
                  blurRadius: 10,
                )
              ],
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _ColorThrobFeedback extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  const _ColorThrobFeedback(
      {required this.child, required this.duration, required this.curve});

  @override
  State<_ColorThrobFeedback> createState() => _ColorThrobFeedbackState();
}

class _ColorThrobFeedbackState extends State<_ColorThrobFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctl,
      builder: (_, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: ColorTween(begin: Colors.blue, end: Colors.cyan)
                .animate(_ctl)
                .value,
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _Flip3DFeedback extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  const _Flip3DFeedback(
      {required this.child, required this.duration, required this.curve});

  @override
  State<_Flip3DFeedback> createState() => _Flip3DFeedbackState();
}

class _Flip3DFeedbackState extends State<_Flip3DFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctl,
      builder: (_, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(Tween(begin: 0.0, end: 0.26).animate(_ctl).value),
          alignment: Alignment.center,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ... Add remaining animation implementations following similar patterns

// ========== Usage Example ========== //
/*
Draggable(
  feedback: YourWidget()
    .animationDraggableFeedback(
      type: DragFeedbackAnim.springSquash,
      duration: Duration(milliseconds: 600),
    ),
  child: YourWidget(),
)
*/
class _PulseFeedback extends StatefulWidget {
  final Widget child;
  final Duration duration;
  const _PulseFeedback({required this.child, required this.duration});

  @override
  State<_PulseFeedback> createState() => _PulseFeedbackState();
}

class _PulseFeedbackState extends State<_PulseFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctl.dispose(); // <- tutup controller
    super.dispose(); // <- WAJIB!
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.1)
          .animate(CurvedAnimation(parent: _ctl, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}

class _ShakeFeedback extends StatefulWidget {
  final Widget child;
  final Duration duration;
  const _ShakeFeedback({required this.child, required this.duration});

  @override
  State<_ShakeFeedback> createState() => _ShakeFeedbackState();
}

class _ShakeFeedbackState extends State<_ShakeFeedback>
    with SingleTickerProviderStateMixin {
  late final _ctl = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true); // goyang kiri‑kanan

  @override
  void dispose() => _ctl.dispose();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctl,
      builder: (_, child) {
        final dx = Tween(begin: -4.0, end: 4.0).animate(_ctl).value;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}

class _FadeFeedback extends StatefulWidget {
  final Widget child;
  final Duration duration;
  const _FadeFeedback({required this.child, required this.duration});

  @override
  State<_FadeFeedback> createState() => _FadeFeedbackState();
}

class _FadeFeedbackState extends State<_FadeFeedback>
    with SingleTickerProviderStateMixin {
  late final _ctl = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true); // opacity turun‑naik

  @override
  void dispose() {
    _ctl.dispose(); // <- tutup controller
    super.dispose(); // <- WAJIB!
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.4).animate(_ctl),
      child: widget.child,
    );
  }
}
