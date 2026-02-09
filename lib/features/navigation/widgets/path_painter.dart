import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/models/models.dart';
import '../../core/theme/app_theme.dart';

/// Custom painter for rendering the navigation path on floor plan
class PathPainter extends CustomPainter {
  final List<NavNode> path;
  final NavNode? currentPosition;
  final NavNode? destination;
  final double animationValue;
  final int currentFloor;
  
  PathPainter({
    required this.path,
    this.currentPosition,
    this.destination,
    this.animationValue = 0,
    this.currentFloor = 0,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (path.isEmpty) return;
    
    // Filter path for current floor
    final floorPath = path.where((n) => n.floor == currentFloor).toList();
    if (floorPath.isEmpty) return;
    
    // Calculate scale based on canvas size
    // Assuming coordinates are in percentage (0-100)
    final scaleX = size.width / 100;
    final scaleY = size.height / 100;
    
    // Draw path shadow
    _drawPathShadow(canvas, floorPath, scaleX, scaleY);
    
    // Draw path line
    _drawPathLine(canvas, floorPath, scaleX, scaleY);
    
    // Draw animated arrows
    _drawAnimatedArrows(canvas, floorPath, scaleX, scaleY);
    
    // Draw waypoint markers
    _drawWaypoints(canvas, floorPath, scaleX, scaleY);
    
    // Draw current position marker
    if (currentPosition != null && currentPosition!.floor == currentFloor) {
      _drawCurrentPositionMarker(canvas, currentPosition!, scaleX, scaleY);
    }
    
    // Draw destination marker
    if (destination != null && destination!.floor == currentFloor) {
      _drawDestinationMarker(canvas, destination!, scaleX, scaleY);
    }
  }
  
  void _drawPathShadow(Canvas canvas, List<NavNode> floorPath, double scaleX, double scaleY) {
    if (floorPath.length < 2) return;
    
    final shadowPaint = Paint()
      ..color = AppColors.pathColor.withOpacity(0.2)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    final pathLine = Path()
      ..moveTo(floorPath.first.x * scaleX, floorPath.first.y * scaleY);
    
    for (int i = 1; i < floorPath.length; i++) {
      pathLine.lineTo(floorPath[i].x * scaleX, floorPath[i].y * scaleY);
    }
    
    canvas.drawPath(pathLine, shadowPaint);
  }
  
  void _drawPathLine(Canvas canvas, List<NavNode> floorPath, double scaleX, double scaleY) {
    if (floorPath.length < 2) return;
    
    // Gradient effect using multiple strokes
    final colors = [
      AppColors.pathColor,
      AppColors.primaryLight,
    ];
    
    final pathPaint = Paint()
      ..color = AppColors.pathColor
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    final pathLine = Path()
      ..moveTo(floorPath.first.x * scaleX, floorPath.first.y * scaleY);
    
    for (int i = 1; i < floorPath.length; i++) {
      pathLine.lineTo(floorPath[i].x * scaleX, floorPath[i].y * scaleY);
    }
    
    // Draw outer glow
    final glowPaint = Paint()
      ..color = AppColors.pathColor.withOpacity(0.3)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawPath(pathLine, glowPaint);
    canvas.drawPath(pathLine, pathPaint);
    
    // Draw dashed center line for style
    _drawDashedLine(canvas, floorPath, scaleX, scaleY);
  }
  
  void _drawDashedLine(Canvas canvas, List<NavNode> floorPath, double scaleX, double scaleY) {
    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    const dashLength = 8.0;
    const gapLength = 6.0;
    
    for (int i = 0; i < floorPath.length - 1; i++) {
      final start = Offset(floorPath[i].x * scaleX, floorPath[i].y * scaleY);
      final end = Offset(floorPath[i + 1].x * scaleX, floorPath[i + 1].y * scaleY);
      
      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;
      final distance = math.sqrt(dx * dx + dy * dy);
      final unitX = dx / distance;
      final unitY = dy / distance;
      
      var currentDistance = 0.0;
      var drawing = true;
      
      while (currentDistance < distance) {
        final segmentLength = drawing ? dashLength : gapLength;
        final segmentEnd = math.min(currentDistance + segmentLength, distance);
        
        if (drawing) {
          canvas.drawLine(
            Offset(
              start.dx + unitX * currentDistance,
              start.dy + unitY * currentDistance,
            ),
            Offset(
              start.dx + unitX * segmentEnd,
              start.dy + unitY * segmentEnd,
            ),
            dashPaint,
          );
        }
        
        currentDistance = segmentEnd;
        drawing = !drawing;
      }
    }
  }
  
  void _drawAnimatedArrows(Canvas canvas, List<NavNode> floorPath, double scaleX, double scaleY) {
    if (floorPath.length < 2) return;
    
    for (int i = 0; i < floorPath.length - 1; i++) {
      final start = Offset(floorPath[i].x * scaleX, floorPath[i].y * scaleY);
      final end = Offset(floorPath[i + 1].x * scaleX, floorPath[i + 1].y * scaleY);
      
      // Calculate multiple arrow positions along the segment
      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;
      final distance = math.sqrt(dx * dx + dy * dy);
      
      if (distance < 20) continue; // Skip short segments
      
      final numArrows = (distance / 40).floor().clamp(1, 5);
      
      for (int j = 0; j < numArrows; j++) {
        // Calculate position with animation offset
        var t = (j + 1) / (numArrows + 1) + (animationValue * 0.3);
        if (t > 1) t -= 1;
        
        final arrowX = start.dx + dx * t;
        final arrowY = start.dy + dy * t;
        final angle = math.atan2(dy, dx);
        
        _drawArrow(canvas, Offset(arrowX, arrowY), angle);
      }
    }
  }
  
  void _drawArrow(Canvas canvas, Offset position, double angle) {
    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);
    
    final arrowPath = Path()
      ..moveTo(8, 0)
      ..lineTo(-4, -5)
      ..lineTo(-2, 0)
      ..lineTo(-4, 5)
      ..close();
    
    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    
    canvas.drawPath(arrowPath.shift(const Offset(1, 1)), shadowPaint);
    canvas.drawPath(arrowPath, arrowPaint);
    
    canvas.restore();
  }
  
