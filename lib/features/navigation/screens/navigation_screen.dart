import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/navigation_providers.dart';
import '../widgets/floor_plan_viewer.dart';

/// Main navigation screen with turn-by-turn directions
class NavigationScreen extends ConsumerWidget {
  const NavigationScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPosition = ref.watch(currentPositionProvider);
    final destination = ref.watch(destinationProvider);
    final pathResult = ref.watch(pathResultProvider);
    
    return Scaffold(
      body: Column(
        children: [
          // Header with destination info
          _buildHeader(context, ref, destination),
          
          // Map view
          Expanded(
            flex: 3,
            child: const FloorPlanViewer(),
          ),
          
          // Directions panel
          Expanded(
            flex: 2,
            child: _buildDirectionsPanel(context, pathResult),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context, WidgetRef ref, destination) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Navigating to', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(
                  destination?.name ?? 'Unknown',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(destinationProvider.notifier).state = null;
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDirectionsPanel(BuildContext context, pathResult) {
    if (pathResult == null || !pathResult.isFound) {
      return const Center(child: Text('No path found'));
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        children: [
          // Info bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoChip(
                  icon: Icons.straighten,
                  value: '${pathResult.totalDistance.toStringAsFixed(0)}m',
                  label: 'Distance',
                ),
                _InfoChip(
                  icon: Icons.timer,
                  value: '${pathResult.estimatedTime.inMinutes}min',
                  label: 'Time',
                ),
                _InfoChip(
                  icon: Icons.stairs,
                  value: '${pathResult.floorsTraversed}',
                  label: 'Floors',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Directions list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pathResult.directions.length,
              itemBuilder: (context, index) {
                return _DirectionStep(
                  step: index + 1,
                  instruction: pathResult.directions[index],
                  isLast: index == pathResult.directions.length - 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  
  const _InfoChip({required this.icon, required this.value, required this.label});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }
}

class _DirectionStep extends StatelessWidget {
  final int step;
  final String instruction;
  final bool isLast;
  
  const _DirectionStep({required this.step, required this.instruction, required this.isLast});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isLast ? AppColors.success : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isLast
                    ? const Icon(Icons.flag, color: Colors.white, size: 16)
                    : Text('$step', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 30, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(instruction, style: const TextStyle(fontSize: 15)),
          ),
        ),
      ],
    );
  }
}
