import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../pathfinding/astar_pathfinder.dart';

/// Provider for the campus graph
final campusGraphProvider = StateNotifierProvider<CampusGraphNotifier, CampusGraph>((ref) {
  return CampusGraphNotifier();
});

/// Provider for current user position (from QR scan)
final currentPositionProvider = StateProvider<NavNode?>((ref) => null);

/// Provider for selected destination
final destinationProvider = StateProvider<NavNode?>((ref) => null);

/// Provider for current floor being viewed
final currentFloorProvider = StateProvider<int>((ref) => 0);

/// Provider for pathfinding result
final pathResultProvider = Provider<PathResult?>((ref) {
  final graph = ref.watch(campusGraphProvider);
  final currentPosition = ref.watch(currentPositionProvider);
  final destination = ref.watch(destinationProvider);
  
  if (currentPosition == null || destination == null) {
    return null;
  }
  
  final pathfinder = AStarPathfinder(graph);
  return pathfinder.findPath(currentPosition.id, destination.id);
});

/// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for filtered search results
final searchResultsProvider = Provider<List<NavNode>>((ref) {
  final graph = ref.watch(campusGraphProvider);
  final query = ref.watch(searchQueryProvider);
  
  return graph.searchNodes(query);
});

/// Provider for admin mode
final isAdminModeProvider = StateProvider<bool>((ref) => false);

/// State notifier for campus graph
class CampusGraphNotifier extends StateNotifier<CampusGraph> {
  CampusGraphNotifier() : super(CampusGraph()) {
    // Load sample data for testing
    _loadSampleData();
  }
  
  void addNode(NavNode node) {
    state.addNode(node);
    state = state; // Trigger rebuild
  }
  
  void removeNode(String nodeId) {
    state.removeNode(nodeId);
    state = state;
  }
  
  void updateNode(NavNode node) {
    state.addNode(node); // addNode replaces if exists
    state = state;
  }
  
  void addEdge(NavEdge edge) {
    state.addEdge(edge);
    state = state;
  }
  
  void removeEdge(String edgeId) {
    state.removeEdge(edgeId);
    state = state;
  }
  
  void loadFromData({required List<NavNode> nodes, required List<NavEdge> edges}) {
    state.loadFromData(nodes: nodes, edges: edges);
    state = state;
  }
  
  void clear() {
    state.clear();
    state = state;
  }
  
