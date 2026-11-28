import 'package:flutter/material.dart';

/// Simple line chart of saved BMI values, oldest on the left. No extra packages.
class BmiChart extends StatelessWidget {
  final List<double> values;
  const BmiChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    final txt = Theme.of(context).textTheme.bodyMedium?.color ??
        Theme.of(context).colorScheme.onSurface;
    final dark = txt.computeLuminance() > 0.5;
    final color = dark ? const Color(0xFF8AB4FF) : Theme.of(context).colorScheme.primary;
    final grey = txt.withOpacity(0.85);
    return Container(
      key: const Key('bmi_chart'),
      height: 150,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: grey.withOpacity(0.5)),
      ),
      child: CustomPaint(
        size: Size.infinite,
        painter: _ChartPainter(values, color, grey),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final Color grey;
  _ChartPainter(this.values, this.color, this.grey);

  void _label(Canvas c, String t, Offset o) {
    final tp = TextPainter(
      text: TextSpan(text: t, style: TextStyle(color: grey, fontSize: 12)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, o);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    const left = 34.0;
    final w = size.width - left;
    final h = size.height - 6;
    var lo = values.reduce((a, b) => a < b ? a : b);
    var hi = values.reduce((a, b) => a > b ? a : b);
    if (hi - lo < 1) {
      lo -= 0.5;
      hi += 0.5;
    }
    double x(int i) => left + w * i / (values.length - 1);
    double y(double v) => 3 + h - h * (v - lo) / (hi - lo);

    final axis = Paint()
      ..color = grey.withOpacity(0.6)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(left, 3), Offset(left, 3 + h), axis);
    canvas.drawLine(Offset(left, 3 + h), Offset(left + w, 3 + h), axis);
    _label(canvas, hi.toStringAsFixed(1), const Offset(0, 0));
    _label(canvas, lo.toStringAsFixed(1), Offset(0, h - 8));

    final line = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(x(0), y(values[0]));
    for (var i = 1; i < values.length; i++) {
      path.lineTo(x(i), y(values[i]));
    }
    canvas.drawPath(path, line);
    final dot = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(Offset(x(i), y(values[i])), 3.5, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.values != values || old.color != color;
}
