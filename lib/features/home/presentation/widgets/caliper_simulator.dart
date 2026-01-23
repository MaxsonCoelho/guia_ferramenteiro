import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CaliperSimulator extends StatefulWidget {
  const CaliperSimulator({super.key});

  @override
  State<CaliperSimulator> createState() => _CaliperSimulatorState();
}

class _CaliperSimulatorState extends State<CaliperSimulator> {
  // Current measurement in millimeters (absolute position)
  double _measurement = 0.0;
  // Maximum measurement (15cm)
  final double _maxMeasurement = 150.0;
  // Scale factor (pixels per mm) - "Zoom" for didactic purposes
  final double _pixelsPerMm = 10.0;
  
  // State variables
  bool _isMetric = true; // true = mm, false = inch
  double _zeroOffset = 0.0; // For ZERO button
  bool _isHold = false; // For HOLD button
  double _heldValue = 0.0; // Value captured when HOLD was pressed
  DateTime? _lastUpdate; // Throttling updates
  
  // Resolution logic
  // Metric: 0.02mm resolution
  // Imperial: 0.001" resolution
  double get _resolution => _isMetric ? 0.02 : 0.001;
  
  // Get current raw value based on unit (without zero offset)
  double get _rawDisplayValue {
    if (_isMetric) {
      return _measurement;
    } else {
      // Convert mm to inch: 1 inch = 25.4 mm
      return _measurement / 25.4;
    }
  }
  
  // Get final display value (applying zero offset)
  double get _displayValue {
    double val = _rawDisplayValue - _zeroOffset;
    // Round to resolution
    double r = _resolution;
    return (val / r).round() * r;
  }

  void _updateMeasurement(double delta) {
    // Throttling updates (approx 30fps) to "decrease real-time sampling"
    final now = DateTime.now();
    if (_lastUpdate != null && now.difference(_lastUpdate!).inMilliseconds < 32) {
      return;
    }
    _lastUpdate = now;

    // Allows movement even if HOLD is active (per technical script)
    setState(() {
      // Convert drag delta (pixels) to measurement delta (mm) always, as physics is mm-based
      double mmDelta = delta / _pixelsPerMm;
      _measurement = (_measurement + mmDelta).clamp(0.0, _maxMeasurement);
    });
  }

  void _snapMeasurement() {
    // Snap logic is purely visual for the slider interaction to feel "notched" 
    // but digital calipers are continuous. We can keep it continuous or snap to resolution.
    // Let's snap to resolution for better didactic control.
    setState(() {
      // Snap to the finest resolution (metric or imperial) to avoid "in between" states
      // Metric step: 0.02mm
      // Imperial step: 0.001" = 0.0254mm
      // Let's use 0.01mm as a fine snap base or just the current unit's resolution
      double stepMm = _isMetric ? 0.02 : (0.001 * 25.4);
      _measurement = ((_measurement / stepMm).round() * stepMm).clamp(0.0, _maxMeasurement);
    });
  }
  
  // Button Actions
  void _toggleUnit() {
    setState(() {
      // If we are holding a value, we should probably convert the held value too?
      // Or just reset hold? The script doesn't specify. 
      // Let's keep hold active and convert the displayed value if it makes sense, 
      // but usually switching units updates the display live.
      // If HOLD is active, let's update _heldValue to the new unit equivalent of what was frozen.
      
      _isMetric = !_isMetric;

      // Convert Zero Offset
      if (_isMetric) {
        // Inch -> MM
        _zeroOffset = _zeroOffset * 25.4;
        if (_isHold) _heldValue = _heldValue * 25.4;
      } else {
        // MM -> Inch
        _zeroOffset = _zeroOffset / 25.4;
        if (_isHold) _heldValue = _heldValue / 25.4;
      }
    });
  }
  
  void _toggleHold() {
    setState(() {
      if (!_isHold) {
        // Activate HOLD: Capture current value
        _heldValue = _displayValue;
      }
      _isHold = !_isHold;
    });
  }
  
  void _zero() {
    setState(() {
      // Set current raw value as the new zero point
      _zeroOffset = _rawDisplayValue;
      // If HOLD is active, update the held value to 0? 
      // Usually ZERO works on the live value. 
      // If HOLD is active, the display is frozen. Pressing ZERO usually affects the underlying count.
      // Let's assume ZERO affects the live reading.
      if (_isHold) {
        // If we Zero while Holding, the held value should probably reflect 0 if it was the current value?
        // Let's update held value to 0 to give feedback.
        _heldValue = 0.0;
      }
    });
  }
  
