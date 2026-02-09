import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../core/models/models.dart';
import '../../core/providers/navigation_providers.dart';
import 'path_painter.dart';

/// Widget for displaying the floor plan with navigation path overlay
class FloorPlanViewer extends ConsumerStatefulWidget {
  final String? floorPlanImagePath;
  final bool showNodes;
  final bool isEditable;
  final Function(double x, double y)? onTap;
  
  const FloorPlanViewer({
    super.key,
    this.floorPlanImagePath,
    this.showNodes = false,
    this.isEditable = false,
    this.onTap,
  });
  
  @override
  ConsumerState<FloorPlanViewer> createState() => _FloorPlanViewerState();
}

class _FloorPlanViewerState extends ConsumerState<FloorPlanViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TransformationController _transformationController = TransformationController();
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final graph = ref.watch(campusGraphProvider);
    final currentPosition = ref.watch(currentPositionProvider);
    final destination = ref.watch(destinationProvider);
    final currentFloor = ref.watch(currentFloorProvider);
    final pathResult = ref.watch(pathResultProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Floor Plan with Interactive Viewer
            InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 4.0,
              boundaryMargin: const EdgeInsets.all(100),
              onInteractionEnd: (_) {
                // Could save the current view state
              },
              child: GestureDetector(
                onTapUp: widget.isEditable ? (details) {
                  // Convert tap position to floor plan coordinates
                  final box = context.findRenderObject() as RenderBox;
                  final localPosition = box.globalToLocal(details.globalPosition);
                  final size = box.size;
                  
                  // Convert to percentage coordinates (0-100)
                  final x = (localPosition.dx / size.width) * 100;
                  final y = (localPosition.dy / size.height) * 100;
                  
                  widget.onTap?.call(x, y);
               } : null,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: Stack(
                        children: [
                          // Grid background (placeholder for floor plan)
                          CustomPaint(
                            size: Size(constraints.maxWidth, constraints.maxHeight),
                            painter: _FloorPlanBackgroundPainter(),
                          ),
                          
                          // Show nodes if in edit mode or showNodes is true
                          if (widget.showNodes)
                            ...graph.nodesForFloor(currentFloor).map((node) {
                              return Positioned(
                                left: (node.x / 100) * constraints.maxWidth - 15,
                                top: (node.y / 100) * constraints.maxHeight - 15,
                                child: _NodeMarker(node: node),
                              );
                            }),
                          
                          // Path overlay
                          if (pathResult != null && pathResult.isFound)
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return CustomPaint(
                                  size: Size(constraints.maxWidth, constraints.maxHeight),
                                  painter: PathPainter(
                                    path: pathResult.path,
                                    currentPosition: currentPosition,
                                    destination: destination,
                                    animationValue: _animationController.value,
                                    currentFloor: currentFloor,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Floor selector
            Positioned(
              top: 16,
              right: 16,
              child: _FloorSelector(currentFloor: currentFloor),
            ),
            
            // Zoom controls
            Positioned(
              bottom: 16,
              right: 16,
              child: _ZoomControls(controller: _transformationController),
            ),
            
            // Compass
            Positioned(
              top: 16,
              left: 16,
              child: _Compass(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Background painter for floor plan (grid placeholder)
class _FloorPlanBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background color
    final bgPaint = Paint()..color = const Color(0xFFF8FAFC);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    
    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    
    const gridSize = 20.0;
    
    // Vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    
    // Horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    
    // Draw building outline
    final outlinePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final margin = 20.0;
    final buildingRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(margin, margin, size.width - margin * 2, size.height - margin * 2),
      const Radius.circular(8),
    );
    canvas.drawRRect(buildingRect, outlinePaint);
    
    // Draw some room outlines as placeholder
    _drawRoomPlaceholders(canvas, size, margin);
  }
  
  void _drawRoomPlaceholders(Canvas canvas, Size size, double margin) {
    final roomPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final roomFillPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
    
    // Left wing rooms
    final room1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(margin + 10, size.height * 0.6, size.width * 0.15, size.height * 0.2),
      const Radius.circular(4),
    );
    canvas.drawRRect(room1, roomFillPaint);
    canvas.drawRRect(room1, roomPaint);
    
    final room2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(margin + 10, size.height * 0.35, size.width * 0.15, size.height * 0.2),
      const Radius.circular(4),
    );
    canvas.drawRRect(room2, roomFillPaint);
    canvas.drawRRect(room2, roomPaint);
    
    // Right wing rooms
    final room3 = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - margin - size.width * 0.15 - 10, size.height * 0.6, size.width * 0.15, size.height * 0.2),
      const Radius.circular(4),
    );
    canvas.drawRRect(room3, roomFillPaint);
    canvas.drawRRect(room3, roomPaint);
    
    final room4 = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - margin - size.width * 0.15 - 10, size.height * 0.35, size.width * 0.15, size.height * 0.2),
      const Radius.circular(4),
    );
    canvas.drawRRect(room4, roomFillPaint);
    canvas.drawRRect(room4, roomPaint);
    
    // Admin area at top
    final adminArea = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.25, margin + 10, size.width * 0.5, size.height * 0.15),
      const Radius.circular(4),
    );
    canvas.drawRRect(adminArea, roomFillPaint);
    canvas.drawRRect(adminArea, roomPaint);
    
    // Main corridor (central)
    final corridorPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;
    
    // Vertical corridor
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.45, size.height * 0.25, size.width * 0.1, size.height * 0.65),
      corridorPaint,
    );
    
    // Horizontal corridor
    canvas.drawRect(
      Rect.fromLTWH(margin + 10, size.height * 0.75, size.width - margin * 2 - 20, size.height * 0.1),
      corridorPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Marker for navigation nodes
class _NodeMarker extends StatelessWidget {
  final NavNode node;
  
  const _NodeMarker({required this.node});
  
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: node.name,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: node.type.color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: node.type.color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          node.type.icon,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}

/// Floor selector widget
class _FloorSelector extends ConsumerWidget {
  final int currentFloor;
  
  const _FloorSelector({required this.currentFloor});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FloorButton(
            label: '1F',
            isSelected: currentFloor == 1,
            onTap: () => ref.read(currentFloorProvider.notifier).state = 1,
          ),
          Container(height: 1, width: 40, color: Colors.grey.shade200),
          _FloorButton(
            label: 'GF',
            isSelected: currentFloor == 0,
            onTap: () => ref.read(currentFloorProvider.notifier).state = 0,
          ),
        ],
      ),
    );
  }
}

class _FloorButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _FloorButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 48,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

/// Zoom controls widget
class _ZoomControls extends StatelessWidget {
  final TransformationController controller;
  
  const _ZoomControls({required this.controller});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: () => _zoom(1.2),
            splashRadius: 20,
          ),
          Container(height: 1, width: 40, color: Colors.grey.shade200),
          IconButton(
            icon: const Icon(Icons.remove, size: 20),
            onPressed: () => _zoom(0.8),
            splashRadius: 20,
          ),
          Container(height: 1, width: 40, color: Colors.grey.shade200),
          IconButton(
            icon: const Icon(Icons.center_focus_strong, size: 20),
            onPressed: _reset,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
  
  void _zoom(double factor) {
    final currentScale = controller.value.getMaxScaleOnAxis();
    final newScale = (currentScale * factor).clamp(0.5, 4.0);
    
    controller.value = Matrix4.identity()..scale(newScale);
  }
  
  void _reset() {
    controller.value = Matrix4.identity();
  }
}

/// Compass widget
class _Compass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Compass ring
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
          ),
          // North indicator
          Positioned(
            top: 6,
            child: Text(
              'N',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
          ),
          // Compass needle
          Transform.rotate(
            angle: 0,
            child: Icon(
              Icons.navigation,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
