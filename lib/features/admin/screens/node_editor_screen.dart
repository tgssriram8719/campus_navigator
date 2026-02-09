import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/navigation_providers.dart';
import '../../../core/models/models.dart';

/// Screen for adding/editing navigation nodes
class NodeEditorScreen extends ConsumerStatefulWidget {
  final NavNode? existingNode;
  final double? initialX;
  final double? initialY;
  
  const NodeEditorScreen({super.key, this.existingNode, this.initialX, this.initialY});
  
  @override
  ConsumerState<NodeEditorScreen> createState() => _NodeEditorScreenState();
}

class _NodeEditorScreenState extends ConsumerState<NodeEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _xController;
  late TextEditingController _yController;
  late TextEditingController _qrCodeController;
  late TextEditingController _keywordsController;
  
  NodeType _selectedType = NodeType.room;
  int _selectedFloor = 0;
  bool _isAccessible = true;
  
  @override
  void initState() {
    super.initState();
    final node = widget.existingNode;
    _nameController = TextEditingController(text: node?.name ?? '');
    _descriptionController = TextEditingController(text: node?.description ?? '');
    _xController = TextEditingController(text: (node?.x ?? widget.initialX ?? 50).toString());
    _yController = TextEditingController(text: (node?.y ?? widget.initialY ?? 50).toString());
    _qrCodeController = TextEditingController(text: node?.qrCode ?? '');
    _keywordsController = TextEditingController(text: node?.keywords.join(', ') ?? '');
    
    if (node != null) {
      _selectedType = node.type;
      _selectedFloor = node.floor;
      _isAccessible = node.isAccessible;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _xController.dispose();
    _yController.dispose();
    _qrCodeController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingNode != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Node' : 'Add New Node'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteNode,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name *', hintText: 'e.g., Room 101 - Physics Lab'),
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description', hintText: 'Brief description of location'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            // Type dropdown
            DropdownButtonFormField<NodeType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Type *'),
              items: NodeType.values.map((type) => DropdownMenuItem(
                value: type,
                child: Row(
                  children: [
                    Icon(type.icon, color: type.color, size: 20),
                    const SizedBox(width: 8),
                    Text(type.displayName),
                  ],
                ),
              )).toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
            ),
            const SizedBox(height: 16),
            
            // Floor
            DropdownButtonFormField<int>(
              value: _selectedFloor,
              decoration: const InputDecoration(labelText: 'Floor *'),
              items: [0, 1, 2, 3].map((f) => DropdownMenuItem(
                value: f,
                child: Text(f == 0 ? 'Ground Floor' : 'Floor $f'),
              )).toList(),
              onChanged: (v) => setState(() => _selectedFloor = v!),
            ),
            const SizedBox(height: 16),
            
            // Coordinates
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _xController,
                    decoration: const InputDecoration(labelText: 'X Coordinate'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _yController,
                    decoration: const InputDecoration(labelText: 'Y Coordinate'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // QR Code
            TextFormField(
              controller: _qrCodeController,
              decoration: InputDecoration(
                labelText: 'QR Code (Optional)',
                hintText: 'e.g., CAMPUS_ROOM_101',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.auto_fix_high),
                  onPressed: _generateQRCode,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Keywords
            TextFormField(
              controller: _keywordsController,
              decoration: const InputDecoration(labelText: 'Search Keywords', hintText: 'Comma separated: physics, lab, science'),
            ),
            const SizedBox(height: 16),
            
            // Accessible
            SwitchListTile(
              title: const Text('Wheelchair Accessible'),
              value: _isAccessible,
              onChanged: (v) => setState(() => _isAccessible = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            
            // Save button
            ElevatedButton.icon(
              onPressed: _saveNode,
              icon: const Icon(Icons.save),
              label: Text(isEditing ? 'Update Node' : 'Add Node'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ],
        ),
      ),
    );
  }
  
  void _generateQRCode() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    
    final code = 'CAMPUS_${name.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '_')}';
    _qrCodeController.text = code;
  }
  
  void _saveNode() {
    if (!_formKey.currentState!.validate()) return;
    
    final keywords = _keywordsController.text
        .split(',')
        .map((k) => k.trim())
        .where((k) => k.isNotEmpty)
        .toList();
    
    final node = NavNode(
      id: widget.existingNode?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      x: double.tryParse(_xController.text) ?? 50,
      y: double.tryParse(_yController.text) ?? 50,
      floor: _selectedFloor,
      type: _selectedType,
      keywords: keywords,
      qrCode: _qrCodeController.text.trim().isEmpty ? null : _qrCodeController.text.trim(),
      isAccessible: _isAccessible,
    );
    
    if (widget.existingNode != null) {
      ref.read(campusGraphProvider.notifier).updateNode(node);
    } else {
      ref.read(campusGraphProvider.notifier).addNode(node);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.existingNode != null ? 'Node updated!' : 'Node added!'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }
  
  void _deleteNode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Node'),
        content: Text('Are you sure you want to delete "${widget.existingNode?.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(campusGraphProvider.notifier).removeNode(widget.existingNode!.id);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Node deleted'), backgroundColor: Colors.red),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
