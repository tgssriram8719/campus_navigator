/// Represents a floor plan for a building
class FloorPlan {
  final String id;
  final String buildingId;
  final String buildingName;
  final int floorNumber;
  final String floorName;  // e.g., "Ground Floor", "First Floor"
  final String imageUrl;  // URL or local path to floor plan image
  final double width;  // Real-world width in meters
  final double height;  // Real-world height in meters
  final double imageWidth;  // Image width in pixels
  final double imageHeight;  // Image height in pixels
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const FloorPlan({
    required this.id,
    required this.buildingId,
    required this.buildingName,
    required this.floorNumber,
    required this.floorName,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.imageWidth,
    required this.imageHeight,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Pixels per meter ratio for X axis
  double get pixelsPerMeterX => imageWidth / width;
  
  /// Pixels per meter ratio for Y axis
  double get pixelsPerMeterY => imageHeight / height;
  
  /// Convert real-world coordinates to pixel coordinates
  Offset realToPixel(double realX, double realY) {
    return Offset(
      realX * pixelsPerMeterX,
      realY * pixelsPerMeterY,
    );
  }
  
  /// Convert pixel coordinates to real-world coordinates
  Offset pixelToReal(double pixelX, double pixelY) {
    return Offset(
      pixelX / pixelsPerMeterX,
      pixelY / pixelsPerMeterY,
    );
  }
  
  /// Create from JSON (Firestore document)
  factory FloorPlan.fromJson(Map<String, dynamic> json) {
    return FloorPlan(
      id: json['id'] as String,
      buildingId: json['buildingId'] as String,
      buildingName: json['buildingName'] as String,
      floorNumber: json['floorNumber'] as int,
      floorName: json['floorName'] as String,
      imageUrl: json['imageUrl'] as String,
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      imageWidth: (json['imageWidth'] as num).toDouble(),
      imageHeight: (json['imageHeight'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
  
  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buildingId': buildingId,
      'buildingName': buildingName,
      'floorNumber': floorNumber,
      'floorName': floorName,
      'imageUrl': imageUrl,
      'width': width,
      'height': height,
      'imageWidth': imageWidth,
      'imageHeight': imageHeight,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  /// Create a copy with modified properties
  FloorPlan copyWith({
    String? id,
    String? buildingId,
    String? buildingName,
    int? floorNumber,
    String? floorName,
    String? imageUrl,
    double? width,
    double? height,
    double? imageWidth,
    double? imageHeight,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FloorPlan(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      buildingName: buildingName ?? this.buildingName,
      floorNumber: floorNumber ?? this.floorNumber,
      floorName: floorName ?? this.floorName,
      imageUrl: imageUrl ?? this.imageUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  String toString() => 'FloorPlan($buildingName - $floorName)';
}

/// Helper class for Offset since we can't import flutter in pure Dart
class Offset {
  final double dx;
  final double dy;
  const Offset(this.dx, this.dy);
}
