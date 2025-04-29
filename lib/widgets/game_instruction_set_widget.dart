import 'package:flutter/material.dart';
import 'package:helper_animation/constants/measurement_size.dart';

class GameInstructionSet extends StatefulWidget {
  final String text;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? textColor;
  final TextAlign? textAlign;
  final double? textHeight;

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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MeasurementsSizeApp.initialize(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MeasurementsSizeApp.initialize(context);
  }

  @override
  Widget build(BuildContext context) {
    // Default value
    final defaultPadding = EdgeInsets.symmetric(vertical: 12, horizontal: 16);
    var defaultMargin = EdgeInsets.symmetric(vertical: 12, horizontal: 16);
    const defaultBackgroundColor = Color(0xFF285499);
    const defaultTextColor = Color.fromARGB(166, 216, 248, 255);

    final defaultBorderRadius = BorderRadius.circular(30);
    final defaultFontSize = MeasurementsSizeApp.calculatedSize(11);
    const defaultFontWeight = FontWeight.bold;
    const defaultTextAlign = TextAlign.center;
    const defaultTextHeight = 1.15;

    return Container(
      width: double.infinity,
      height: 60, // Default height of 80
      margin: widget.margin ?? defaultMargin,
      padding: widget.padding ?? defaultPadding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? defaultBackgroundColor,
        borderRadius: widget.borderRadius ?? defaultBorderRadius,
      ),
      clipBehavior: Clip.hardEdge, // Force clipping to prevent any overflow
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate available space (accounting for padding)
            final availableWidth = constraints.maxWidth;
            final availableHeight = constraints.maxHeight;

            // Start with default font size
            double calculatedFontSize = widget.fontSize ?? defaultFontSize;
            double minFontSize = 5.0; // Absolute minimum size

            // Binary search for the optimal font size
            double maxSize = calculatedFontSize;
            double minSize = minFontSize;

            // Function to check if text fits at a given size
            bool doesTextFit(double size) {
              final textStyle = TextStyle(
                fontWeight: widget.fontWeight ?? defaultFontWeight,
                fontSize: size,
                color: widget.textColor ?? defaultTextColor,
                height: widget.textHeight ?? defaultTextHeight,
              );

              final textSpan = TextSpan(
                text: widget.text,
                style: textStyle,
              );

              final textPainter = TextPainter(
                text: textSpan,
                textDirection: TextDirection.ltr,
                textAlign: widget.textAlign ?? defaultTextAlign,
                maxLines: 4,
              );

              textPainter.layout(maxWidth: availableWidth);

              // Strict check: must be within height AND not exceed max lines
              return textPainter.height < availableHeight * 0.98 &&
                  !textPainter.didExceedMaxLines;
            }

            // Binary search for largest font size that fits
            int iterations = 0;
            while (maxSize - minSize > 0.5 && iterations < 10) {
              double mid = (maxSize + minSize) / 2;
              if (doesTextFit(mid)) {
                minSize = mid;
              } else {
                maxSize = mid;
              }
              iterations++;
            }

            // To be extra safe, take 90% of the calculated optimal size
            calculatedFontSize = minSize * 0.9;

            return Container(
              constraints: BoxConstraints(
                maxWidth: availableWidth,
                maxHeight: availableHeight,
              ),
              child: Text(
                widget.text,
                textAlign: widget.textAlign ?? defaultTextAlign,
                style: TextStyle(
                  fontWeight: widget.fontWeight ?? defaultFontWeight,
                  fontSize: calculatedFontSize,
                  color: widget.textColor ?? defaultTextColor,
                  height: widget.textHeight ?? defaultTextHeight,
                ),
                maxLines: 4,
                overflow: TextOverflow
                    .ellipsis, // Show ellipsis if text still doesn't fit
              ),
            );
          },
        ),
      ),
    );
  }
}
