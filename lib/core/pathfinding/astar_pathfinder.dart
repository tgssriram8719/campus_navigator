import 'dart:collection';
import '../models/nav_node.dart';
import '../models/nav_edge.dart';
import '../models/campus_graph.dart';

/// Result of pathfinding operation
class PathResult {
  final List<NavNode> path;
  final double totalDistance;
  final int floorsTraversed;
  final Duration estimatedTime;
  final List<String> directions;
  
  const PathResult({
    required this.path,
    required this.totalDistance,
    required this.floorsTraversed,
    required this.estimatedTime,
    required this.directions,
  });
  
  bool get isFound => path.isNotEmpty;
  
  /// Create an empty result (no path found)
  factory PathResult.notFound() => const PathResult(
    path: [],
    totalDistance: 0,
    floorsTraversed: 0,
    estimatedTime: Duration.zero,
    directions: ['No path found'],
  );
}

/// A* Pathfinding algorithm for indoor navigation
class AStarPathfinder {
  final CampusGraph graph;
  
  /// Walking speed in meters per second (average human walking speed)
  static const double walkingSpeed = 1.4;
  
  /// Additional time per floor change in seconds
  static const double floorChangeTime = 30.0;
  
  AStarPathfinder(this.graph);
  
  /// Find the shortest path between two nodes using A* algorithm
  PathResult findPath(String startId, String goalId, {bool accessibleOnly = false}) {
    // Validate start and goal nodes exist
    if (!graph.nodes.containsKey(startId) || !graph.nodes.containsKey(goalId)) {
      return PathResult.notFound();
    }
    
    if (startId == goalId) {
      final node = graph.nodes[startId]!;
      return PathResult(
        path: [node],
        totalDistance: 0,
        floorsTraversed: 0,
        estimatedTime: Duration.zero,
        directions: ['You are already at ${node.name}'],
      );
    }
    
    // Priority queue for open set (nodes to explore)
    final openSet = PriorityQueue<_AStarNode>(
      (a, b) => a.fScore.compareTo(b.fScore),
    );
    
    // Track g-scores (cost from start to node)
    final gScore = <String, double>{};
    
    // Track f-scores (g + heuristic)
    final fScore = <String, double>{};
    
    // Track path reconstruction
    final cameFrom = <String, String>{};
    
    // Track visited nodes
    final visited = <String>{};
    
    // Initialize start node
    gScore[startId] = 0;
    fScore[startId] = _heuristic(startId, goalId);
    openSet.add(_AStarNode(startId, fScore[startId]!));
    
    while (openSet.isNotEmpty) {
      final current = openSet.removeFirst();
      
      // Skip if already visited
      if (visited.contains(current.nodeId)) continue;
      visited.add(current.nodeId);
      
      // Goal reached!
      if (current.nodeId == goalId) {
        return _reconstructPath(cameFrom, goalId, gScore[goalId]!);
      }
      
      // Explore neighbors
      for (final edge in graph.getEdgesFrom(current.nodeId)) {
        // Skip non-accessible edges if required
        if (accessibleOnly && !edge.isAccessible) continue;
        
        final neighbor = edge.toNodeId;
        
        // Skip if already visited
        if (visited.contains(neighbor)) continue;
        
        // Calculate tentative g-score
        final tentativeG = gScore[current.nodeId]! + edge.weight;
        
        // If this path is better than previous
        if (tentativeG < (gScore[neighbor] ?? double.infinity)) {
          cameFrom[neighbor] = current.nodeId;
          gScore[neighbor] = tentativeG;
          fScore[neighbor] = tentativeG + _heuristic(neighbor, goalId);
          
          openSet.add(_AStarNode(neighbor, fScore[neighbor]!));
        }
      }
    }
    
    // No path found
    return PathResult.notFound();
  }
  
  /// Heuristic function (Euclidean distance + floor penalty)
  double _heuristic(String fromId, String toId) {
    final from = graph.nodes[fromId]!;
    final to = graph.nodes[toId]!;
    
    // Euclidean distance
    final dx = to.x - from.x;
    final dy = to.y - from.y;
    final distance = _sqrt(dx * dx + dy * dy);
    
    // Floor change penalty (10 units per floor)
    final floorPenalty = (to.floor - from.floor).abs() * 10.0;
    
    return distance + floorPenalty;
  }
  
  /// Reconstruct path from cameFrom map
  PathResult _reconstructPath(
    Map<String, String> cameFrom,
    String goalId,
    double totalDistance,
  ) {
    final path = <NavNode>[];
    var currentId = goalId;
    
    // Build path backwards
    while (cameFrom.containsKey(currentId)) {
      path.insert(0, graph.nodes[currentId]!);
      currentId = cameFrom[currentId]!;
    }
    // Add start node
    path.insert(0, graph.nodes[currentId]!);
    
    // Calculate floors traversed
    final floors = path.map((n) => n.floor).toSet();
    final floorsTraversed = floors.length - 1;
    
    // Calculate estimated time
    final walkTime = totalDistance / walkingSpeed;
    final floorTime = floorsTraversed * floorChangeTime;
    final estimatedTime = Duration(seconds: (walkTime + floorTime).round());
    
    // Generate directions
    final directions = _generateDirections(path);
    
    return PathResult(
      path: path,
      totalDistance: totalDistance,
      floorsTraversed: floorsTraversed,
      estimatedTime: estimatedTime,
      directions: directions,
    );
  }
  
