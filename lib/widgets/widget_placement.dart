// import 'package:flutter/material.dart';

// class AutoPositionWidget extends StatefulWidget {
//   final Widget widgetBase;
//   final Widget? widgetBaseButtonBottom;
//   final Widget? widgetBaseButtonKiri;
//   final Widget? widgetBaseButtonKanan;
//   final Widget? widgetBaseButtonAtas;

//   const AutoPositionWidget({
//     super.key,
//     required this.widgetBase,
//     this.widgetBaseButtonBottom,
//     this.widgetBaseButtonKiri,
//     this.widgetBaseButtonKanan,
//     this.widgetBaseButtonAtas,
//   });

//   static _AutoPositionWidgetState? of(BuildContext context) {
//     return context.findAncestorStateOfType<_AutoPositionWidgetState>();
//   }

//   @override
//   State<AutoPositionWidget> createState() => _AutoPositionWidgetState();
// }

// class _AutoPositionWidgetState extends State<AutoPositionWidget> {
//   Size? widgetBaseSize;
//   Size? buttonBottomSize;
//   bool _buttonsVisible = true;

//   final GlobalKey _widgetBaseKey = GlobalKey();
//   final GlobalKey _buttonBottomKey = GlobalKey(); // keep this – we still use it

//   OverlayEntry? _bottomOverlayEntry; // ⬅ NEW

//   /* ---------------- public helpers ---------------- */
//   void hideButtons() {
//     setState(() => _buttonsVisible = false);
//     _removeBottomOverlay(); // keep overlay in sync
//   }

//   void showButtons() {
//     setState(() => _buttonsVisible = true);
//     WidgetsBinding.instance
//         .addPostFrameCallback((_) => _insertOrUpdateBottomOverlay());
//   }

//   /* ---------------- widget tree ---------------- */
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (_, __) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           // Get the size of widgetBase using the dynamic GlobalKey
//           final renderBoxBase =
//               _widgetBaseKey.currentContext?.findRenderObject() as RenderBox?;
//           if (renderBoxBase != null) {
//             final newSize = renderBoxBase.size;
//             if (widgetBaseSize != newSize) {
//               setState(() {
//                 widgetBaseSize = newSize;
//               });
//             }
//           }

//           // Get the size of widgetBaseButtonBottom using the dynamic GlobalKey
//           if (widget.widgetBaseButtonBottom != null) {
//             final renderBoxButtonBottom = _buttonBottomKey.currentContext
//                 ?.findRenderObject() as RenderBox?;
//             if (renderBoxButtonBottom != null) {
//               final newButtonSize = renderBoxButtonBottom.size;
//               if (buttonBottomSize != newButtonSize) {
//                 setState(() {
//                   buttonBottomSize = newButtonSize;
//                 });
//               }
//             }
//           }
//           _measureBaseSize();
//           _measureBottomSize();
//           _insertOrUpdateBottomOverlay(); // every frame if needed
//           setState(() {});
//         });

//         return Stack(
//           clipBehavior: Clip.none,
//           children: [
//             // Assign the dynamic GlobalKey to widgetBase
//             widget.widgetBase is Container
//                 ? Container(
//                     key: _widgetBaseKey,
//                     child: widget.widgetBase,
//                   )
//                 : widget.widgetBase,
//             if (_buttonsVisible && widgetBaseSize != null)
//               ..._buildPositionedButtons(), // ← now NO bottom button here
//           ],
//         );
//       },
//     );
//   }

//   /* ---------------- size measurements ---------------- */
//   void _measureBaseSize() {
//     final box = _widgetBaseKey.currentContext?.findRenderObject() as RenderBox?;
//     if (box != null && widgetBaseSize != box.size) {
//       setState(() => widgetBaseSize = box.size);
//     }
//   }

//   void _measureBottomSize() {
//     if (widget.widgetBaseButtonBottom == null) return;
//     final box =
//         _buttonBottomKey.currentContext?.findRenderObject() as RenderBox?;
//     if (box != null && buttonBottomSize != box.size) {
//       setState(() => buttonBottomSize = box.size);
//     }
//   }

