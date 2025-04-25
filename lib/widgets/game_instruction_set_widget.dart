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

    // Use SingleChildScrollView to enable scrolling
    return Container(
      width: double.infinity,
      margin: margin ?? defaultMargin,
      padding: padding ?? defaultPadding,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBackgroundColor,
        borderRadius: borderRadius ?? defaultBorderRadius,
      ),
      child: SingleChildScrollView(
        child: Text(
          text,
          textAlign: textAlign ?? defaultTextAlign,
          style: TextStyle(
            fontWeight: fontWeight ?? defaultFontWeight,
            fontSize: fontSize ?? defaultFontSize,
            color: textColor ?? defaultTextColor,
            height: textHeight ?? defaultTextHeight,
          ),
        ),
      ),
    );
  }
}
