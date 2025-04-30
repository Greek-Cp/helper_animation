import 'package:flutter/material.dart';
import 'package:helper_animation/constants/measurement_size.dart';

class GameInstructionSet extends StatefulWidget {
  final String text;
  final EdgeInsets? padding, margin;
  final Color? backgroundColor, textColor;
  final BorderRadius? borderRadius;
  final double? fontSize;
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
  });

  @override
  State<GameInstructionSet> createState() => _GameInstructionSetState();
}

class _GameInstructionSetState extends State<GameInstructionSet> {
  static const _kMaxFont = 22.0;
  static const _kMinFont = 18.0;
  static const _kMaxLines = 3;

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
    const bgDefault = Color(0xFF285499);
    const textDefault = Color.fromARGB(166, 216, 248, 255);
    const weightDefault = FontWeight.bold;
    const alignDefault = TextAlign.center;
    final borderDefault = BorderRadius.circular(20);

    final padding = widget.padding ??
        const EdgeInsets.symmetric(vertical: 12, horizontal: 16);
    final margin = widget.margin ??
        const EdgeInsets.symmetric(vertical: 12, horizontal: 16);

    return LayoutBuilder(
      builder: (context, constraints) {
        //------------------------------------------------------------
        // 1) Cari font terbesar (22→18) yg tidak melebihi 3 baris
        //------------------------------------------------------------
        double low = _kMinFont, high = _kMaxFont, best = low;

        bool fits(double size) {
          final tp = TextPainter(
            text: TextSpan(
              text: widget.text,
              style: TextStyle(
                fontSize: size,
                fontWeight: widget.fontWeight ?? weightDefault,
                height: 1.2,
              ),
            ),
            maxLines: _kMaxLines,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: constraints.maxWidth - padding.horizontal);
          return !tp.didExceedMaxLines;
        }

        // binary-search
        while (high - low > .5) {
          final mid = (high + low) / 2;
          if (fits(mid)) {
            best = mid;
            low = mid;
          } else {
            high = mid;
          }
        }
        final chosenSize = best;

        //------------------------------------------------------------
        // 2) Hitung baris aktual & pilih lineHeight adaptif
        //------------------------------------------------------------
        final tempTp = TextPainter(
          text: TextSpan(
            text: widget.text,
            style: TextStyle(fontSize: chosenSize, height: 1.2),
          ),
          maxLines: _kMaxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth - padding.horizontal);

        final lineCount = tempTp.computeLineMetrics().length;
        final lineHeight =
            lineCount == 3 ? 1.15 : (lineCount == 2 ? 1.20 : 1.28);

        // Re-measure dengan lineHeight final
        final tpFinal = TextPainter(
          text: TextSpan(
            text: widget.text,
            style: TextStyle(fontSize: chosenSize, height: lineHeight),
          ),
          maxLines: _kMaxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth - padding.horizontal);

        final boxHeight = tpFinal.height + padding.vertical;

        //------------------------------------------------------------
        // 3) Build UI — tidak akan ter-crop
        //------------------------------------------------------------
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
              overflow: TextOverflow.clip, // tanpa ellipsis
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
