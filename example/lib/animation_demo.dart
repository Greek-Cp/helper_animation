import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:helper_animation/helper_animation_library.dart';

class AnimationDemo extends StatefulWidget {
  const AnimationDemo({Key? key}) : super(key: key);

  @override
  State<AnimationDemo> createState() => _AnimationDemoState();
}

class _AnimationDemoState extends State<AnimationDemo>
    with TickerProviderStateMixin {
  // Basic animation parameters
  AnimationType _currentType = AnimationType.firework;
  AnimationPosition _position = AnimationPosition.outside;
  Color _effectColor = const Color(0xFF8BB3C5);

  // Advanced parameters
  double _radiusMultiplier = 1.0;
  bool _useCustomOffset = false;
  double _offsetX = 0.0;
  double _offsetY = 0.0;
  bool _repeatWhenDrag = true;
  bool _autoAnimate = false;
  int _durationMs = 2400; // Animation duration in milliseconds

  // UI state
  bool _showCodePreview = false;
  bool _showAdvancedOptions = false;

  // Colors for color picker
  final List<Color> _presetColors = [
    const Color(0xFF8BB3C5), // Default blue
    Colors.yellow,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
  ];

  // Controller for preview scaling animation
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  // Generate code for copying
  String _generateCode() {
    final buffer = StringBuffer();

    buffer.writeln('Widget yourWidget = Container(');
    buffer.writeln('  // Your widget properties here');
    buffer.writeln(').withEffectAnimation(');
    buffer.writeln(
        '  animationType: AnimationType.${_currentType.toString().split('.').last},');

    // Only include non-default values to keep code clean
    if (_effectColor != const Color(0xFF8BB3C5)) {
      buffer.writeln(
          '  effectColor: const Color(0x${_effectColor.value.toRadixString(16).toUpperCase()}),');
    }

    if (_radiusMultiplier != 1.0) {
      buffer.writeln('  radiusMultiplier: $_radiusMultiplier,');
    }

    if (_position != AnimationPosition.outside) {
      buffer.writeln(
          '  position: AnimationPosition.${_position.toString().split('.').last},');
    }

    if (_useCustomOffset && (_offsetX != 0 || _offsetY != 0)) {
      buffer.writeln('  customOffset: Offset($_offsetX, $_offsetY),');
    }

    if (_durationMs != 2400) {
      buffer.writeln('  duration: const Duration(milliseconds: $_durationMs),');
    }

    if (_repeatWhenDrag != true) {
      buffer.writeln('  repeatWhenDrag: false,');
    }

    if (_autoAnimate != false) {
      buffer.writeln('  autoAnimate: true,');
    }

    buffer.writeln(');');

    return buffer.toString();
  }

  // Copy to clipboard
  void _copyCodeToClipboard() {
    final code = _generateCode();
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copied to clipboard!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        width: 200,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Animation Gallery',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple.shade800,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showCodePreview ? Icons.code_off : Icons.code,
              color: Colors.white,
            ),
            tooltip: _showCodePreview ? 'Hide Code' : 'Show Code',
            onPressed: () {
              setState(() {
                _showCodePreview = !_showCodePreview;
              });
            },
          ),
          IconButton(
            icon: Icon(
              _showAdvancedOptions ? Icons.tune : Icons.tune_outlined,
              color: Colors.white,
            ),
            tooltip: _showAdvancedOptions
                ? 'Hide Advanced Options'
                : 'Show Advanced Options',
            onPressed: () {
              setState(() {
                _showAdvancedOptions = !_showAdvancedOptions;
              });
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.help_outline,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('How to Use'),
                  content: const Text(
                      'Explore different animations, customize parameters, and copy the code for use in your projects.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade900,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade800, Colors.black],
          ),
        ),
        child: SafeArea(
          child: isLandscape && !isSmallScreen
              ? _buildLandscapeLayout(screenSize)
              : _buildPortraitLayout(screenSize),
        ),
      ),
      bottomNavigationBar: Container(
        height: 40,
        color: Colors.black,
        child: Center(
          child: Text(
            'Animation Gallery v1.0',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  // Layout for landscape orientation on larger screens
  Widget _buildLandscapeLayout(Size screenSize) {
    return Row(
      children: [
        // Left side: Preview
        Expanded(
          flex: 1,
          child: _buildPreviewSection(),
        ),

        // Right side: Controls (and Code Preview if shown)
        Expanded(
          flex: 1,
          child: Column(
            children: [
              if (_showCodePreview)
                Expanded(
                  flex: 2,
                  child: _buildCodePreviewSection(),
                ),
              Expanded(
                flex: _showCodePreview ? 3 : 5,
                child: _buildControlsSection(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Layout for portrait orientation or small screens
  Widget _buildPortraitLayout(Size screenSize) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            children: [
              // Preview section at top (smaller in portrait)
              SizedBox(
                height: screenSize.height * 0.4, // 40% of screen height
                child: _buildPreviewSection(),
              ),

              // Code preview if shown
              if (_showCodePreview)
                SizedBox(
                  height: screenSize.height * 0.25, // 25% of screen height
                  child: _buildCodePreviewSection(),
                ),

              // Controls section (expanding to fill remaining space)
              Expanded(
                child: _buildControlsSection(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Preview section widget
  Widget _buildPreviewSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PREVIEW',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(flex: 1),

            // Animation Preview Widget
            Center(
              child: MouseRegion(
                onEnter: (_) => _scaleController.forward(),
                onExit: (_) => _scaleController.reverse(),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Draggable(
                    feedback: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: _effectColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _effectColor.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Tap Me',
                          style: TextStyle(
                            color: _getContrastColor(_effectColor),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _effectColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _effectColor.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Tap Me',
                        style: TextStyle(
                          color: _getContrastColor(_effectColor),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ).withEffectAnimation(
                    animationType: _currentType,
                    effectColor: _effectColor,
                    autoAnimate: _autoAnimate,
                    repeatWhenDrag: _repeatWhenDrag,
                    radiusMultiplier: _radiusMultiplier,
                    position: _position,
                    customOffset: _useCustomOffset
                        ? Offset(_offsetX, _offsetY)
                        : Offset.zero,
                    duration: Duration(milliseconds: _durationMs),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Text(
              _autoAnimate ? 'Auto-animating' : 'Tap to see animation',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),

            const Spacer(flex: 1),

            // Animation info
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    '${_currentType.toString().split('.').last}',
                    style: TextStyle(
                      color: _effectColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${_position.toString().split('.').last}${_useCustomOffset ? ' (Custom)' : ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Duration: ${_durationMs}ms',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Copy button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _effectColor,
                foregroundColor: _getContrastColor(_effectColor),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _copyCodeToClipboard,
              icon: const Icon(Icons.copy),
              label: const Text('Copy Code'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get contrasting text color for a background
  Color _getContrastColor(Color backgroundColor) {
    // Calculate luminance - if color is bright, return dark text, otherwise light text
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }

  // Code preview section
  Widget _buildCodePreviewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: CodePreview(
        code: _generateCode(),
        onCopy: _copyCodeToClipboard,
      ),
    );
  }

  // Controls section widget
  Widget _buildControlsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MultiDragTargetExample(),
                        ),
                      );
                    },
                    child: Text("Test Drag Drop")),
                const Text(
                  'ANIMATION SETTINGS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 10),

                // Basic Settings
                _buildBasicSettings(),

                // Advanced Settings
                if (_showAdvancedOptions) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'ADVANCED OPTIONS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Divider(color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 10),
                  _buildAdvancedSettings(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Basic animation settings
  Widget _buildBasicSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animation Type Dropdown
        _buildSettingRow(
          'Animation Type',
          DropdownButton<AnimationType>(
            value: _currentType,
            isExpanded: true,
            dropdownColor: Colors.grey.shade800,
            underline: Container(
              height: 1,
              color: Colors.deepPurple.shade200,
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: (AnimationType? newValue) {
              if (newValue != null) {
                setState(() {
                  _currentType = newValue;
                });
              }
            },
            items: AnimationType.values.map((AnimationType type) {
              return DropdownMenuItem<AnimationType>(
                value: type,
                child: Text(
                  type.toString().split('.').last,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Position Dropdown
        _buildSettingRow(
          'Position',
          DropdownButton<AnimationPosition>(
            value: _position,
            isExpanded: true,
            dropdownColor: Colors.grey.shade800,
            underline: Container(
              height: 1,
              color: Colors.deepPurple.shade200,
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: (AnimationPosition? newValue) {
              if (newValue != null) {
                setState(() {
                  _position = newValue;
                  // Reset custom offset when changing position
                  _useCustomOffset = false;
                });
              }
            },
            items: AnimationPosition.values.map((AnimationPosition pos) {
              return DropdownMenuItem<AnimationPosition>(
                value: pos,
                child: Text(
                  pos.toString().split('.').last,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Effect Color
        _buildSettingRow(
          'Effect Color',
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._presetColors.map((color) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _effectColor = color;
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _effectColor == color
                              ? Colors.white
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  )),
              // Custom color picker option
              GestureDetector(
                onTap: () {
                  // Show a dialog with more color options or a color picker
                  _showColorPickerDialog();
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.red, Colors.green, Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Advanced animation settings
  Widget _buildAdvancedSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Duration Slider
        _buildSettingRow(
          'Duration (ms)',
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Colors.deepPurple.shade300,
                    inactiveTrackColor:
                        Colors.deepPurple.shade100.withOpacity(0.3),
                    thumbColor: _effectColor,
                    overlayColor: _effectColor.withOpacity(0.3),
                    valueIndicatorColor: Colors.deepPurple,
                    valueIndicatorTextStyle:
                        const TextStyle(color: Colors.white),
                  ),
                  child: Slider(
                    value: _durationMs.toDouble(),
                    min: 500,
                    max: 5000,
                    divisions: 45,
                    label: _durationMs.toString(),
                    onChanged: (value) {
                      setState(() {
                        _durationMs = value.toInt();
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  _durationMs.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Auto Animate Toggle
        _buildSettingRow(
          'Auto Animate',
          Switch(
            value: _autoAnimate,
            activeColor: _effectColor,
            activeTrackColor: Colors.deepPurple.shade300,
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade700,
            onChanged: (value) {
              setState(() {
                _autoAnimate = value;
              });
            },
          ),
        ),

        const SizedBox(height: 16),

        // Repeat When Drag Toggle
        _buildSettingRow(
          'Repeat When Drag',
          Switch(
            value: _repeatWhenDrag,
            activeColor: _effectColor,
            activeTrackColor: Colors.deepPurple.shade300,
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade700,
            onChanged: (value) {
              setState(() {
                _repeatWhenDrag = value;
              });
            },
          ),
        ),

        const SizedBox(height: 16),

        // Radius Multiplier Slider
        _buildSettingRow(
          'Radius Multiplier',
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Colors.deepPurple.shade300,
                    inactiveTrackColor:
                        Colors.deepPurple.shade100.withOpacity(0.3),
                    thumbColor: _effectColor,
                    overlayColor: _effectColor.withOpacity(0.3),
                    valueIndicatorColor: Colors.deepPurple,
                    valueIndicatorTextStyle:
                        const TextStyle(color: Colors.white),
                  ),
                  child: Slider(
                    value: _radiusMultiplier,
                    min: 0.5,
                    max: 3.0,
                    divisions: 25,
                    label: _radiusMultiplier.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _radiusMultiplier = value;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  _radiusMultiplier.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Custom Offset Switch
        _buildSettingRow(
          'Custom Offset',
          Switch(
            value: _useCustomOffset,
            activeColor: _effectColor,
            activeTrackColor: Colors.deepPurple.shade300,
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade700,
            onChanged: (value) {
              setState(() {
                _useCustomOffset = value;
              });
            },
          ),
        ),

        if (_useCustomOffset) ...[
          const SizedBox(height: 16),

          // X Offset Slider
          _buildSettingRow(
            'Offset X',
            Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: Colors.deepPurple.shade300,
                      inactiveTrackColor:
                          Colors.deepPurple.shade100.withOpacity(0.3),
                      thumbColor: _effectColor,
                      overlayColor: _effectColor.withOpacity(0.3),
                      valueIndicatorColor: Colors.deepPurple,
                      valueIndicatorTextStyle:
                          const TextStyle(color: Colors.white),
                    ),
                    child: Slider(
                      value: _offsetX,
                      min: -100,
                      max: 100,
                      divisions: 20,
                      label: _offsetX.toStringAsFixed(0),
                      onChanged: (value) {
                        setState(() {
                          _offsetX = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    '${_offsetX.toStringAsFixed(0)}px',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Y Offset Slider
          _buildSettingRow(
            'Offset Y',
            Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: Colors.deepPurple.shade300,
                      inactiveTrackColor:
                          Colors.deepPurple.shade100.withOpacity(0.3),
                      thumbColor: _effectColor,
                      overlayColor: _effectColor.withOpacity(0.3),
                      valueIndicatorColor: Colors.deepPurple,
                      valueIndicatorTextStyle:
                          const TextStyle(color: Colors.white),
                    ),
                    child: Slider(
                      value: _offsetY,
                      min: -100,
                      max: 100,
                      divisions: 20,
                      label: _offsetY.toStringAsFixed(0),
                      onChanged: (value) {
                        setState(() {
                          _offsetY = value;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    '${_offsetY.toStringAsFixed(0)}px',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Show color picker dialog
  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        Color selectedColor = _effectColor;

        return AlertDialog(
          title: const Text('Select Color'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Simple grid of color options
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ...[
                      Colors.red,
                      Colors.pink,
                      Colors.purple,
                      Colors.deepPurple,
                      Colors.indigo,
                      Colors.blue,
                      Colors.lightBlue,
                      Colors.cyan,
                      Colors.teal,
                      Colors.green,
                      Colors.lightGreen,
                      Colors.lime,
                      Colors.yellow,
                      Colors.amber,
                      Colors.orange,
                      Colors.deepOrange,
                      Colors.brown,
                      Colors.grey,
                      Colors.blueGrey,
                      Colors.black,
                      // Lighter shades
                      Colors.red.shade300,
                      Colors.pink.shade300,
                      Colors.purple.shade300,
                      Colors.deepPurple.shade300,
                      Colors.indigo.shade300,
                      Colors.blue.shade300,
                      Colors.lightBlue.shade300,
                      Colors.cyan.shade300,
                      Colors.teal.shade300,
                      Colors.green.shade300,
                      Colors.lightGreen.shade300,
                      Colors.lime.shade300,
                      Colors.yellow.shade300,
                      Colors.amber.shade300,
                      Colors.orange.shade300,
                      Colors.deepOrange.shade300,
                    ].map((color) => GestureDetector(
                          onTap: () {
                            selectedColor = color;
                            Navigator.of(context).pop(color);
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    ).then((color) {
      if (color != null) {
        setState(() {
          _effectColor = color;
        });
      }
    });
  }

  // Helper method to build setting rows
  Widget _buildSettingRow(String label, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}

class CodePreview extends StatefulWidget {
  final String code;
  final VoidCallback onCopy;

  const CodePreview({
    Key? key,
    required this.code,
    required this.onCopy,
  }) : super(key: key);

  @override
  State<CodePreview> createState() => _CodePreviewState();
}

class _CodePreviewState extends State<CodePreview> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade800,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Generated Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isExpanded ? Icons.unfold_less : Icons.unfold_more,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      tooltip: _isExpanded ? 'Collapse' : 'Expand',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(
                        Icons.content_copy,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: widget.onCopy,
                      tooltip: 'Copy to clipboard',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Code content
          AnimatedCrossFade(
            firstChild: Container(
              height: 0,
              width: double.infinity,
            ),
            secondChild: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the code with syntax highlighting
                    SelectableText(
                      widget.code,
                      style: const TextStyle(
                        color: Colors.lightGreenAccent,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

class MultiDragTargetExample extends StatefulWidget {
  const MultiDragTargetExample({Key? key}) : super(key: key);

  @override
  State<MultiDragTargetExample> createState() => _MultiDragTargetExampleState();
}

class _MultiDragTargetExampleState extends State<MultiDragTargetExample> {
  // Data untuk draggable items
  final List<Map<String, dynamic>> _items = [
    {'id': '1', 'name': 'Item 1', 'color': Colors.red},
    {'id': '2', 'name': 'Item 2', 'color': Colors.blue},
    {'id': '3', 'name': 'Item 3', 'color': Colors.green},
    {'id': '4', 'name': 'Item 4', 'color': Colors.orange},
  ];

  // Data untuk drop targets
  final List<Map<String, dynamic>> _targets = [
    {
      'id': 'target1',
      'name': 'Target 1',
      'position': 'top-left',
      'itemId': null
    },
    {
      'id': 'target2',
      'name': 'Target 2',
      'position': 'top-right',
      'itemId': null
    },
    {
      'id': 'target3',
      'name': 'Target 3',
      'position': 'bottom-left',
      'itemId': null
    },
    {
      'id': 'target4',
      'name': 'Target 4',
      'position': 'bottom-right',
      'itemId': null
    },
  ];

  // Satu controller untuk setiap target
  final Map<String, EffectAnimationController> _controllers = {
    'target1': EffectAnimationController(),
    'target2': EffectAnimationController(),
    'target3': EffectAnimationController(),
    'target4': EffectAnimationController(),
  };

  // Pengaturan animasi
  AnimationType _animationType = AnimationType.firework;
  double _radiusMultiplier = 1.8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drag & Drop Targets'),
        backgroundColor: Colors.deepPurple.shade800,
      ),
      body: Stack(
        children: [
          // Main content
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepPurple.shade800,
                  Colors.deepPurple.shade900
                ],
              ),
            ),
            child: Column(
              children: [
                // Draggable Items (di bagian atas)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Drag items to the targets below:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _items.map((item) {
                          // Check if this item is already dropped in any target
                          bool isDropped = _targets
                              .any((target) => target['itemId'] == item['id']);

                          return Opacity(
                            opacity: isDropped ? 0.5 : 1.0,
                            child: Draggable<Map<String, dynamic>>(
                              data: item,
                              feedback: Material(
                                color: Colors.transparent,
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: item['color'].withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      item['name'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: item['color'],
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    item['name'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Drop targets (di bagian bawah tanpa grid)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stack(
                      children: _targets.map((target) {
                        final targetId = target['id'];
                        final droppedItemId = target['itemId'];
                        final position = target['position'];

                        // Get color and name info if an item is dropped here
                        Color targetColor = Colors.grey.shade800;
                        String targetText = target['name'];

                        if (droppedItemId != null) {
                          final droppedItem = _items.firstWhere(
                              (item) => item['id'] == droppedItemId);
                          targetColor = droppedItem['color'];
                          targetText = droppedItem['name'];
                        }

                        // Posisi berdasarkan properti position
                        Alignment alignment;
                        switch (position) {
                          case 'top-left':
                            alignment = Alignment.topLeft;
                            break;
                          case 'top-right':
                            alignment = Alignment.topRight;
                            break;
                          case 'bottom-left':
                            alignment = Alignment.bottomLeft;
                            break;
                          case 'bottom-right':
                            alignment = Alignment.bottomRight;
                            break;
                          default:
                            alignment = Alignment.center;
                        }

                        return Align(
                          alignment: alignment,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: DragTarget<Map<String, dynamic>>(
                              onWillAccept: (data) {
                                // Only accept if no item is already here
                                return target['itemId'] == null;
                              },
                              onAccept: (item) {
                                setState(() {
                                  // First, check if this item is already in another target
                                  for (var t in _targets) {
                                    if (t['itemId'] == item['id']) {
                                      t['itemId'] =
                                          null; // Remove from previous target
                                    }
                                  }

                                  // Then place it in this target
                                  target['itemId'] = item['id'];
                                });

                                // Trigger animation
                                _controllers[targetId]?.triggerAnimation();
                              },
                              builder: (context, candidateData, rejectedData) {
                                final bool isTargeted =
                                    candidateData.isNotEmpty;

                                return Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: targetColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isTargeted
                                          ? Colors.white
                                          : Colors.white30,
                                      width: isTargeted ? 3 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        targetText,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ).withEffectAnimation(
                                  // Gunakan nilai dari state class
                                  animationType: _animationType,
                                  effectColor: droppedItemId != null
                                      ? _items.firstWhere((item) =>
                                          item['id'] == droppedItemId)['color']
                                      : Colors.blueAccent,
                                  customOffset: Offset.zero,
                                  radiusMultiplier: _radiusMultiplier,
                                  controller: _controllers[targetId],
                                  duration: const Duration(
                                      milliseconds:
                                          1200), // Durasi lebih pendek
                                );
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Reset button
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        // Reset all targets
                        for (var target in _targets) {
                          target['itemId'] = null;
                        }
                      });
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Reset All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Panel pengaturan melayang
          FloatingAnimationPanel(
            currentType: _animationType,
            currentRadius: _radiusMultiplier,
            onTypeChanged: (type) {
              setState(() {
                _animationType = type;
              });
            },
            onRadiusChanged: (radius) {
              setState(() {
                _radiusMultiplier = radius;
              });
            },
            onPreviewTap: () {
              // Trigger semua controller animasi untuk preview
              _controllers.forEach((key, controller) {
                controller.triggerAnimation();
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose semua controllers jika diperlukan
    super.dispose();
  }
}

/// Panel pengaturan animasi yang melayang di bagian bawah layar
class FloatingAnimationPanel extends StatefulWidget {
  final AnimationType currentType;
  final double currentRadius;
  final Function(AnimationType) onTypeChanged;
  final Function(double) onRadiusChanged;
  final VoidCallback onPreviewTap;

  const FloatingAnimationPanel({
    Key? key,
    required this.currentType,
    required this.currentRadius,
    required this.onTypeChanged,
    required this.onRadiusChanged,
    required this.onPreviewTap,
  }) : super(key: key);

  @override
  State<FloatingAnimationPanel> createState() => _FloatingAnimationPanelState();
}

class _FloatingAnimationPanelState extends State<FloatingAnimationPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Panel yang dapat diexpand/collapse
          if (_isExpanded)
            Container(
              width: 280,
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header panel
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Animation Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.play_circle_outline,
                            color: Colors.white),
                        onPressed: widget.onPreviewTap,
                        tooltip: 'Preview Animation',
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                  Divider(color: Colors.white.withOpacity(0.3)),
                  SizedBox(height: 8),

                  // Dropdown untuk memilih tipe animasi
                  Text('Animation Type:',
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<AnimationType>(
                      value: widget.currentType,
                      isExpanded: true,
                      dropdownColor: Colors.black.withOpacity(0.8),
                      underline: Container(),
                      style: TextStyle(color: Colors.white),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                      items: AnimationType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getDisplayName(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          widget.onTypeChanged(value);
                        }
                      },
                    ),
                  ),

                  SizedBox(height: 16),

                  // Slider untuk radius
                  Row(
                    children: [
                      Text('Radius:', style: TextStyle(color: Colors.white70)),
                      Expanded(
                        child: Slider(
                          value: widget.currentRadius,
                          min: 0.5,
                          max: 3.0,
                          divisions: 25,
                          label: widget.currentRadius.toStringAsFixed(1),
                          activeColor: Colors.deepPurple,
                          inactiveColor: Colors.deepPurple.withOpacity(0.3),
                          onChanged: widget.onRadiusChanged,
                        ),
                      ),
                      Text(
                        widget.currentRadius.toStringAsFixed(1),
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Tombol untuk toggle panel
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade600,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isExpanded ? Icons.close : Icons.settings,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _isExpanded ? 'Close' : 'Animation Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method untuk mendapatkan nama display yang lebih baik dari AnimationType
  String _getDisplayName(AnimationType type) {
    switch (type) {
      case AnimationType.firework:
        return 'Firework';
      case AnimationType.ripple:
        return 'Ripple';
      default:
        return type.toString().split('.').last;
    }
  }
}
