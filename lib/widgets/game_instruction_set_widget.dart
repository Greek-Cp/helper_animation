import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class GameInstructionSet extends StatefulWidget {
  final String text;
  final EdgeInsets? padding, margin;
  final Color? backgroundColor, textColor;
  final BorderRadius? borderRadius;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final double textScale;

  const GameInstructionSet({
    super.key,
    required this.text,
    this.padding,
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.borderRadius,
    this.fontWeight,
    this.textColor,
    this.textAlign,
    this.textScale = 1.0,
  });

  @override
  State<GameInstructionSet> createState() => _GameInstructionSetState();
}

class _GameInstructionSetState extends State<GameInstructionSet> {
  static const double _kMaxFont = 22.0;
  static const double _kMinFont = 4.0;
  static const int _kMaxLines = 3;

  @override
  Widget build(BuildContext context) {
    const bgDefault = Color(0xFF285499);
    const textDefault = Color.fromARGB(166, 216, 248, 255);
    const weightDefault = FontWeight.bold;
    const alignDefault = TextAlign.center;
    final borderDefault = BorderRadius.circular(20);

    final padding = widget.padding ??
        const EdgeInsets.symmetric(vertical: 10, horizontal: 16);
    final margin = widget.margin ??
        const EdgeInsets.symmetric(vertical: 12, horizontal: 16);

    return LayoutBuilder(
      builder: (context, constraints) {
        double low = _kMinFont * widget.textScale;
        double high = _kMaxFont * widget.textScale;
        double bestFont = _kMinFont * widget.textScale;
        double lineHeight = 1.2;

        final maxWidth = constraints.maxWidth - padding.horizontal;

        while ((high - low) > 0.2) {
          final mid = (low + high) / 2;

          final tp = TextPainter(
            text: TextSpan(
              text: widget.text,
              style: TextStyle(
                  fontSize: mid,
                  height: lineHeight,
                  fontWeight: widget.fontWeight ?? weightDefault),
            ),
            maxLines: _kMaxLines,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: maxWidth);

          if (!tp.didExceedMaxLines) {
            bestFont = mid;
            low = mid;
          } else {
            high = mid;
          }
        }

        // Confirm line height
        final finalPainter = TextPainter(
          text: TextSpan(
            text: widget.text,
            style: TextStyle(fontSize: bestFont, height: lineHeight),
          ),
          maxLines: _kMaxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: maxWidth);

        final actualLines = finalPainter.computeLineMetrics().length;
        lineHeight = actualLines == 3 ? 1.15 : (actualLines == 2 ? 1.2 : 1.28);

        // Ensure minFontSize is a multiple of stepGranularity
        const stepGranularity = 0.5;
        final baseMinFontSize = 4 * widget.textScale;
        final minFontSize =
            (baseMinFontSize / stepGranularity).round() * stepGranularity;

        return Container(
          width: double.infinity,
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? bgDefault,
            borderRadius: widget.borderRadius ?? borderDefault,
          ),
          child: AutoSizeText(
            widget.text,
            maxLines: 3,
            minFontSize: minFontSize,
            stepGranularity: stepGranularity,
            overflowReplacement: const Text(
              'Text too long',
              style: TextStyle(color: Colors.red),
            ),
            textAlign: widget.textAlign ?? alignDefault,
            style: TextStyle(
              fontSize: 22 * widget.textScale,
              fontWeight: widget.fontWeight ?? weightDefault,
              color: widget.textColor ?? textDefault,
              height: 1.2,
            ),
          ),
        );
      },
    );
  }
}