  void _drawWaypoints(Canvas canvas, List<NavNode> floorPath, double scaleX, double scaleY) {
    for (final node in floorPath) {
      // Only draw waypoints for important nodes (not corridors)
      if (node.type == NodeType.corridor) continue;
      if (node == currentPosition || node == destination) continue;
      
      final position = Offset(node.x * scaleX, node.y * scaleY);
      
      // Outer circle
      final outerPaint = Paint()
        ..color = node.type.color.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(position, 12, outerPaint);
      
      // Inner circle
      final innerPaint = Paint()
        ..color = node.type.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(position, 8, innerPaint);
      
      // White border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(position, 8, borderPaint);
    }
  }
  
  void _drawCurrentPositionMarker(Canvas canvas, NavNode node, double scaleX, double scaleY) {
    final position = Offset(node.x * scaleX, node.y * scaleY);
    
    // Animated pulse effect
    final pulseRadius = 20 + (animationValue * 15);
    final pulsePaint = Paint()
      ..color = AppColors.currentLocation.withOpacity(0.3 * (1 - animationValue))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, pulseRadius, pulsePaint);
    
    // Outer glow
    final glowPaint = Paint()
      ..color = AppColors.currentLocation.withOpacity(0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(position, 16, glowPaint);
    
    // Main circle
    final mainPaint = Paint()
      ..color = AppColors.currentLocation
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 14, mainPaint);
    
    // White border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(position, 14, borderPaint);
    
    // Inner dot
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 5, dotPaint);
  }
  
  void _drawDestinationMarker(Canvas canvas, NavNode node, double scaleX, double scaleY) {
    final position = Offset(node.x * scaleX, node.y * scaleY);
    
    // Pin drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(position.translate(2, 4), 12, shadowPaint);
    
    // Pin outer circle
    final outerPaint = Paint()
      ..color = AppColors.destination
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 16, outerPaint);
    
    // White border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(position, 16, borderPaint);
    
    // Flag icon in center
    final flagPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Simple flag shape
    final flagPath = Path()
      ..moveTo(position.dx - 4, position.dy - 8)
      ..lineTo(position.dx - 4, position.dy + 8)
      ..moveTo(position.dx - 4, position.dy - 8)
      ..lineTo(position.dx + 6, position.dy - 4)
      ..lineTo(position.dx - 4, position.dy);
    
    canvas.drawPath(
      flagPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    
    // Fill the flag
    final flagFillPath = Path()
      ..moveTo(position.dx - 4, position.dy - 8)
      ..lineTo(position.dx + 6, position.dy - 4)
      ..lineTo(position.dx - 4, position.dy)
      ..close();
    canvas.drawPath(flagFillPath, flagPaint);
  }
  
  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    return path != oldDelegate.path ||
           currentPosition != oldDelegate.currentPosition ||
           destination != oldDelegate.destination ||
           animationValue != oldDelegate.animationValue ||
           currentFloor != oldDelegate.currentFloor;
  }
}

/// Extension for Offset translate
extension OffsetExtension on Offset {
  Offset translate(double dx, double dy) => Offset(this.dx + dx, this.dy + dy);
}
