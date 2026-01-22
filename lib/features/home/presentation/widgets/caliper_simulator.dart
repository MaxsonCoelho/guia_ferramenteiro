import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CaliperSimulator extends StatefulWidget {
  const CaliperSimulator({super.key});

  @override
  State<CaliperSimulator> createState() => _CaliperSimulatorState();
}

class _CaliperSimulatorState extends State<CaliperSimulator> {
  // Current measurement in millimeters
  double _measurement = 0.0;
  // Maximum measurement (15cm)
  final double _maxMeasurement = 150.0;
  // Scale factor (pixels per mm)
  // Increased to 14.0 to make 0.05mm intervals visually distinguishable (0.05mm * 14 = 0.7px diff)
  // This "Zoom" is essential for didactic purposes on mobile screens
  final double _pixelsPerMm = 14.0; 

  void _updateMeasurement(double delta) {
    setState(() {
      // Convert drag delta (pixels) to measurement delta (mm)
      double mmDelta = delta / _pixelsPerMm;
      _measurement = (_measurement + mmDelta).clamp(0.0, _maxMeasurement);
    });
  }

  void _snapMeasurement() {
    setState(() {
      // Snap to nearest 0.05mm for didactic clarity
      // This helps the user "find" the alignment
      const double step = 0.05;
      _measurement = ((_measurement / step).round() * step).clamp(0.0, _maxMeasurement);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Digital Readout (Didactic aid)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.silver),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '${_measurement.toStringAsFixed(2)} mm',
            style: const TextStyle(
              fontFamily: 'Courier', // Monospace for digital look
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00FF00), // Digital green
              shadows: [
                Shadow(
                  color: Color(0xFF00FF00),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
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
                      ),
                      size: Size((_maxMeasurement * _pixelsPerMm) + 200, 300),
                    ),
                    
                    // Moving Part (Vernier + Jaw)
                    Positioned(
                      left: (_measurement * _pixelsPerMm) + 40, // 40 is the offset for the jaw start
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
                          ),
                          size: const Size(400, 300), // Increased size for the moving head (dynamic width ~350)
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
}

class MainScalePainter extends CustomPainter {
  final double maxMm;
  final double pixelsPerMm;

  MainScalePainter({required this.maxMm, required this.pixelsPerMm});

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
    canvas.drawRect(rulerRect, borderPaint);

    // --- Draw Matte Strip for Numbers (Common in real calipers) ---
    // A slightly darker, non-reflective strip where the graduations are
    final Rect matteStrip = Rect.fromLTWH(startX, rulerY + 30, rulerRect.width, 30);
    final Paint mattePaint = Paint()
      ..color = const Color(0xFFEEEEEE).withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRect(matteStrip, mattePaint);
    canvas.drawLine(
      Offset(startX, rulerY + 30),
      Offset(startX + rulerRect.width, rulerY + 30),
      Paint()..color = Colors.black12..strokeWidth = 0.5,
    );

    // --- Draw Fixed Jaw (External) - Left Side ---
    // Realistic shape: straight inner edge, curved outer edge
    Path fixedJaw = Path();
    fixedJaw.moveTo(startX, rulerY);
    // Inner edge (straight down)
    fixedJaw.lineTo(startX + 40, rulerY); // Start slightly right
    fixedJaw.lineTo(startX + 40, rulerY + 150); // Down to tip
    // Tip detail
    fixedJaw.lineTo(startX + 35, rulerY + 152); // Tiny blunt tip
    // Outer edge (curved up)
    fixedJaw.quadraticBezierTo(
      startX, rulerY + 100, // Control point
      startX, rulerY // End point
    );
    fixedJaw.close();

    // Gradient for Jaw
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
    // Inner edge (straight up)
    fixedUpperJaw.lineTo(startX + 40, rulerY);
    fixedUpperJaw.lineTo(startX + 40, rulerY - 45); // Up to tip
    // Tip
    fixedUpperJaw.quadraticBezierTo(
      startX + 42, rulerY - 50,
      startX + 35, rulerY - 50
    );
    // Outer edge (curved down)
    fixedUpperJaw.quadraticBezierTo(
      startX + 10, rulerY - 25,
      startX + 10, rulerY
    );
    fixedUpperJaw.close();

    canvas.drawPath(fixedUpperJaw, jawPaint);
    canvas.drawPath(fixedUpperJaw, borderPaint);

    // --- Draw Scale Marks ---
    double zeroX = startX + 40; // Scale zero point matches jaw inner edge
    for (int i = 0; i <= maxMm; i++) {
      double x = zeroX + (i * pixelsPerMm);
      double lineHeight;
      
      if (i % 10 == 0) {
        lineHeight = 20.0;
        // Draw Number
        textPainter.text = TextSpan(
          text: (i ~/ 10).toString(),
          style: const TextStyle(
            color: Colors.black87, 
            fontSize: 12, 
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto', // Cleaner font
          ),
        );
        textPainter.layout();
        // Position number centered above the tick
        textPainter.paint(canvas, Offset(x - (textPainter.width / 2), rulerY + 32));
      } else if (i % 5 == 0) {
        lineHeight = 15.0;
      } else {
        lineHeight = 10.0;
      }
      
      // Draw ticks extending from bottom edge up
      canvas.drawLine(
        Offset(x, rulerY + rulerHeight), 
        Offset(x, rulerY + rulerHeight - lineHeight), 
        marksPaint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class VernierScalePainter extends CustomPainter {
  final double pixelsPerMm;

  VernierScalePainter({required this.pixelsPerMm});

  @override
  void paint(Canvas canvas, Size size) {
    // Constants
    double rulerHeight = 60.0;
    double rulerY = 100.0;
    
    // Dynamic Width Calculation
    double vernierStepMm = 19.0 / 20.0;
    double scalePixelWidth = 20 * vernierStepMm * pixelsPerMm;
    double headWidth = scalePixelWidth + 80.0; 
    
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF757575)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Paint marksPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.0;
      
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // --- 1. Draw Depth Gauge (The tail) ---
    // Extends to the right from the center of the head
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
    Path headPath = Path();
    
    // Start top-left on ruler
    headPath.moveTo(0, rulerY);
    
    // Internal Jaw (Top)
    headPath.lineTo(0, rulerY - 20); // Base of jaw
    // Curved outer edge
    headPath.quadraticBezierTo(
      0, rulerY - 45,
      10, rulerY - 50 // Tip
    );
    // Tip detail
    headPath.lineTo(15, rulerY - 50);
    // Inner edge (straight) - This is the measuring face
    headPath.lineTo(15, rulerY); // Back to ruler line
    
    // Top Edge over Ruler
    headPath.lineTo(headWidth, rulerY);
    
    // Right Edge
    headPath.lineTo(headWidth, rulerY + rulerHeight);
    
    // Bottom Section (Vernier Scale Plate)
    // Beveled edge for scale
    headPath.lineTo(headWidth - 10, rulerY + rulerHeight + 35);
    // Bottom edge
    headPath.lineTo(10, rulerY + rulerHeight + 35);
    
    // External Jaw (Bottom)
    // Inner edge (measuring face)
    headPath.lineTo(10, rulerY + 150); // Tip
    // Tip detail
    headPath.lineTo(0, rulerY + 150);
    // Outer edge (curved)
    headPath.quadraticBezierTo(
      -10, rulerY + 100,
      -5, rulerY + rulerHeight // Back to ruler body
    );
    // Close shape
    headPath.lineTo(0, rulerY + rulerHeight); // Join
    headPath.close();

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

    // Shadow
    canvas.drawShadow(headPath, Colors.black54, 4.0, true);
    
    canvas.drawPath(headPath, headPaint);
    canvas.drawPath(headPath, borderPaint);

    // --- 3. Draw Locking Screw (Top) ---
    // A small knurled screw on top
    double screwX = headWidth / 2;
    double screwY = rulerY - 8;
    Rect screwHead = Rect.fromCenter(center: Offset(screwX, screwY), width: 12, height: 10);
    
    // Screw Thread/Post
    canvas.drawRect(
      Rect.fromCenter(center: Offset(screwX, rulerY), width: 6, height: 10), 
      Paint()..color = Colors.grey[400]!
    );
    
    // Screw Head
    canvas.drawOval(screwHead, Paint()..color = const Color(0xFFE0E0E0));
    canvas.drawOval(screwHead, Paint()..style=PaintingStyle.stroke..color=Colors.grey[700]!);
    // Knurling lines
    for(int k=0; k<5; k++) {
      double kx = screwHead.left + 2 + k*2;
      canvas.drawLine(
        Offset(kx, screwHead.top+2),
        Offset(kx, screwHead.bottom-2),
        Paint()..color=Colors.grey[500]!
      );
    }

    // --- 4. Draw Thumb Grip (Bottom Right) ---
    // A textured area for the thumb
    Rect thumbRect = Rect.fromLTWH(headWidth - 45, rulerY + rulerHeight + 5, 35, 20);
    // Base shape
    RRect thumbRRect = RRect.fromRectAndRadius(thumbRect, const Radius.circular(4));
    canvas.drawRRect(thumbRRect, Paint()..color = const Color(0xFFD0D0D0));
    canvas.drawRRect(thumbRRect, Paint()..style=PaintingStyle.stroke..color=Colors.grey);
    // Ribs
    for(int r=0; r<8; r++) {
      double rx = thumbRect.left + 4 + r*4;
      canvas.drawLine(
        Offset(rx, thumbRect.top),
        Offset(rx, thumbRect.bottom),
        Paint()..color=Colors.grey[600]!..strokeWidth=1.5
      );
    }

    // --- 5. Draw Window/Bevel for Scale ---
    // The vernier scale sits on a beveled edge
    double bevelHeight = 35.0;
    double bevelY = rulerY + rulerHeight;
    Path bevelPath = Path();
    bevelPath.moveTo(10, bevelY);
    bevelPath.lineTo(headWidth - 10, bevelY);
    bevelPath.lineTo(headWidth - 10, bevelY + bevelHeight);
    bevelPath.lineTo(10, bevelY + bevelHeight);
    bevelPath.close();
    
    // Matte finish for reading area
    canvas.drawPath(bevelPath, Paint()..color = const Color(0xFFF5F5F5));
    canvas.drawPath(bevelPath, borderPaint);

    // --- 6. Draw Vernier Scale Marks ---
    double vernierY = bevelY; 
    
    for (int i = 0; i <= 20; i++) {
      double x = 25 + (i * vernierStepMm * pixelsPerMm); // Start offset 25 relative to head
      double lineHeight;
      
      if (i % 2 == 0) {
        // Numbered mark (0, 1, 2... 10)
        lineHeight = 15.0;
        String label = (i ~/ 2).toString();
        textPainter.text = TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.black87, 
            fontSize: 9, 
            fontWeight: FontWeight.w700
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - (textPainter.width / 2), vernierY + 18));
      } else {
        // Half mark
        lineHeight = 10.0;
      }
      
      canvas.drawLine(Offset(x, vernierY), Offset(x, vernierY + lineHeight), marksPaint);
    }
    
    // Draw "0.05mm" text
    textPainter.text = const TextSpan(
      text: '0.05mm',
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
