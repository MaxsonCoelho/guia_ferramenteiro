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
    final paintBody = Paint()
      ..color = AppTheme.brushedMetal
      ..style = PaintingStyle.fill;
      
    final paintBorder = Paint()
      ..color = const Color(0xFF5C5C5C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final paintMarks = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    double rulerHeight = 60.0;
    double rulerY = 100.0; // Vertical position of the ruler
    double startX = 50.0; // Start drawing after some padding

    // 1. Draw Main Body (Ruler)
    Rect rulerRect = Rect.fromLTWH(startX, rulerY, maxMm * pixelsPerMm + 100, rulerHeight);
    canvas.drawRect(rulerRect, paintBody);
    canvas.drawRect(rulerRect, paintBorder);

    // 2. Draw Fixed Jaw (Left side)
    Path fixedJaw = Path();
    fixedJaw.moveTo(startX, rulerY);
    fixedJaw.lineTo(startX, rulerY + 150); // Downward jaw
    fixedJaw.lineTo(startX + 40, rulerY + 150);
    fixedJaw.lineTo(startX + 40, rulerY + rulerHeight);
    fixedJaw.close();
    
    // Upper jaw (for internal measurement)
    Path fixedUpperJaw = Path();
    fixedUpperJaw.moveTo(startX, rulerY);
    fixedUpperJaw.lineTo(startX, rulerY - 50);
    fixedUpperJaw.lineTo(startX + 20, rulerY - 50);
    fixedUpperJaw.lineTo(startX + 30, rulerY);
    fixedUpperJaw.close();

    canvas.drawPath(fixedJaw, paintBody);
    canvas.drawPath(fixedJaw, paintBorder);
    canvas.drawPath(fixedUpperJaw, paintBody);
    canvas.drawPath(fixedUpperJaw, paintBorder);

    // 3. Draw Scale Marks
    // Scale starts at startX + 40 (where the jaws meet at 0)
    double zeroX = startX + 40;
    
    for (int i = 0; i <= maxMm; i++) {
      double x = zeroX + (i * pixelsPerMm);
      double lineHeight;
      
      if (i % 10 == 0) {
        lineHeight = 20.0; // cm mark
        // Draw Number
        textPainter.text = TextSpan(
          text: (i ~/ 10).toString(),
          style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - (textPainter.width / 2), rulerY + 25));
      } else if (i % 5 == 0) {
        lineHeight = 15.0; // 5mm mark
      } else {
        lineHeight = 10.0; // 1mm mark
      }
      
      canvas.drawLine(Offset(x, rulerY + rulerHeight), Offset(x, rulerY + rulerHeight - lineHeight), paintMarks);
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
    final paintBody = Paint()
      ..color = AppTheme.silver // Lighter metal for moving part
      ..style = PaintingStyle.fill;
      
    final paintBorder = Paint()
      ..color = const Color(0xFF5C5C5C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final paintMarks = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    double rulerHeight = 60.0;
    double rulerY = 100.0; // Must match MainScalePainter
    
    // Calculate dynamic head width based on scale size
    // 20 divisions * 0.95mm/division * pixelsPerMm
    double vernierStepMm = 19.0 / 20.0;
    double scalePixelWidth = 20 * vernierStepMm * pixelsPerMm;
    
    // Ensure head is wide enough for the scale plus padding
    double headWidth = scalePixelWidth + 80.0; 
    
    // 1. Draw Moving Head Body
    // It wraps around the ruler
    // We'll draw a shape that looks like the sliding head
    Path headPath = Path();
    // Start at top-left of the slider on the ruler
    headPath.moveTo(0, rulerY); 
    // Upper jaw (internal)
    headPath.lineTo(10, rulerY - 50);
    headPath.lineTo(30, rulerY - 50);
    headPath.lineTo(40, rulerY);
    // Continue right along top of ruler
    headPath.lineTo(headWidth, rulerY);
    // Down to bottom of ruler
    headPath.lineTo(headWidth, rulerY + rulerHeight);
    // The vernier scale plate (extends down)
    headPath.lineTo(headWidth - 20, rulerY + rulerHeight + 40); 
    headPath.lineTo(20, rulerY + rulerHeight + 40);
    // The moving jaw (external)
    headPath.lineTo(20, rulerY + 150);
    headPath.lineTo(0, rulerY + 150);
    headPath.close();

    // Shadow for depth
    canvas.drawShadow(headPath, Colors.black45, 4.0, false);
    
    canvas.drawPath(headPath, paintBody);
    canvas.drawPath(headPath, paintBorder);

    // 2. Draw Vernier Scale Marks
    // Standard 0.05mm vernier: 20 divisions spanning 19mm or 39mm.
    // Let's use 19mm span for 20 divisions (standard compact).
    // So total length = 19mm.
    // Each division = 19/20 = 0.95mm on the main scale.
    // But here we are drawing on the moving part, so we draw them relative to the 0 of the vernier.
    // The 0 of the vernier aligns with the 0 of the main scale when closed.
    
    double vernierY = rulerY + rulerHeight; // Start marks at bottom of main ruler
    
    for (int i = 0; i <= 20; i++) {
      double x = i * vernierStepMm * pixelsPerMm;
      double lineHeight;
      
      if (i % 2 == 0) {
        // Numbered mark (0, 1, 2... 10)
        lineHeight = 15.0;
        String label = (i ~/ 2).toString();
        textPainter.text = TextSpan(
          text: label,
          style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - (textPainter.width / 2), vernierY + 18));
      } else {
        // Half mark
        lineHeight = 10.0;
      }
      
      canvas.drawLine(Offset(x, vernierY), Offset(x, vernierY + lineHeight), paintMarks);
    }
    
    // Draw "0.05mm" text
    // Positioned to the right of the scale to avoid overlapping
    textPainter.text = const TextSpan(
      text: '0.05mm',
      style: TextStyle(
        color: Colors.black, 
        fontSize: 10, 
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w600
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(scalePixelWidth + 15, vernierY + 15));
    
    // Draw Thumb Rest (Texture)
    final paintThumb = Paint()
      ..color = Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    // Position thumb rest at the end of the head
    double thumbStart = headWidth - 40.0;
    for(int i=0; i<6; i++) {
      double tx = thumbStart + (i * 4);
      canvas.drawLine(Offset(tx, rulerY + rulerHeight + 10), Offset(tx, rulerY + rulerHeight + 30), paintThumb);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
