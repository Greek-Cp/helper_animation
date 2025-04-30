import 'package:flutter/material.dart';
import 'package:helper_animation/constants/measurement_size.dart';

class GameInstructionSet extends StatefulWidget {
  final String text;
  final EdgeInsets? padding, margin;
  final Color? backgroundColor, textColor;
  final BorderRadius? borderRadius;
  final double? fontSize, textHeight;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;

  const GameInstructionSet({
    super.key,
    required this.text,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
    this.textColor,
    this.textAlign,
    this.textHeight,
  });

  @override
  State<GameInstructionSet> createState() => _GameInstructionSetState();
}

class _GameInstructionSetState extends State<GameInstructionSet> {
  static const _kMaxLines = 3;
  static const _kMaxFont = 22.0;
  static const _kMinFont = 18.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => MeasurementsSizeApp.initialize(context),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MeasurementsSizeApp.initialize(context);
  }

  @override
  Widget build(BuildContext context) {
    // ——— default style ———
    const bgDefault = Color(0xFF285499);
    const textDefault = Color.fromARGB(166, 216, 248, 255);
    const weightDefault = FontWeight.bold;
    const alignDefault = TextAlign.center;
    const lineHeightDefault = 1.28; // lebih lega
    final borderDefault = BorderRadius.circular(30);

    final padding = widget.padding ??
        const EdgeInsets.symmetric(vertical: 12, horizontal: 16);
    final margin = widget.margin ??
        const EdgeInsets.symmetric(vertical: 12, horizontal: 16);

    // font awal (clamp 18-22)
    final double start =
        (widget.fontSize ?? _kMaxFont).clamp(_kMinFont, _kMaxFont);

    return LayoutBuilder(
      builder: (context, constraints) {
        double low = _kMinFont, high = start, best = low;

        // helper: cek muat ≤3 baris
        bool fits(double size) {
          final tp = TextPainter(
            text: TextSpan(
              text: widget.text,
              style: TextStyle(
                fontSize: size,
                fontWeight: widget.fontWeight ?? weightDefault,
                height: widget.textHeight ?? lineHeightDefault,
              ),
            ),
            maxLines: _kMaxLines,
            textAlign: widget.textAlign ?? alignDefault,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: constraints.maxWidth - padding.horizontal);

          return !tp.didExceedMaxLines;
        }

        // cari font terbesar yang muat
        while (high - low > .5) {
          final mid = (high + low) / 2;
          if (fits(mid)) {
            best = mid;
            low = mid;
          } else {
            high = mid;
          }
        }

        final chosenSize = fits(best) ? best : _kMinFont;

        // —— Hitung baris aktual —— //
        final tp = TextPainter(
          text: TextSpan(
            text: widget.text,
            style: TextStyle(
              fontSize: chosenSize,
              fontWeight: widget.fontWeight ?? weightDefault,
              height: widget.textHeight ?? lineHeightDefault,
            ),
          ),
          maxLines: _kMaxLines,
          textAlign: widget.textAlign ?? alignDefault,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth - padding.horizontal);

        final int lineCount =
            tp.computeLineMetrics().length.clamp(1, _kMaxLines);

        final lineHeight = widget.textHeight ?? lineHeightDefault;
        final boxHeight =
            chosenSize * lineHeight * lineCount + padding.vertical + 4;

        return Container(
          width: double.infinity,
          height: boxHeight,
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? bgDefault,
            borderRadius: widget.borderRadius ?? borderDefault,
          ),
          clipBehavior: Clip.hardEdge,
          child: Center(
            child: Text(
              widget.text,
              maxLines: _kMaxLines,
              overflow: TextOverflow.clip,
              softWrap: true,
              textAlign: widget.textAlign ?? alignDefault,
              style: TextStyle(
                fontSize: chosenSize,
                fontWeight: widget.fontWeight ?? weightDefault,
                color: widget.textColor ?? textDefault,
                height: lineHeight,
              ),
            ),
          ),
        );
      },
    );
  }
}
