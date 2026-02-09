import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/navigation_providers.dart';
import '../../../core/models/models.dart';
import '../../navigation/widgets/floor_plan_viewer.dart';
import 'node_editor_screen.dart';

/// Admin dashboard for managing campus map data
class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graph = ref.watch(campusGraphProvider);
    final stats = graph.statistics;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Stats Cards
                  Row(
                    children: [
                      _StatCard(title: 'Total Nodes', value: '${stats['totalNodes']}', icon: Icons.place, color: AppColors.primary),
                      const SizedBox(width: 12),
                      _StatCard(title: 'Total Edges', value: '${stats['totalEdges']}', icon: Icons.timeline, color: AppColors.secondary),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatCard(title: 'Searchable', value: '${stats['searchableNodes']}', icon: Icons.search, color: AppColors.accent),
                      const SizedBox(width: 12),
                      _StatCard(title: 'Floors', value: '${(stats['floors'] as List).length}', icon: Icons.layers, color: const Color(0xFF8B5CF6)),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  _ActionCard(
                    icon: Icons.add_location_alt,
                    title: 'Add New Node',
                    subtitle: 'Add a room, entrance, or waypoint',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NodeEditorScreen())),
                  ),
                  _ActionCard(
                    icon: Icons.edit_location_alt,
                    title: 'Edit Map (Visual)',
                    subtitle: 'Tap on map to add/edit nodes',
                    onTap: () => _openVisualEditor(context, ref),
                  ),
                  _ActionCard(
                    icon: Icons.qr_code,
                    title: 'Generate QR Codes',
                    subtitle: 'Create QR codes for locations',
                    onTap: () => _showQRGenerator(context, ref),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Node List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('All Nodes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      TextButton(onPressed: () {}, child: const Text('See All')),
                    ],
                  ),
                  ...graph.nodesList.take(5).map((node) => _NodeTile(node: node)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: AppColors.warning.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.admin_panel_settings, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text('Manage campus map data', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _openVisualEditor(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, color: Colors.grey.shade300),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Tap on map to add node', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: FloorPlanViewer(
                  showNodes: true,
                  isEditable: true,
                  onTap: (x, y) {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => NodeEditorScreen(initialX: x, initialY: y),
                    ));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showQRGenerator(BuildContext context, WidgetRef ref) {
    final graph = ref.read(campusGraphProvider);
    final nodesWithQR = graph.nodesList.where((n) => n.qrCode != null).toList();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('QR Codes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            ...nodesWithQR.take(5).map((node) => ListTile(
              leading: const Icon(Icons.qr_code),
              title: Text(node.name),
              subtitle: Text(node.qrCode!),
              trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.copy)),
            )),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});
  
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: TextStyle(color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _NodeTile extends ConsumerWidget {
  final NavNode node;
  
  const _NodeTile({required this.node});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: node.type.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(node.type.icon, color: node.type.color),
        ),
        title: Text(node.name),
        subtitle: Text('Floor ${node.floor} • (${node.x.toStringAsFixed(1)}, ${node.y.toStringAsFixed(1)})'),
        trailing: IconButton(
          icon: const Icon(Icons.edit, size: 20),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NodeEditorScreen(existingNode: node))),
        ),
      ),
    );
  }
}
