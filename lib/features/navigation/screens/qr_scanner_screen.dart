import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/navigation_providers.dart';

/// QR Scanner screen for detecting user's current position
class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});
  
  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
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
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera placeholder
          Container(
            color: Colors.grey.shade900,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Point camera at QR code', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          
          // Scanner overlay
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) => CustomPaint(
              painter: _ScannerPainter(_animationController.value),
              size: Size.infinite,
            ),
          ),
          
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
              ),
            ),
          ),
          
          // Bottom panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(context),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            const Text('Scan Location QR Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Tap buttons below to simulate scan', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _demoButton('Main Entrance', 'CAMPUS_MAIN_ENTRANCE'),
                _demoButton('Room 101', 'CAMPUS_ROOM_101'),
                _demoButton('Library', 'CAMPUS_LIBRARY'),
                _demoButton("Principal", 'CAMPUS_PRINCIPAL'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _demoButton(String label, String qrCode) {
    return OutlinedButton(
      onPressed: () => _handleScan(qrCode),
      child: Text(label),
    );
  }
  
  void _handleScan(String qrCode) {
    final graph = ref.read(campusGraphProvider);
    final node = graph.getNodeByQrCode(qrCode);
    
    if (node != null) {
      ref.read(currentPositionProvider.notifier).state = node;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location: ${node.name}'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unknown QR code'), backgroundColor: Colors.red),
      );
    }
  }
}

class _ScannerPainter extends CustomPainter {
  final double animationValue;
  _ScannerPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 80);
    const frameSize = 250.0;
    final frameRect = Rect.fromCenter(center: center, width: frameSize, height: frameSize);
    
    // Dark overlay with cutout
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(frameRect, const Radius.circular(24)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(overlayPath, Paint()..color = Colors.black54);
    
    // Frame border
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(24)),
      Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3,
    );
    
    // Scan line
    final lineY = frameRect.top + (frameRect.height * animationValue);
    canvas.drawLine(
      Offset(frameRect.left + 20, lineY),
      Offset(frameRect.right - 20, lineY),
      Paint()..color = AppColors.primary..strokeWidth = 3,
    );
  }
  
  @override
  bool shouldRepaint(covariant _ScannerPainter oldDelegate) => true;
}
