import 'package:flutter/material.dart';

/// Types of navigation nodes in the campus
enum NodeType {
  room,       // Classrooms, labs, offices
  corridor,   // Hallway intersection points
  staircase,  // Stairs between floors
  elevator,   // Elevator access points
  entrance,   // Building entrances
  restroom,   // Restrooms
  utility,    // Other utility areas
}

/// Extension to get display properties for node types
extension NodeTypeExtension on NodeType {
  String get displayName {
    switch (this) {
      case NodeType.room:
        return 'Room';
      case NodeType.corridor:
        return 'Corridor';
      case NodeType.staircase:
        return 'Staircase';
      case NodeType.elevator:
        return 'Elevator';
      case NodeType.entrance:
        return 'Entrance';
      case NodeType.restroom:
        return 'Restroom';
      case NodeType.utility:
        return 'Utility';
    }
  }
  
  IconData get icon {
    switch (this) {
      case NodeType.room:
        return Icons.meeting_room_outlined;
      case NodeType.corridor:
        return Icons.route_outlined;
      case NodeType.staircase:
        return Icons.stairs_outlined;
      case NodeType.elevator:
        return Icons.elevator_outlined;
      case NodeType.entrance:
        return Icons.door_front_door_outlined;
      case NodeType.restroom:
        return Icons.wc_outlined;
      case NodeType.utility:
        return Icons.build_outlined;
    }
  }
  
  Color get color {
    switch (this) {
      case NodeType.room:
        return const Color(0xFF2563EB);
      case NodeType.corridor:
        return const Color(0xFF64748B);
      case NodeType.staircase:
        return const Color(0xFFF59E0B);
      case NodeType.elevator:
        return const Color(0xFF8B5CF6);
      case NodeType.entrance:
        return const Color(0xFF22C55E);
      case NodeType.restroom:
        return const Color(0xFF0EA5E9);
      case NodeType.utility:
        return const Color(0xFF6B7280);
    }
  }
  
  /// Whether this node type can be a navigation destination
  bool get isSearchable {
    switch (this) {
      case NodeType.room:
      case NodeType.restroom:
      case NodeType.entrance:
        return true;
      default:
        return false;
    }
  }
}

/// Represents a navigation node (waypoint) on the campus map
class NavNode {
  final String id;
  final String name;
  final String? description;
  final double x;  // X coordinate on floor plan (percentage 0-100 or pixels)
  final double y;  // Y coordinate on floor plan
  final int floor;
  final NodeType type;
  final List<String> keywords;  // Search keywords
  final String? qrCode;  // QR code identifier for this location
  final bool isAccessible;  // Wheelchair accessible
  final String? imageUrl;  // Optional image of the location
  
  const NavNode({
    required this.id,
    required this.name,
    this.description,
    required this.x,
    required this.y,
    required this.floor,
    required this.type,
    this.keywords = const [],
    this.qrCode,
    this.isAccessible = true,
    this.imageUrl,
  });
  
  /// Create from JSON (Firestore document)
  factory NavNode.fromJson(Map<String, dynamic> json) {
    return NavNode(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      floor: json['floor'] as int,
      type: NodeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NodeType.room,
      ),
      keywords: List<String>.from(json['keywords'] ?? []),
      qrCode: json['qrCode'] as String?,
      isAccessible: json['isAccessible'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
    );
  }
  
  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'x': x,
      'y': y,
      'floor': floor,
      'type': type.name,
      'keywords': keywords,
      'qrCode': qrCode,
      'isAccessible': isAccessible,
      'imageUrl': imageUrl,
    };
  }
  
  /// Create a copy with modified properties
  NavNode copyWith({
    String? id,
    String? name,
    String? description,
    double? x,
    double? y,
    int? floor,
    NodeType? type,
    List<String>? keywords,
    String? qrCode,
    bool? isAccessible,
    String? imageUrl,
  }) {
    return NavNode(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      x: x ?? this.x,
      y: y ?? this.y,
      floor: floor ?? this.floor,
      type: type ?? this.type,
      keywords: keywords ?? this.keywords,
      qrCode: qrCode ?? this.qrCode,
      isAccessible: isAccessible ?? this.isAccessible,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
  
  /// Calculate distance to another node (Euclidean)
  double distanceTo(NavNode other) {
    final dx = other.x - x;
    final dy = other.y - y;
    return (dx * dx + dy * dy).sqrt();
  }
  
  /// Check if this node matches a search query
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
           keywords.any((k) => k.toLowerCase().contains(lowerQuery)) ||
           (description?.toLowerCase().contains(lowerQuery) ?? false);
  }
  
  @override
  String toString() => 'NavNode($name, floor: $floor, type: ${type.name})';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavNode &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Extension method for sqrt
extension NumExtension on num {
  double sqrt() => this < 0 ? 0 : this.toDouble().sqrt();
}

extension DoubleExtension on double {
  double sqrt() {
    if (this < 0) return 0;
    double x = this;
    double y = 1;
    const double e = 0.000001;
    while (x - y > e) {
      x = (x + y) / 2;
      y = this / x;
    }
    return x;
  }
}