  void _resetZero() {
    setState(() {
      _measurement = 0.0;
      _zeroOffset = 0.0;
      _isHold = false;
      _heldValue = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine what to show on display
    double valToShow = _isHold ? _heldValue : _displayValue;
    
    return Column(
      children: [
        const SizedBox(height: 10),
        // Top Control Panel: Display (Left) + Buttons (Right)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Digital Readout (Compact)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAE6), // LCD Background color (greenish-grey)
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.silver, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Unit Indicator
                  Column(
                    children: [
                       Text(
                        _isMetric ? 'mm' : 'in',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (_isHold)
                        const Text(
                          'H',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Digits
                  Builder(
                    builder: (context) {
                      String text;
                      if (_isMetric) {
                        text = valToShow.toStringAsFixed(2);
                      } else {
                        text = valToShow.toStringAsFixed(3); // .001" resolution
                      }
                      
                      return Text(
                        text,
                        style: const TextStyle(
                          fontFamily: 'Courier', // LCD-like font
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87, 
                          letterSpacing: 2.0,
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // 2. Buttons (2x2 Grid)
            Column(
              children: [
                Row(
                  children: [
                    _buildButton('mm/in', _toggleUnit, isActive: false),
                    const SizedBox(width: 12),
                    _buildButton('ZERO', _zero, isActive: false),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildButton('HOLD', _toggleHold, isActive: _isHold),
                    const SizedBox(width: 12),
                    _buildButton('OFF', _resetZero, isActive: false, color: Colors.red),
                  ],
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),
        
        // Caliper Visual
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                height: 300,
                // Width = margin + ruler length + margin
                width: (_maxMeasurement * _pixelsPerMm) + 300, 
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Fixed Part (Main Scale + Body)
                    CustomPaint(
                      painter: MainScalePainter(
                        maxMm: _maxMeasurement,
                        pixelsPerMm: _pixelsPerMm,
                        isMetric: _isMetric,
                      ),
                      size: Size((_maxMeasurement * _pixelsPerMm) + 200, 300),
                    ),
                    
                    // Moving Part (Vernier + Jaw)
                    Positioned(
                      // Main Scale Start (50) + Fixed Jaw Width (40) = 90 (Zero Position)
                      // Vernier Jaw Face Offset = 15
                      // Positioned Left = 90 - 15 = 75
                      left: (_measurement * _pixelsPerMm) + 75,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          _updateMeasurement(details.delta.dx);
                        },
                        onHorizontalDragEnd: (details) {
                          _snapMeasurement();
                        },
                        child: CustomPaint(
                          painter: VernierScalePainter(
                            pixelsPerMm: _pixelsPerMm,
                            isMetric: _isMetric,
                          ),
                          size: const Size(400, 300), // Size for the moving head
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Arraste a peça móvel para medir',
            style: TextStyle(
              color: AppTheme.silver,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildButton(String label, VoidCallback onTap, {bool isActive = false, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isActive ? (color ?? Colors.blue) : Colors.grey[300],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(2, 2),
              blurRadius: 2,
            ),
          ],
          gradient: isActive ? null : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[200]!, Colors.grey[400]!],
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class MainScalePainter extends CustomPainter {
  final double maxMm;
  final double pixelsPerMm;
  final bool isMetric;

  MainScalePainter({
    required this.maxMm, 
    required this.pixelsPerMm,
    required this.isMetric,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Realistic metallic gradient for body
    final Rect rulerRect = Rect.fromLTWH(50, 100, maxMm * pixelsPerMm + 100, 60);
    final Paint bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFE0E0E0), // Light Silver
          Color(0xFFF5F5F5), // Highlight
          Color(0xFFBDBDBD), // Darker Silver
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rulerRect)
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = const Color(0xFF757575)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Paint marksPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    double rulerY = 100.0;
    double rulerHeight = 60.0;
    double startX = 50.0;

    // --- Draw Main Ruler Body ---
    canvas.drawRect(rulerRect, bodyPaint);
    
    // --- Draw Depth Rod Groove ---
    // A dark thin line/rect in the middle
    final Rect grooveRect = Rect.fromLTWH(startX, rulerY + (rulerHeight/2) - 1.5, rulerRect.width, 3);
    final Paint groovePaint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..style = PaintingStyle.fill;
    canvas.drawRect(grooveRect, groovePaint);
    
    canvas.drawRect(rulerRect, borderPaint);

    // --- Draw Matte Strip for Numbers (Middle) ---
    final Rect matteStrip = Rect.fromLTWH(startX, rulerY + 15, rulerRect.width, 30); 
    final Paint mattePaint = Paint()
      ..color = const Color(0xFFEEEEEE).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRect(matteStrip, mattePaint);

    // --- Draw Fixed Jaw (External) - Left Side ---
    Path fixedJaw = Path();
    fixedJaw.moveTo(startX, rulerY);
    fixedJaw.lineTo(startX + 40, rulerY); 
    fixedJaw.lineTo(startX + 40, rulerY + 150); 
    fixedJaw.lineTo(startX + 35, rulerY + 152); 
    fixedJaw.quadraticBezierTo(startX, rulerY + 100, startX, rulerY);
    fixedJaw.close();

    final Paint jawPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFD6D6D6), Color(0xFFF0F0F0), Color(0xFFC0C0C0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(fixedJaw.getBounds());

    canvas.drawPath(fixedJaw, jawPaint);
    canvas.drawPath(fixedJaw, borderPaint);

    // --- Draw Fixed Jaw (Internal) - Top Side ---
    Path fixedUpperJaw = Path();
    fixedUpperJaw.moveTo(startX + 10, rulerY);
    fixedUpperJaw.lineTo(startX + 40, rulerY);
    fixedUpperJaw.lineTo(startX + 40, rulerY - 45); 
    fixedUpperJaw.quadraticBezierTo(startX + 42, rulerY - 50, startX + 35, rulerY - 50);
    fixedUpperJaw.quadraticBezierTo(startX + 10, rulerY - 25, startX + 10, rulerY);
    fixedUpperJaw.close();

    canvas.drawPath(fixedUpperJaw, jawPaint);
    canvas.drawPath(fixedUpperJaw, borderPaint);

    // --- Draw Scale Marks ---
    double zeroX = startX + 40; 
    
    // --- BOTTOM: METRIC SCALE (1mm divisions) ---
    // Marks go UP from bottom edge (rulerY + rulerHeight)
    for (int i = 0; i <= maxMm; i++) {
      double x = zeroX + (i * pixelsPerMm);
      double lineHeight;
      
      if (i % 10 == 0) {
        lineHeight = 20.0;
        textPainter.text = TextSpan(
          text: (i ~/ 10).toString(),
          style: const TextStyle(
            color: Colors.black87, 
            fontSize: 12, 
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto', 
          ),
        );
        textPainter.layout();
        // Number placement
        textPainter.paint(canvas, Offset(x - (textPainter.width / 2), rulerY + rulerHeight - 32));
      } else if (i % 5 == 0) {
        lineHeight = 15.0;
      } else {
        lineHeight = 10.0;
      }
      
      canvas.drawLine(
        Offset(x, rulerY + rulerHeight), 
        Offset(x, rulerY + rulerHeight - lineHeight), 
        marksPaint
      );
    }
  }

  @override
  bool shouldRepaint(covariant MainScalePainter oldDelegate) => 
    oldDelegate.isMetric != isMetric || oldDelegate.maxMm != maxMm;
}

class VernierScalePainter extends CustomPainter {
  final double pixelsPerMm;
  final bool isMetric;

  VernierScalePainter({
    required this.pixelsPerMm,
    required this.isMetric,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Constants
    double rulerHeight = 60.0;
    double rulerY = 100.0;
    
    // Determine Scale Specs (Using Metric dimensions for head sizing)
    double vernierLengthMm = 49.0; 
    double scalePixelWidth = vernierLengthMm * pixelsPerMm;
    double headWidth = scalePixelWidth + 80.0; // Extra space for housing
    
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF757575)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Paint marksPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.0;
      
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // --- 1. Draw Depth Gauge (The tail) ---
    double tailLength = 200.0; // Visual length
    Rect tailRect = Rect.fromLTWH(headWidth, rulerY + (rulerHeight/2) - 2, tailLength, 4);
    final Paint tailPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB0B0B0), Color(0xFFE0E0E0), Color(0xFFB0B0B0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(tailRect);
    
    canvas.drawRect(tailRect, tailPaint);
    canvas.drawRect(tailRect, borderPaint);

    // --- 2. Draw Moving Head (Slider) ---
    Path outerHeadPath = Path();
    
    // Start top-left on ruler
    outerHeadPath.moveTo(0, rulerY);
    
    // Internal Jaw (Top)
    outerHeadPath.lineTo(0, rulerY - 20); // Base of jaw
    // Curved outer edge
    outerHeadPath.quadraticBezierTo(
      0, rulerY - 45,
      10, rulerY - 50 // Tip
    );
    // Tip detail
    outerHeadPath.lineTo(15, rulerY - 50);
    // Inner edge (straight) - This is the measuring face
    outerHeadPath.lineTo(15, rulerY); // Back to ruler line
    
    // Top Section (Housing Flush with Ruler)
    // The housing now sits ON the ruler, covering the top part (since top scale is gone).
    // So we don't go UP anymore. We go along the top edge.
    outerHeadPath.lineTo(15, rulerY); 
    outerHeadPath.lineTo(headWidth, rulerY); // Top edge of housing (flush)
    
    // Right Edge
    outerHeadPath.lineTo(headWidth, rulerY + rulerHeight);
    
    // Bottom Section (Vernier Scale Plate)
    // Beveled edge for scale
    outerHeadPath.lineTo(headWidth - 10, rulerY + rulerHeight + 35);
    // Bottom edge
    outerHeadPath.lineTo(10, rulerY + rulerHeight + 35);
    
    // External Jaw (Bottom)
    // Inner edge (measuring face)
    outerHeadPath.lineTo(10, rulerY + 150); // Tip
    // Tip detail
    outerHeadPath.lineTo(0, rulerY + 150);
    // Outer edge (curved)
    outerHeadPath.quadraticBezierTo(
      -10, rulerY + 100,
      -5, rulerY + rulerHeight // Back to ruler body
    );
    // Close shape
    outerHeadPath.lineTo(0, rulerY + rulerHeight); // Join
    outerHeadPath.close();

    // Create Window (Cutout) to see Main Scale
    Path windowPath = Path();
    // Window position: offset from jaw, centered vertically on ruler
    // Ruler is rulerY to rulerY + 60.
    // We open the window lower to allow the top housing to cover the empty top space.
    // Top 20px covered by housing/bevel.
    Rect windowRect = Rect.fromLTRB(30, rulerY + 20, headWidth - 20, rulerY + rulerHeight);
    windowPath.addRect(windowRect);

    // Combine to create the final head shape with hole
    Path headPath = Path.combine(PathOperation.difference, outerHeadPath, windowPath);

    // Metallic Gradient for Head
    final Paint headPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFD0D0D0), 
          Color(0xFFF8F8F8), 
          Color(0xFFC8C8C8)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(headPath.getBounds());

    canvas.drawShadow(headPath, Colors.black54, 4.0, true);
    canvas.drawPath(headPath, headPaint);
    canvas.drawPath(headPath, borderPaint);

    // --- 3. Draw Locking Screw (Top) ---
    double screwX = headWidth / 2;
    double screwY = rulerY - 8;
    Rect screwHead = Rect.fromCenter(center: Offset(screwX, screwY), width: 12, height: 10);
    
    // Screw Thread/Post
    canvas.drawRect(
      Rect.fromCenter(center: Offset(screwX, rulerY), width: 6, height: 10), 
      Paint()..color = Colors.grey[400]!
    );
    
    canvas.drawOval(screwHead, Paint()..color = const Color(0xFFE0E0E0));
    canvas.drawOval(screwHead, Paint()..style=PaintingStyle.stroke..color=Colors.grey[700]!);
    for(int k=0; k<5; k++) {
      double kx = screwHead.left + 2 + k*2;
      canvas.drawLine(
        Offset(kx, screwHead.top+2),
        Offset(kx, screwHead.bottom-2),
        Paint()..color=Colors.grey[500]!
      );
    }

    // --- 4. Draw Thumb Grip (Bottom Right) ---
    Rect thumbRect = Rect.fromLTWH(headWidth - 45, rulerY + rulerHeight + 5, 35, 20);
    RRect thumbRRect = RRect.fromRectAndRadius(thumbRect, const Radius.circular(4));
    canvas.drawRRect(thumbRRect, Paint()..color = const Color(0xFFD0D0D0));
    canvas.drawRRect(thumbRRect, Paint()..style=PaintingStyle.stroke..color=Colors.grey);
    for(int r=0; r<8; r++) {
      double rx = thumbRect.left + 4 + r*4;
      canvas.drawLine(
        Offset(rx, thumbRect.top),
        Offset(rx, thumbRect.bottom),
        Paint()..color=Colors.grey[600]!..strokeWidth=1.5
      );
    }

    // --- 5a. Draw Window/Bevel for Bottom Scale (Metric) ---
    double bevelHeight = 35.0;
    double bottomBevelY = rulerY + rulerHeight;
    Path bottomBevelPath = Path();
    // Trapezoid shape for bevel effect
    bottomBevelPath.moveTo(10, bottomBevelY); // Bottom-left of slider
    bottomBevelPath.lineTo(headWidth - 10, bottomBevelY); // Bottom-right of slider
    bottomBevelPath.lineTo(headWidth - 10, bottomBevelY + bevelHeight);
    bottomBevelPath.lineTo(10, bottomBevelY + bevelHeight);
    bottomBevelPath.close();
    
    // Gradient for bevel (sloping down)
    final Paint bevelPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE0E0E0), Color(0xFFFAFAFA)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bottomBevelPath.getBounds());
      
    canvas.drawPath(bottomBevelPath, bevelPaint);
    canvas.drawPath(bottomBevelPath, borderPaint);

    // Screws for Bottom Plate
    double bottomScrewY = bottomBevelY + 10;
    canvas.drawCircle(Offset(20, bottomScrewY), 2.5, Paint()..color = Colors.grey[700]!);
    canvas.drawCircle(Offset(headWidth - 20, bottomScrewY), 2.5, Paint()..color = Colors.grey[700]!);

    // --- 5b. Draw Window/Bevel for Top Scale (Plate covering ruler) ---
    // Start at rulerY and go DOWN into ruler area
    double topBevelY = rulerY;
    Path topBevelPath = Path();
    topBevelPath.moveTo(15, topBevelY); // Top-left (near jaw)
    topBevelPath.lineTo(headWidth - 10, topBevelY); // Top-right
    topBevelPath.lineTo(headWidth - 10, topBevelY + 20); // Bottom-right of top plate
    topBevelPath.lineTo(15, topBevelY + 20); // Bottom-left of top plate
    topBevelPath.close();
    
    // Gradient for bevel (sloping up/flat)
    final Paint topBevelPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFAFAFA), Color(0xFFE0E0E0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(topBevelPath.getBounds());
    
    canvas.drawPath(topBevelPath, topBevelPaint);
    canvas.drawPath(topBevelPath, borderPaint);

    // Screws for Top Plate
    double topScrewY = topBevelY + 10;
    canvas.drawCircle(Offset(25, topScrewY), 2.5, Paint()..color = Colors.grey[700]!);
    canvas.drawCircle(Offset(headWidth - 20, topScrewY), 2.5, Paint()..color = Colors.grey[700]!);

    // --- 6a. Draw Metric Vernier Scale Marks (Bottom) ---
    double vernierY = bottomBevelY; 
    
    // Metric: 50 divisions in 49mm
    double stepMmMetric = 49.0 / 50.0;
    
    for (int i = 0; i <= 50; i++) {
      double x = 10 + 15 + (i * stepMmMetric * pixelsPerMm); 
      x = 15 + (i * stepMmMetric * pixelsPerMm); // 15 is jaw offset

      double lineHeight;
      if (i % 5 == 0) {
          lineHeight = 15.0;
          // Numbers: 0, 1, 2... 10
          textPainter.text = TextSpan(
          text: (i ~/ 5).toString(),
          style: const TextStyle(
            color: Colors.black87, 
            fontSize: 10, 
            fontWeight: FontWeight.w600,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - (textPainter.width / 2), vernierY + 18));
      } else {
          lineHeight = 8.0;
      }
      
      canvas.drawLine(
        Offset(x, vernierY),
        Offset(x, vernierY + lineHeight),
        marksPaint
      );
    }
    
    // Resolution text Metric
    textPainter.text = const TextSpan(
      text: '0.02mm',
      style: TextStyle(
        color: Colors.black, 
        fontSize: 9, 
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w600
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(headWidth - 50, vernierY + 15));
  }

  @override
  bool shouldRepaint(covariant VernierScalePainter oldDelegate) => 
    oldDelegate.isMetric != isMetric;
}