  /// Generate turn-by-turn directions
  List<String> _generateDirections(List<NavNode> path) {
    if (path.isEmpty) return [];
    if (path.length == 1) return ['You are at ${path.first.name}'];
    
    final directions = <String>[];
    directions.add('Start at ${path.first.name}');
    
    for (int i = 1; i < path.length; i++) {
      final prev = path[i - 1];
      final current = path[i];
      
      // Check for floor change
      if (current.floor != prev.floor) {
        final direction = current.floor > prev.floor ? 'up' : 'down';
        final method = current.type == NodeType.elevator ? 'elevator' : 'stairs';
        directions.add('Take the $method $direction to floor ${current.floor}');
      }
      
      // Generate direction based on angle change
      if (i < path.length - 1) {
        final next = path[i + 1];
        final turnDirection = _getTurnDirection(prev, current, next);
        
        if (turnDirection != null && current.type == NodeType.corridor) {
          directions.add('$turnDirection at the corridor');
        }
      }
      
      // Add waypoint info for important nodes
      if (current.type.isSearchable || current.type == NodeType.staircase) {
        if (i == path.length - 1) {
          directions.add('Arrive at ${current.name}');
        } else {
          directions.add('Pass by ${current.name}');
        }
      }
    }
    
    return directions;
  }
  
  /// Determine turn direction based on angle
  String? _getTurnDirection(NavNode prev, NavNode current, NavNode next) {
    // Calculate vectors
    final v1x = current.x - prev.x;
    final v1y = current.y - prev.y;
    final v2x = next.x - current.x;
    final v2y = next.y - current.y;
    
    // Cross product to determine turn direction
    final cross = v1x * v2y - v1y * v2x;
    
    // Threshold for significant turn
    const threshold = 0.5;
    
    if (cross > threshold) {
      return 'Turn right';
    } else if (cross < -threshold) {
      return 'Turn left';
    }
    return null; // Continue straight
  }
  
  /// Find path to nearest node of a specific type
  PathResult findNearestOfType(String startId, NodeType type, {bool accessibleOnly = false}) {
    final candidates = graph.nodes.values
        .where((n) => n.type == type)
        .toList();
    
    if (candidates.isEmpty) {
      return PathResult.notFound();
    }
    
    PathResult? bestPath;
    
    for (final candidate in candidates) {
      final result = findPath(startId, candidate.id, accessibleOnly: accessibleOnly);
      if (result.isFound) {
        if (bestPath == null || result.totalDistance < bestPath.totalDistance) {
          bestPath = result;
        }
      }
    }
    
    return bestPath ?? PathResult.notFound();
  }
}

/// Internal class for A* priority queue
class _AStarNode {
  final String nodeId;
  final double fScore;
  
  _AStarNode(this.nodeId, this.fScore);
}

/// Simple priority queue implementation
class PriorityQueue<T> {
  final List<T> _heap = [];
  final int Function(T, T) _compare;
  
  PriorityQueue(this._compare);
  
  bool get isNotEmpty => _heap.isNotEmpty;
  bool get isEmpty => _heap.isEmpty;
  int get length => _heap.length;
  
  void add(T element) {
    _heap.add(element);
    _bubbleUp(_heap.length - 1);
  }
  
  T removeFirst() {
    if (_heap.isEmpty) throw StateError('Queue is empty');
    
    final first = _heap.first;
    final last = _heap.removeLast();
    
    if (_heap.isNotEmpty) {
      _heap[0] = last;
      _bubbleDown(0);
    }
    
    return first;
  }
  
  void _bubbleUp(int index) {
    while (index > 0) {
      final parentIndex = (index - 1) ~/ 2;
      if (_compare(_heap[index], _heap[parentIndex]) >= 0) break;
      _swap(index, parentIndex);
      index = parentIndex;
    }
  }
  
  void _bubbleDown(int index) {
    while (true) {
      var smallest = index;
      final leftChild = 2 * index + 1;
      final rightChild = 2 * index + 2;
      
      if (leftChild < _heap.length &&
          _compare(_heap[leftChild], _heap[smallest]) < 0) {
        smallest = leftChild;
      }
      
      if (rightChild < _heap.length &&
          _compare(_heap[rightChild], _heap[smallest]) < 0) {
        smallest = rightChild;
      }
      
      if (smallest == index) break;
      _swap(index, smallest);
      index = smallest;
    }
  }
  
  void _swap(int i, int j) {
    final temp = _heap[i];
    _heap[i] = _heap[j];
    _heap[j] = temp;
  }
}

/// Helper sqrt function
double _sqrt(double value) {
  if (value < 0) return 0;
  double x = value;
  double y = 1;
  const double e = 0.000001;
  while (x - y > e) {
    x = (x + y) / 2;
    y = value / x;
  }
  return x;
}