  /// Load sample data for testing the app
  void _loadSampleData() {
    // Sample nodes for a ground floor
    final nodes = [
      // Entrance
      NavNode(
        id: 'entrance_main',
        name: 'Main Entrance',
        description: 'Main entrance of the building',
        x: 50,
        y: 95,
        floor: 0,
        type: NodeType.entrance,
        qrCode: 'CAMPUS_MAIN_ENTRANCE',
        keywords: ['entrance', 'main', 'gate', 'door'],
      ),
      
      // Corridor points
      NavNode(
        id: 'corridor_1',
        name: 'Main Corridor',
        x: 50,
        y: 80,
        floor: 0,
        type: NodeType.corridor,
      ),
      NavNode(
        id: 'corridor_2',
        name: 'Left Wing Corridor',
        x: 25,
        y: 80,
        floor: 0,
        type: NodeType.corridor,
      ),
      NavNode(
        id: 'corridor_3',
        name: 'Right Wing Corridor',
        x: 75,
        y: 80,
        floor: 0,
        type: NodeType.corridor,
      ),
      NavNode(
        id: 'corridor_4',
        name: 'North Corridor',
        x: 50,
        y: 50,
        floor: 0,
        type: NodeType.corridor,
      ),
      NavNode(
        id: 'corridor_5',
        name: 'Left North Corridor',
        x: 25,
        y: 50,
        floor: 0,
        type: NodeType.corridor,
      ),
      NavNode(
        id: 'corridor_6',
        name: 'Right North Corridor',
        x: 75,
        y: 50,
        floor: 0,
        type: NodeType.corridor,
      ),
      
      // Rooms - Left Wing
      NavNode(
        id: 'room_101',
        name: 'Room 101 - Physics Lab',
        description: 'Physics Laboratory with experimental equipment',
        x: 10,
        y: 70,
        floor: 0,
        type: NodeType.room,
        qrCode: 'CAMPUS_ROOM_101',
        keywords: ['physics', 'lab', 'laboratory', '101'],
      ),
      NavNode(
        id: 'room_102',
        name: 'Room 102 - Chemistry Lab',
        description: 'Chemistry Laboratory',
        x: 10,
        y: 55,
        floor: 0,
        type: NodeType.room,
        qrCode: 'CAMPUS_ROOM_102',
        keywords: ['chemistry', 'lab', 'laboratory', '102'],
      ),
      
      // Rooms - Right Wing
      NavNode(
        id: 'room_103',
        name: 'Room 103 - Computer Lab',
        description: 'Computer Science Laboratory with 50 workstations',
        x: 90,
        y: 70,
        floor: 0,
        type: NodeType.room,
        qrCode: 'CAMPUS_ROOM_103',
        keywords: ['computer', 'lab', 'cs', 'it', '103'],
      ),
      NavNode(
        id: 'room_104',
        name: 'Room 104 - Electronics Lab',
        description: 'Electronics and Communication Lab',
        x: 90,
        y: 55,
        floor: 0,
        type: NodeType.room,
        qrCode: 'CAMPUS_ROOM_104',
        keywords: ['electronics', 'lab', 'ece', '104'],
      ),
      
      // Admin Area
      NavNode(
        id: 'principal_office',
        name: "Principal's Office",
        description: 'Office of the Principal',
        x: 50,
        y: 25,
        floor: 0,
        type: NodeType.room,
        qrCode: 'CAMPUS_PRINCIPAL',
        keywords: ['principal', 'office', 'admin', 'head'],
      ),
      NavNode(
        id: 'admin_office',
        name: 'Administrative Office',
        description: 'Main administrative office for inquiries',
        x: 35,
        y: 25,
        floor: 0,
        type: NodeType.room,
        qrCode: 'CAMPUS_ADMIN',
        keywords: ['admin', 'office', 'administration', 'inquiry'],
      ),
      
      // Library
      NavNode(
        id: 'library',
        name: 'Library',
        description: 'Central Library with study area',
        x: 65,
        y: 25,
        floor: 0,
        type: NodeType.room,
        qrCode: 'CAMPUS_LIBRARY',
        keywords: ['library', 'books', 'study', 'reading'],
      ),
      
      // Restrooms
      NavNode(
        id: 'restroom_left',
        name: 'Restroom (Left Wing)',
        x: 25,
        y: 65,
        floor: 0,
        type: NodeType.restroom,
        keywords: ['restroom', 'toilet', 'washroom', 'bathroom'],
      ),
      NavNode(
        id: 'restroom_right',
        name: 'Restroom (Right Wing)',
        x: 75,
        y: 65,
        floor: 0,
        type: NodeType.restroom,
        keywords: ['restroom', 'toilet', 'washroom', 'bathroom'],
      ),
      
      // Staircase
      NavNode(
        id: 'staircase_main',
        name: 'Main Staircase',
        x: 50,
        y: 40,
        floor: 0,
        type: NodeType.staircase,
        qrCode: 'CAMPUS_STAIRS_MAIN',
        keywords: ['stairs', 'staircase'],
      ),
      
      // Additional corridor for north section
      NavNode(
        id: 'corridor_north',
        name: 'North Corridor',
        x: 50,
        y: 30,
        floor: 0,
        type: NodeType.corridor,
      ),
    ];
    
    // Create edges connecting nodes
    final edges = [
      // Main entrance to corridor
      NavEdge(id: 'e1', fromNodeId: 'entrance_main', toNodeId: 'corridor_1', weight: 5),
      
      // Main corridor connections
      NavEdge(id: 'e2', fromNodeId: 'corridor_1', toNodeId: 'corridor_2', weight: 8),
      NavEdge(id: 'e3', fromNodeId: 'corridor_1', toNodeId: 'corridor_3', weight: 8),
      NavEdge(id: 'e4', fromNodeId: 'corridor_1', toNodeId: 'corridor_4', weight: 10),
      
      // Left wing
      NavEdge(id: 'e5', fromNodeId: 'corridor_2', toNodeId: 'corridor_5', weight: 10),
      NavEdge(id: 'e6', fromNodeId: 'corridor_2', toNodeId: 'room_101', weight: 5),
      NavEdge(id: 'e7', fromNodeId: 'corridor_5', toNodeId: 'room_102', weight: 5),
      NavEdge(id: 'e8', fromNodeId: 'corridor_2', toNodeId: 'restroom_left', weight: 3),
      
      // Right wing
      NavEdge(id: 'e9', fromNodeId: 'corridor_3', toNodeId: 'corridor_6', weight: 10),
      NavEdge(id: 'e10', fromNodeId: 'corridor_3', toNodeId: 'room_103', weight: 5),
      NavEdge(id: 'e11', fromNodeId: 'corridor_6', toNodeId: 'room_104', weight: 5),
      NavEdge(id: 'e12', fromNodeId: 'corridor_3', toNodeId: 'restroom_right', weight: 3),
      
      // North section
      NavEdge(id: 'e13', fromNodeId: 'corridor_4', toNodeId: 'staircase_main', weight: 4),
      NavEdge(id: 'e14', fromNodeId: 'staircase_main', toNodeId: 'corridor_north', weight: 3),
      NavEdge(id: 'e15', fromNodeId: 'corridor_north', toNodeId: 'principal_office', weight: 3),
      NavEdge(id: 'e16', fromNodeId: 'corridor_north', toNodeId: 'admin_office', weight: 4),
      NavEdge(id: 'e17', fromNodeId: 'corridor_north', toNodeId: 'library', weight: 4),
      
      // Cross connections
      NavEdge(id: 'e18', fromNodeId: 'corridor_4', toNodeId: 'corridor_5', weight: 8),
      NavEdge(id: 'e19', fromNodeId: 'corridor_4', toNodeId: 'corridor_6', weight: 8),
    ];
    
    // Load the sample data
    state.loadFromData(nodes: nodes, edges: edges);
  }
}
