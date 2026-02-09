import 'nav_node.dart';
import 'nav_edge.dart';

/// Graph data structure for campus navigation
class CampusGraph {
  final Map<String, NavNode> _nodes = {};
  final Map<String, List<NavEdge>> _adjacencyList = {};
  
  /// Get all nodes
  Map<String, NavNode> get nodes => Map.unmodifiable(_nodes);
  
  /// Get adjacency list
  Map<String, List<NavEdge>> get adjacencyList => Map.unmodifiable(_adjacencyList);
  
  /// Get all nodes as list
  List<NavNode> get nodesList => _nodes.values.toList();
  
  /// Get searchable nodes (rooms, entrances, restrooms)
  List<NavNode> get searchableNodes => 
      _nodes.values.where((n) => n.type.isSearchable).toList();
  
  /// Get nodes for a specific floor
  List<NavNode> nodesForFloor(int floor) =>
      _nodes.values.where((n) => n.floor == floor).toList();
  
  /// Add a node to the graph
  void addNode(NavNode node) {
    _nodes[node.id] = node;
    _adjacencyList.putIfAbsent(node.id, () => []);
  }
  
  /// Remove a node and all connected edges
  void removeNode(String nodeId) {
    _nodes.remove(nodeId);
    _adjacencyList.remove(nodeId);
    
    // Remove edges pointing to this node
    for (final edges in _adjacencyList.values) {
      edges.removeWhere((e) => e.toNodeId == nodeId);
    }
  }
  
  /// Add an edge between two nodes
  void addEdge(NavEdge edge) {
    // Add forward edge
    _adjacencyList.putIfAbsent(edge.fromNodeId, () => []);
    _adjacencyList[edge.fromNodeId]!.add(edge);
    
    // Add reverse edge if bidirectional
    if (edge.isBidirectional) {
      _adjacencyList.putIfAbsent(edge.toNodeId, () => []);
      _adjacencyList[edge.toNodeId]!.add(edge.reversed);
    }
  }
  
  /// Remove an edge
  void removeEdge(String edgeId) {
    for (final edges in _adjacencyList.values) {
      edges.removeWhere((e) => e.id == edgeId || e.id == '${edgeId}_reversed');
    }
  }
  
  /// Get node by ID
  NavNode? getNode(String nodeId) => _nodes[nodeId];
  
  /// Get node by QR code
  NavNode? getNodeByQrCode(String qrCode) {
    try {
      return _nodes.values.firstWhere((n) => n.qrCode == qrCode);
    } catch (_) {
      return null;
    }
  }
  
  /// Get neighbors of a node
  List<NavNode> getNeighbors(String nodeId) {
    final edges = _adjacencyList[nodeId] ?? [];
    return edges
        .map((e) => _nodes[e.toNodeId])
        .where((n) => n != null)
        .cast<NavNode>()
        .toList();
  }
  
  /// Get edges from a node
  List<NavEdge> getEdgesFrom(String nodeId) {
    return _adjacencyList[nodeId] ?? [];
  }
  
  /// Search nodes by query
  List<NavNode> searchNodes(String query) {
    if (query.isEmpty) return searchableNodes;
    
    return searchableNodes
        .where((n) => n.matchesSearch(query))
        .toList()
      ..sort((a, b) {
        // Prioritize exact name matches
        final aExact = a.name.toLowerCase() == query.toLowerCase();
        final bExact = b.name.toLowerCase() == query.toLowerCase();
        if (aExact && !bExact) return -1;
        if (bExact && !aExact) return 1;
        
        // Then by name starts with query
        final aStarts = a.name.toLowerCase().startsWith(query.toLowerCase());
        final bStarts = b.name.toLowerCase().startsWith(query.toLowerCase());
        if (aStarts && !bStarts) return -1;
        if (bStarts && !aStarts) return 1;
        
        return a.name.compareTo(b.name);
      });
  }
  
  /// Clear all data
  void clear() {
    _nodes.clear();
    _adjacencyList.clear();
  }
  
  /// Load from raw data
  void loadFromData({
    required List<NavNode> nodes,
    required List<NavEdge> edges,
  }) {
    clear();
    for (final node in nodes) {
      addNode(node);
    }
    for (final edge in edges) {
      addEdge(edge);
    }
  }
  
  /// Calculate edge weight from node positions
  static double calculateWeight(NavNode from, NavNode to) {
    final dx = to.x - from.x;
    final dy = to.y - from.y;
    final distance = _sqrt(dx * dx + dy * dy);
    
    // Add floor change penalty
    final floorPenalty = (to.floor - from.floor).abs() * 10.0;
    
    return distance + floorPenalty;
  }
  
  /// Get statistics
  Map<String, dynamic> get statistics => {
    'totalNodes': _nodes.length,
    'totalEdges': _adjacencyList.values.fold<int>(0, (sum, edges) => sum + edges.length) ~/ 2,
    'searchableNodes': searchableNodes.length,
    'floors': _nodes.values.map((n) => n.floor).toSet().toList()..sort(),
    'nodeTypes': NodeType.values.map((t) => {
      'type': t.name,
      'count': _nodes.values.where((n) => n.type == t).length,
    }).toList(),
  };
  
  @override
  String toString() {
    final stats = statistics;
    return 'CampusGraph(nodes: ${stats['totalNodes']}, edges: ${stats['totalEdges']})';
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