//   /* ---------------- overlay logic ---------------- */
//   void _insertOrUpdateBottomOverlay() {
//     if (!_buttonsVisible ||
//         widget.widgetBaseButtonBottom == null ||
//         widgetBaseSize == null) {
//       _removeBottomOverlay();
//       return;
//     }

//     final baseBox =
//         _widgetBaseKey.currentContext?.findRenderObject() as RenderBox?;
//     final overlay = Overlay.of(context);
//     if (baseBox == null) return;

//     // ---- use YOUR calculation verbatim ----
//     final double buttonW = buttonBottomSize?.width ?? 300.0;
//     final double buttonH = buttonBottomSize?.height ?? 50.0;

//     final Offset baseGlobal = baseBox.localToGlobal(Offset.zero);
//     final double left = baseGlobal.dx + (widgetBaseSize!.width - buttonW) / 2;
//     final double top =
//         baseGlobal.dy + (widgetBaseSize!.height - buttonH / 2) - 3;

//     final OverlayEntry entry = OverlayEntry(
//       builder: (_) => Positioned(
//         left: baseGlobal.dx + 25, // Add 25px margin from left
//         top: top,
//         width: widgetBaseSize!.width - 50, // Maintain original margin
//         child: Material(
//           // hit‑testing & theming
//           type: MaterialType.transparency,
//           child: Center(
//             child: Container(
//               key: _buttonBottomKey, // still measuring!
//               child: widget.widgetBaseButtonBottom!,
//             ),
//           ),
//         ),
//       ),
//     );

//     // replace or insert
//     if (_bottomOverlayEntry == null) {
//       _bottomOverlayEntry = entry;
//       overlay.insert(entry);
//     } else {
//       _bottomOverlayEntry!.remove();
//       _bottomOverlayEntry = entry;
//       overlay.insert(entry);
//     }
//   }

//   void _removeBottomOverlay() {
//     _bottomOverlayEntry?.remove();
//     _bottomOverlayEntry = null;
//   }

//   /* ---------------- positioned side buttons (unchanged) ---------------- */
//   List<Widget> _buildPositionedButtons() {
//     final double buttonW = buttonBottomSize?.width ?? 300.0;
//     final double buttonH = buttonBottomSize?.height ?? 50.0;

//     final b = <Widget>[];

//     // TOP
//     if (widget.widgetBaseButtonAtas != null) {
//       b.add(Positioned(
//         left: (widgetBaseSize!.width - buttonW) / 2,
//         top: -buttonH / 2,
//         child: widget.widgetBaseButtonAtas!,
//       ));
//     }
//     // LEFT
//     if (widget.widgetBaseButtonKiri != null) {
//       b.add(Positioned(
//         left: -buttonW / 2,
//         top: (widgetBaseSize!.height - buttonH) / 2,
//         child: widget.widgetBaseButtonKiri!,
//       ));
//     }
//     // RIGHT
//     if (widget.widgetBaseButtonKanan != null) {
//       b.add(Positioned(
//         left: widgetBaseSize!.width - buttonW / 2,
//         top: (widgetBaseSize!.height - buttonH) / 2,
//         child: widget.widgetBaseButtonKanan!,
//       ));
//     }
//     return b;
//   }

//   /* ---------------- clean‑up ---------------- */
//   @override
//   void dispose() {
//     _removeBottomOverlay();
//     super.dispose();
//   }
// }

