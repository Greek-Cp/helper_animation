import 'package:flutter/material.dart';

class GameInstructionSet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Default value
    final defaultPadding = EdgeInsets.symmetric(vertical: 12, horizontal: 16);
    var defaultMargin = EdgeInsets.symmetric(vertical: 12, horizontal: 16);
    const defaultBackgroundColor = Color.fromARGB(123, 171, 247, 255);
    final defaultBorderRadius = BorderRadius.circular(16);
    final defaultFontSize = 16.0;
    const defaultFontWeight = FontWeight.bold;
    const defaultTextColor = Color(0xFF285499);
    const defaultTextAlign = TextAlign.center;
    const defaultTextHeight = 1.15;

    return Container(
      width: double.infinity,
      height: 80, // Default height of 80
      margin: margin ?? defaultMargin,
      padding: padding ?? defaultPadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBackgroundColor,
        borderRadius: borderRadius ?? defaultBorderRadius,
      ),
      clipBehavior: Clip.hardEdge, // Force clipping to prevent any overflow
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate available space (accounting for padding)
            final availableWidth = constraints.maxWidth;
            final availableHeight = constraints.maxHeight;

            // Start with default font size
            double calculatedFontSize = fontSize ?? defaultFontSize;
            double minFontSize = 5.0; // Absolute minimum size

            // Binary search for the optimal font size
            double maxSize = calculatedFontSize;
            double minSize = minFontSize;

            // Function to check if text fits at a given size
            bool doesTextFit(double size) {
              final textStyle = TextStyle(
                fontWeight: fontWeight ?? defaultFontWeight,
                fontSize: size,
                color: textColor ?? defaultTextColor,
                height: textHeight ?? defaultTextHeight,
              );

              final textSpan = TextSpan(
                text: text,
                style: textStyle,
              );

              final textPainter = TextPainter(
                text: textSpan,
                textDirection: TextDirection.ltr,
                textAlign: textAlign ?? defaultTextAlign,
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
                text,
                textAlign: textAlign ?? defaultTextAlign,
                style: TextStyle(
                  fontWeight: fontWeight ?? defaultFontWeight,
                  fontSize: calculatedFontSize,
                  color: textColor ?? defaultTextColor,
                  height: textHeight ?? defaultTextHeight,
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
