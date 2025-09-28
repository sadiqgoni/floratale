import 'package:flutter/material.dart';

class LoadingLeaf extends StatefulWidget {
  const LoadingLeaf({
    super.key,
    this.size = 60,
    this.strokeWidth = 4,
  });

  final double size;
  final double strokeWidth;

  @override
  State<LoadingLeaf> createState() => _LoadingLeafState();
}

class _LoadingLeafState extends State<LoadingLeaf>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159, 
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.8),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.0),
        weight: 25,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: LeafPainter(
                strokeWidth: widget.strokeWidth,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}

class LeafPainter extends CustomPainter {
  LeafPainter({
    required this.strokeWidth,
    required this.color,
  });

  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2 - strokeWidth;

    final Path path = Path();

    
    path.moveTo(centerX, size.height - strokeWidth);

    
    path.cubicTo(
      centerX - radius * 0.3, centerY + radius * 0.4,
      centerX - radius * 0.8, centerY - radius * 0.2,
      centerX - radius * 0.2, centerY - radius * 0.8,
    );

    
    path.cubicTo(
      centerX, centerY - radius,
      centerX + radius * 0.8, centerY - radius * 0.2,
      centerX + radius * 0.2, centerY - radius * 0.8,
    );

    
    path.cubicTo(
      centerX + radius * 0.8, centerY - radius * 0.2,
      centerX + radius * 0.3, centerY + radius * 0.4,
      centerX, size.height - strokeWidth,
    );

    
    path.moveTo(centerX, size.height - strokeWidth);
    path.lineTo(centerX, size.height);

    canvas.drawPath(path, paint);

      
    final Path veinPath = Path();
    veinPath.moveTo(centerX, size.height - strokeWidth);
    veinPath.lineTo(centerX, centerY - radius * 0.6);

    canvas.drawPath(veinPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