// // import 'package:flutter/material.dart';
// //
// // class AutoPositionWidget extends StatefulWidget {
// //   final Widget widgetBase;
// //   final Widget? widgetBaseButtonBottom;
// //   final Widget? widgetBaseButtonKiri;
// //   final Widget? widgetBaseButtonKanan;
// //   final Widget? widgetBaseButtonAtas;
// //
// //   const AutoPositionWidget({
// //     super.key,
// //     required this.widgetBase,
// //     this.widgetBaseButtonBottom,
// //     this.widgetBaseButtonKiri,
// //     this.widgetBaseButtonKanan,
// //     this.widgetBaseButtonAtas,
// //   });
// //
// //   static _AutoPositionWidgetState? of(BuildContext context) {
// //     return context.findAncestorStateOfType<_AutoPositionWidgetState>();
// //   }
// //
// //   @override
// //   State<AutoPositionWidget> createState() => _AutoPositionWidgetState();
// // }
// //
// // class _AutoPositionWidgetState extends State<AutoPositionWidget> {
// //   Size? widgetBaseSize;
// //   Size? buttonBottomSize;
// //   bool _buttonsVisible = true;
// //
// //   final GlobalKey _widgetBaseKey = GlobalKey();
// //   final GlobalKey _buttonBottomKey = GlobalKey(); // keep this – we still use it
// //   final GlobalKey _buttonKiriKey = GlobalKey();
// //   final GlobalKey _buttonKananKey = GlobalKey();
// //   final GlobalKey _buttonAtasKey = GlobalKey();
// //
// //   OverlayEntry? _bottomOverlayEntry; // ⬅ NEW
// //
// //   /* ---------------- public helpers ---------------- */
// //   void hideButtons() {
// //     setState(() => _buttonsVisible = false);
// //     _removeBottomOverlay(); // keep overlay in sync
// //   }
// //
// //   void showButtons() {
// //     setState(() => _buttonsVisible = true);
// //     WidgetsBinding.instance
// //         .addPostFrameCallback((_) => _insertOrUpdateBottomOverlay());
// //   }
// //
// //   /* ---------------- widget tree ---------------- */
// //   @override
// //   Widget build(BuildContext context) {
// //     return LayoutBuilder(
// //       builder: (_, __) {
// //         WidgetsBinding.instance.addPostFrameCallback((_) {
// //           _measureBaseSize();
// //           _measureBottomSize();
// //           _insertOrUpdateBottomOverlay(); // every frame if needed
// //         });
// //
// //         return Stack(
// //           clipBehavior: Clip.none,
// //           children: [
// //             Container(
// //               // base widget (unchanged)
// //               key: _widgetBaseKey,
// //               child: widget.widgetBase,
// //             ),
// //             if (_buttonsVisible && widgetBaseSize != null)
// //               ..._buildPositionedButtons(), // ← now NO bottom button here
// //           ],
// //         );
// //       },
// //     );
// //   }
// //
// //   /* ---------------- size measurements ---------------- */
// //   void _measureBaseSize() {
// //     final box = _widgetBaseKey.currentContext?.findRenderObject() as RenderBox?;
// //     if (box != null && widgetBaseSize != box.size) {
// //       setState(() => widgetBaseSize = box.size);
// //     }
// //   }
// //
// //   void _measureBottomSize() {
// //     if (widget.widgetBaseButtonBottom == null) return;
// //     final box =
// //         _buttonBottomKey.currentContext?.findRenderObject() as RenderBox?;
// //     if (box != null && buttonBottomSize != box.size) {
// //       setState(() => buttonBottomSize = box.size);
// //     }
// //   }
// //
// //   /* ---------------- overlay logic ---------------- */
// //   void _insertOrUpdateBottomOverlay() {
// //     if (!_buttonsVisible ||
// //         widget.widgetBaseButtonBottom == null ||
// //         widgetBaseSize == null) {
// //       _removeBottomOverlay();
// //       return;
// //     }
// //
// //     final baseBox =
// //         _widgetBaseKey.currentContext?.findRenderObject() as RenderBox?;
// //     final overlay = Overlay.of(context);
// //     if (baseBox == null || overlay == null) return;
// //
// //     // ---- use YOUR calculation verbatim ----
// //     final double buttonW = buttonBottomSize?.width ?? 300.0;
// //     final double buttonH = buttonBottomSize?.height ?? 50.0;
// //
// //     final Offset baseGlobal = baseBox.localToGlobal(Offset.zero);
// //     final double left = baseGlobal.dx + (widgetBaseSize!.width - buttonW) / 2;
// //     // final double right = baseGlobal.dx + (widgetBaseSize!.width - buttonW) / 1;
// //     final double top =
// //         baseGlobal.dy + (widgetBaseSize!.height - buttonH / 2) - 3;
// //
// //     final OverlayEntry entry = OverlayEntry(
// //       builder: (_) => Positioned(
// //         left: left,
// //         // right: right,
// //         top: top,
// //         width: widgetBaseSize!.width - 50, // ← your original margin
// //         child: Material(
// //           // hit‑testing & theming
// //           type: MaterialType.transparency,
// //           child: Container(
// //             key: _buttonBottomKey, // still measuring!
// //             child: widget.widgetBaseButtonBottom!,
// //           ),
// //         ),
// //       ),
// //     );
// //
// //     // replace or insert
// //     if (_bottomOverlayEntry == null) {
// //       _bottomOverlayEntry = entry;
// //       overlay.insert(entry);
// //     } else {
// //       _bottomOverlayEntry!.remove();
// //       _bottomOverlayEntry = entry;
// //       overlay.insert(entry);
// //     }
// //   }
// //
// //   void _removeBottomOverlay() {
// //     _bottomOverlayEntry?..remove();
// //     _bottomOverlayEntry = null;
// //   }
// //
// //   /* ---------------- positioned side buttons (unchanged) ---------------- */
// //   List<Widget> _buildPositionedButtons() {
// //     final double buttonW = buttonBottomSize?.width ?? 300.0;
// //     final double buttonH = buttonBottomSize?.height ?? 50.0;
// //
// //     final b = <Widget>[];
// //
// //     // TOP
// //     if (widget.widgetBaseButtonAtas != null) {
// //       b.add(Positioned(
// //         left: (widgetBaseSize!.width - buttonW) / 2,
// //         top: -buttonH / 2,
// //         child: widget.widgetBaseButtonAtas!,
// //       ));
// //     }
// //     // LEFT
// //     if (widget.widgetBaseButtonKiri != null) {
// //       b.add(Positioned(
// //         left: -buttonW / 2,
// //         top: (widgetBaseSize!.height - buttonH) / 2,
// //         child: widget.widgetBaseButtonKiri!,
// //       ));
// //     }
// //     // RIGHT
// //     if (widget.widgetBaseButtonKanan != null) {
// //       b.add(Positioned(
// //         left: widgetBaseSize!.width - buttonW / 2,
// //         top: (widgetBaseSize!.height - buttonH) / 2,
// //         child: widget.widgetBaseButtonKanan!,
// //       ));
// //     }
// //     return b;
// //   }
// //
// //   /* ---------------- clean‑up ---------------- */
// //   @override
// //   void dispose() {
// //     _removeBottomOverlay();
// //     super.dispose();
// //   }
// // }

