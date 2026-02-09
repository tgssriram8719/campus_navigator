# 🏫 Campus Wayfinder - Project Documentation

## 📁 Project Structure

```
campus_wayfinder/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── core/
│   │   ├── models/
│   │   │   ├── models.dart               # Barrel export
│   │   │   ├── nav_node.dart             # Navigation node model
│   │   │   ├── nav_edge.dart             # Edge/connection model
│   │   │   ├── floor_plan.dart           # Floor plan model
│   │   │   └── campus_graph.dart         # Graph data structure
│   │   ├── pathfinding/
│   │   │   └── astar_pathfinder.dart     # A* algorithm implementation
│   │   ├── providers/
│   │   │   └── navigation_providers.dart # Riverpod state management
│   │   └── theme/
│   │       └── app_theme.dart            # App theming & colors
│   └── features/
│       ├── navigation/
│       │   ├── screens/
│       │   │   ├── home_screen.dart      # Main home screen
│       │   │   ├── search_screen.dart    # Room search screen
│       │   │   ├── qr_scanner_screen.dart # QR code scanner
│       │   │   └── navigation_screen.dart # Active navigation view
│       │   └── widgets/
│       │       ├── path_painter.dart     # Path drawing on map
│       │       └── floor_plan_viewer.dart # Interactive map widget
│       └── admin/
│           └── screens/
│               ├── admin_dashboard.dart   # Admin panel home
│               └── node_editor_screen.dart # Add/edit nodes
├── assets/
│   ├── images/
│   ├── floor_plans/                       # Your floor plan images
│   ├── icons/
│   └── fonts/
└── pubspec.yaml                           # Dependencies
```

## 🚀 Getting Started

### Step 1: Create Flutter Project
If you don't have Flutter installed, install it from: https://docs.flutter.dev/get-started/install

```bash
# Navigate to project directory
cd "c:\sri ram\campus_wayfinder"

# Create Flutter project structure
flutter create . --org com.campuswayfinder

# Get dependencies
flutter pub get
```

### Step 2: Set Up Firebase (Optional for v1.0)
For the initial version, data is stored in memory. Later, integrate Firebase:

1. Create a Firebase project at https://console.firebase.google.com
2. Add an Android app with package name: com.campuswayfinder.campus_wayfinder
3. Download google-services.json to android/app/
4. Follow Firestore setup instructions

### Step 3: Create Your Floor Plan

See the detailed guide in `FLOOR_PLAN_GUIDE.md`

### Step 4: Run the App
```bash
flutter run
```

## 📍 How QR Code Positioning Works

1. **Setup Phase (Admin)**:
   - Create nodes for each location with unique QR codes
   - Generate QR codes using the admin panel
   - Print and place QR codes at entrances and key locations

2. **User Flow**:
   - User enters building and scans QR code at entrance
   - App sets their current position to that node
   - User selects destination from search
   - A* algorithm calculates shortest path
   - Path is displayed on 2D map with directions

3. **QR Code Format**:
   - Use format: `CAMPUS_[LOCATION_NAME]`
   - Example: `CAMPUS_MAIN_ENTRANCE`, `CAMPUS_ROOM_101`

## 🔧 Adding Your Campus Data

### Option 1: Using Admin Panel (Recommended)
1. Open the app and tap the admin icon
2. Use "Add New Node" to add locations
3. Use "Edit Map (Visual)" to place nodes by tapping

### Option 2: Edit Source Code
Edit the sample data in `lib/core/providers/navigation_providers.dart`:

```dart
final nodes = [
  NavNode(
    id: 'your_unique_id',
    name: 'Room Name',
    x: 50,  // X position (0-100)
    y: 50,  // Y position (0-100)
    floor: 0,
    type: NodeType.room,
    qrCode: 'CAMPUS_YOUR_ROOM',
    keywords: ['search', 'keywords'],
  ),
];

final edges = [
  NavEdge(
    id: 'edge_1',
    fromNodeId: 'node_1',
    toNodeId: 'node_2',
    weight: 5.0,  // Distance/weight
  ),
];
```

## ✨ Key Features

| Feature | Status | Description |
|---------|--------|-------------|
| 2D Floor Map | ✅ | Interactive floor plan viewer |
| A* Pathfinding | ✅ | Optimal route calculation |
| QR Scanner | ✅ | Detect user position via QR codes |
| Search | ✅ | Find rooms by name/keywords |
| Turn-by-Turn Directions | ✅ | Step-by-step navigation |
| Admin Panel | ✅ | In-app node management |
| Multi-floor Support | ✅ | Navigate between floors |
| Accessibility | ✅ | Wheelchair-friendly routes |

## 🔮 Future Enhancements

1. **Firebase Integration** - Cloud storage for room data
2. **AR Navigation** - ARCore visual guidance
3. **Offline Support** - Download maps for offline use
4. **User Authentication** - Admin login for security
5. **Analytics** - Track popular destinations
6. **Voice Directions** - Audio navigation guidance
7. **WiFi Positioning** - Automatic location detection

## 📞 Support

For questions about this project, refer to:
- Flutter docs: https://docs.flutter.dev
- Firebase docs: https://firebase.google.com/docs
- ARCore docs: https://developers.google.com/ar

---
Generated by Campus Wayfinder Project Generator
