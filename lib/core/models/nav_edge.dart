/// Represents a connection between two navigation nodes
class NavEdge {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  final double weight;  // Distance in meters or arbitrary units
  final bool isAccessible;  // Wheelchair accessible
  final bool isBidirectional;  // Can traverse both ways
  
  const NavEdge({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.weight,
    this.isAccessible = true,
    this.isBidirectional = true,
  });
  
  /// Create from JSON (Firestore document)
  factory NavEdge.fromJson(Map<String, dynamic> json) {
    return NavEdge(
      id: json['id'] as String,
      fromNodeId: json['fromNodeId'] as String,
      toNodeId: json['toNodeId'] as String,
      weight: (json['weight'] as num).toDouble(),
      isAccessible: json['isAccessible'] as bool? ?? true,
      isBidirectional: json['isBidirectional'] as bool? ?? true,
    );
  }
  
  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromNodeId': fromNodeId,
      'toNodeId': toNodeId,
      'weight': weight,
      'isAccessible': isAccessible,
      'isBidirectional': isBidirectional,
    };
  }
  
  /// Create a copy with modified properties
  NavEdge copyWith({
    String? id,
    String? fromNodeId,
    String? toNodeId,
    double? weight,
    bool? isAccessible,
    bool? isBidirectional,
  }) {
    return NavEdge(
      id: id ?? this.id,
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      weight: weight ?? this.weight,
      isAccessible: isAccessible ?? this.isAccessible,
      isBidirectional: isBidirectional ?? this.isBidirectional,
    );
  }
  
  /// Get the reverse edge (for bidirectional paths)
  NavEdge get reversed => NavEdge(
    id: '${id}_reversed',
    fromNodeId: toNodeId,
    toNodeId: fromNodeId,
    weight: weight,
    isAccessible: isAccessible,
    isBidirectional: isBidirectional,
  );
  
  @override
  String toString() => 'NavEdge($fromNodeId -> $toNodeId, weight: $weight)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavEdge &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