// class AutoPositionWidgetDailyBonus extends StatefulWidget {
//   final Widget widgetBase;
//   final Widget? widgetBaseButtonBottom;
//   final Widget? widgetBaseButtonKiri;
//   final Widget? widgetBaseButtonKanan;
//   final Widget? widgetBaseButtonAtas;

//   const AutoPositionWidgetDailyBonus({
//     super.key,
//     required this.widgetBase,
//     this.widgetBaseButtonBottom,
//     this.widgetBaseButtonKiri,
//     this.widgetBaseButtonKanan,
//     this.widgetBaseButtonAtas,
//   });

//   static _AutoPositionWidgetDailyBonusState? of(BuildContext context) {
//     return context
//         .findAncestorStateOfType<_AutoPositionWidgetDailyBonusState>();
//   }

//   @override
//   State<AutoPositionWidgetDailyBonus> createState() =>
//       _AutoPositionWidgetDailyBonusState();
// }

// class _AutoPositionWidgetDailyBonusState
//     extends State<AutoPositionWidgetDailyBonus> {
//   Size? widgetBaseSize;
//   Size? buttonBottomSize;
//   Size? buttonTopSize;

//   bool _buttonsVisible = true;

//   GlobalKey _widgetBaseKey = GlobalKey();
//   GlobalKey _buttonBottomKey = GlobalKey();
//   GlobalKey _buttonKiriKey = GlobalKey();
//   GlobalKey _buttonKananKey = GlobalKey();
//   GlobalKey _buttonAtasKey = GlobalKey();

//   void hideButtons() {
//     setState(() => _buttonsVisible = false);
//   }

//   void showButtons() {
//     setState(() => _buttonsVisible = true);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         // Use a post-frame callback to get the size after the layout is complete
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           // Get the size of widgetBase using the dynamic GlobalKey
//           final renderBoxBase =
//               _widgetBaseKey.currentContext?.findRenderObject() as RenderBox?;
//           if (renderBoxBase != null) {
//             final newSize = renderBoxBase.size;
//             if (widgetBaseSize != newSize) {
//               setState(() {
//                 widgetBaseSize = newSize;
//               });
//             }
//           }
// // Get the size of widgetBaseButtonAtas using the dynamic GlobalKey
//           if (widget.widgetBaseButtonAtas != null) {
//             final renderBoxButtonTop =
//                 _buttonAtasKey.currentContext?.findRenderObject() as RenderBox?;
//             if (renderBoxButtonTop != null) {
//               final newTopSize = renderBoxButtonTop.size;
//               if (buttonTopSize != newTopSize) {
//                 setState(() {
//                   buttonTopSize = newTopSize;
//                 });
//               }
//             }
//           }

//           // Get the size of widgetBaseButtonBottom using the dynamic GlobalKey
//           if (widget.widgetBaseButtonBottom != null) {
//             final renderBoxButtonBottom = _buttonBottomKey.currentContext
//                 ?.findRenderObject() as RenderBox?;
//             if (renderBoxButtonBottom != null) {
//               final newButtonSize = renderBoxButtonBottom.size;
//               if (buttonBottomSize != newButtonSize) {
//                 setState(() {
//                   buttonBottomSize = newButtonSize;
//                 });
//               }
//             }
//           }
//         });

//         return Stack(
//           clipBehavior: Clip.none,
//           children: [
//             // Assign the dynamic GlobalKey to widgetBase
//             widget.widgetBase is Container
//                 ? Container(
//                     key: _widgetBaseKey,
//                     child: widget.widgetBase,
//                   )
//                 : widget.widgetBase,
//             if (_buttonsVisible && widgetBaseSize != null)
//               ..._buildPositionedButtons(),
//           ],
//         );
//       },
//     );
//   }

//   List<Widget> _buildPositionedButtons() {
//     double buttonWidth = 300.0; // Default width for button
//     double buttonHeight = 50.0; // Default height for button

//     // Adjust buttonWidth dynamically based on the size of widgetBaseButtonBottom
//     if (buttonBottomSize != null) {
//       buttonWidth = buttonBottomSize!
//           .width; // Set the button width based on the bottom button's width
//       buttonHeight = buttonBottomSize!
//           .height; // Set the button height dynamically based on the height of the bottom button
//     }
//     if (buttonTopSize != null) {
//       buttonWidth = buttonTopSize!
//           .width; // Set the button width based on the bottom button's width
//       buttonHeight = buttonTopSize!
//           .height; // Set the button height dynamically based on the height of the bottom button
//     }
//     final buttons = <Widget>[];

//     if (widget.widgetBaseButtonAtas != null) {
//       final double containerWidth = widgetBaseSize!.width - 25;

//       buttons.add(
//         Positioned(
//           left: (widgetBaseSize!.width - containerWidth) / 2, // ← konsisten
//           top: (-buttonHeight / 2) + 45,
//           child: Container(
//             key: _buttonAtasKey,
//             width: containerWidth, // sama persis
//             child: widget.widgetBaseButtonAtas!,
//           ),
//         ),
//       );
//     }

//     if (widget.widgetBaseButtonKiri != null) {
//       buttons.add(
//         Positioned(
//           left: -buttonWidth / 2,
//           top: (widgetBaseSize!.height - buttonHeight) / 2,
//           child: widget.widgetBaseButtonKiri!,
//         ),
//       );
//     }

//     if (widget.widgetBaseButtonKanan != null) {
//       buttons.add(
//         Positioned(
//           left: widgetBaseSize!.width - buttonWidth / 2,
//           top: (widgetBaseSize!.height - buttonHeight) / 2,
//           child: widget.widgetBaseButtonKanan!,
//         ),
//       );
//     }

//     return buttons;
//   }
// }

// // import 'package:flutter/material.dart';
// //
// // class AutoPositionWidgetDailyBonus extends StatefulWidget {
// //   final Widget widgetBase;
// //   final Widget? widgetBaseButtonBottom;
// //   final Widget? widgetBaseButtonKiri;
// //   final Widget? widgetBaseButtonKanan;
// //   final Widget? widgetBaseButtonAtas;
// //
// //   const AutoPositionWidgetDailyBonus({
// //     super.key,
// //     required this.widgetBase,
// //     this.widgetBaseButtonBottom,
// //     this.widgetBaseButtonKiri,
// //     this.widgetBaseButtonKanan,
// //     this.widgetBaseButtonAtas,
// //   });
// //
// //   static _AutoPositionWidgetDailyBonusState? of(BuildContext context) {
// //     return context.findAncestorStateOfType<_AutoPositionWidgetDailyBonusState>();
// //   }
// //
// //   @override
// //   State<AutoPositionWidgetDailyBonus> createState() => _AutoPositionWidgetDailyBonusState();
// // }
// //
// // class _AutoPositionWidgetDailyBonusState extends State<AutoPositionWidgetDailyBonus> {
// //   Size? widgetBaseSize;
// //   Size? buttonBottomSize;
// //   bool _buttonsVisible = true;
// //
// //   final GlobalKey _widgetBaseKey = GlobalKey();
// //   final GlobalKey _buttonBottomKey = GlobalKey(); // keep this – we still use it
// //   final GlobalKey _buttonKiriKey = GlobalKey();
// //   final GlobalKey _buttonKananKey = GlobalKey();
// //   final GlobalKey _buttonAtasKey = GlobalKey();
// //
// //   OverlayEntry? _bottomOverlayEntry; // ⬅ NEW
// //
// //   /* ---------------- public helpers ---------------- */
// //   void hideButtons() {
// //     setState(() => _buttonsVisible = false);
// //     _removeBottomOverlay(); // keep overlay in sync
// //   }
// //
// //   void showButtons() {
// //     setState(() => _buttonsVisible = true);
// //     WidgetsBinding.instance
// //         .addPostFrameCallback((_) => _insertOrUpdateBottomOverlay());
// //   }
// //
// //   /* ---------------- widget tree ---------------- */
// //   @override
// //   Widget build(BuildContext context) {
// //     return LayoutBuilder(
// //       builder: (_, __) {
// //         WidgetsBinding.instance.addPostFrameCallback((_) {
// //           _measureBaseSize();
// //           _measureBottomSize();
// //           _insertOrUpdateBottomOverlay(); // every frame if needed
// //         });
// //
// //         return Stack(
// //           clipBehavior: Clip.none,
// //           children: [
// //             Container(
// //               // base widget (unchanged)
// //               key: _widgetBaseKey,
// //               child: widget.widgetBase,
// //             ),
// //             if (_buttonsVisible && widgetBaseSize != null)
// //               ..._buildPositionedButtons(), // ← now NO bottom button here
// //           ],
// //         );
// //       },
// //     );
// //   }
// //
// //   /* ---------------- size measurements ---------------- */
// //   void _measureBaseSize() {
// //     final box = _widgetBaseKey.currentContext?.findRenderObject() as RenderBox?;
// //     if (box != null && widgetBaseSize != box.size) {
// //       setState(() => widgetBaseSize = box.size);
// //     }
// //   }
// //
// //   void _measureBottomSize() {
// //     if (widget.widgetBaseButtonBottom == null) return;
// //     final box =
// //         _buttonBottomKey.currentContext?.findRenderObject() as RenderBox?;
// //     if (box != null && buttonBottomSize != box.size) {
// //       setState(() => buttonBottomSize = box.size);
// //     }
// //   }
// //
// //   /* ---------------- overlay logic ---------------- */
// //   void _insertOrUpdateBottomOverlay() {
// //     if (!_buttonsVisible ||
// //         widget.widgetBaseButtonBottom == null ||
// //         widgetBaseSize == null) {
// //       _removeBottomOverlay();
// //       return;
// //     }
// //
// //     final baseBox =
// //         _widgetBaseKey.currentContext?.findRenderObject() as RenderBox?;
// //     final overlay = Overlay.of(context);
// //     if (baseBox == null || overlay == null) return;
// //
// //     // ---- use YOUR calculation verbatim ----
// //     final double buttonW = buttonBottomSize?.width ?? 300.0;
// //     final double buttonH = buttonBottomSize?.height ?? 50.0;
// //
// //     final Offset baseGlobal = baseBox.localToGlobal(Offset.zero);
// //     final double left = baseGlobal.dx + (widgetBaseSize!.width - buttonW) / 2;
// //     // final double right = baseGlobal.dx + (widgetBaseSize!.width - buttonW) / 1;
// //     final double top =
// //         baseGlobal.dy + (widgetBaseSize!.height - buttonH / 2) - 3;
// //
// //     final OverlayEntry entry = OverlayEntry(
// //       builder: (_) => Positioned(
// //         left: left,
// //         // right: right,
// //         top: top,
// //         width: widgetBaseSize!.width - 50, // ← your original margin
// //         child: Material(
// //           // hit‑testing & theming
// //           type: MaterialType.transparency,
// //           child: Container(
// //             key: _buttonBottomKey, // still measuring!
// //             child: widget.widgetBaseButtonBottom!,
// //           ),
// //         ),
// //       ),
// //     );
// //
// //     // replace or insert
// //     if (_bottomOverlayEntry == null) {
// //       _bottomOverlayEntry = entry;
// //       overlay.insert(entry);
// //     } else {
// //       _bottomOverlayEntry!.remove();
// //       _bottomOverlayEntry = entry;
// //       overlay.insert(entry);
// //     }
// //   }
// //
// //   void _removeBottomOverlay() {
// //     _bottomOverlayEntry?..remove();
// //     _bottomOverlayEntry = null;
// //   }
// //
// //   /* ---------------- positioned side buttons (unchanged) ---------------- */
// //   List<Widget> _buildPositionedButtons() {
// //     final double buttonW = buttonBottomSize?.width ?? 300.0;
// //     final double buttonH = buttonBottomSize?.height ?? 50.0;
// //
// //     final b = <Widget>[];
// //
// //     // TOP
// //     if (widget.widgetBaseButtonAtas != null) {
// //       b.add(Positioned(
// //         left: (widgetBaseSize!.width - buttonW) / 2,
// //         top: -buttonH / 2,
// //         child: widget.widgetBaseButtonAtas!,
// //       ));
// //     }
// //     // LEFT
// //     if (widget.widgetBaseButtonKiri != null) {
// //       b.add(Positioned(
// //         left: -buttonW / 2,
// //         top: (widgetBaseSize!.height - buttonH) / 2,
// //         child: widget.widgetBaseButtonKiri!,
// //       ));
// //     }
// //     // RIGHT
// //     if (widget.widgetBaseButtonKanan != null) {
// //       b.add(Positioned(
// //         left: widgetBaseSize!.width - buttonW / 2,
// //         top: (widgetBaseSize!.height - buttonH) / 2,
// //         child: widget.widgetBaseButtonKanan!,
// //       ));
// //     }
// //     return b;
// //   }
// //
// //   /* ---------------- clean‑up ---------------- */
// //   @override
// //   void dispose() {
// //     _removeBottomOverlay();
// //     super.dispose();
// //   }
// // }
