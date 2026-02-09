# 🗺️ Creating Digital Floor Plans for Campus Wayfinder

This guide explains how to create accurate digital floor plans for your campus navigation app.

## 📋 What You Need

1. **Measuring tape** or laser distance meter
2. **Graph paper** or digital drawing tool
3. **Camera/phone** for reference photos
4. **Spreadsheet** for recording measurements

## 🎯 Step-by-Step Process

### Step 1: Survey the Building

1. **Walk the entire floor** and note:
   - All rooms and their numbers
   - Corridors and intersections
   - Entrances and exits
   - Staircases and elevators
   - Restrooms and facilities

2. **Measure key distances**:
   - Building length and width
   - Corridor lengths
   - Room dimensions (approximate)

3. **Take photos** of:
   - Room number signs
   - Corridor intersections
   - Key landmarks

### Step 2: Create Floor Plan Image

#### Option A: Use Online Tools (Recommended)
- **Floorplanner.com** - Free web-based tool
- **RoomSketcher** - Easy drag-and-drop
- **SmartDraw** - Professional floor plans
- **Lucidchart** - Simple diagrams

#### Option B: Use Desktop Software
- **AutoCAD** (Professional)
- **SketchUp** (Free version available)
- **LibreCAD** (Free, open-source)
- **Microsoft Visio**

#### Option C: Hand Draw + Scan
1. Draw on graph paper (scale: 1 square = 1 meter)
2. Scan at high resolution (300 DPI+)
3. Clean up in image editor

### Step 3: Export Floor Plan

1. **Export as PNG** (recommended) or JPEG
2. **Size**: 1000-2000 pixels wide is ideal
3. **Aspect ratio**: Keep proportional to actual building
4. **Background**: White or light gray

### Step 4: Set Up Coordinate System

The app uses a **percentage-based coordinate system** (0-100):
- (0, 0) = Top-left corner
- (100, 100) = Bottom-right corner
- (50, 50) = Center of floor plan

**Example coordinate mapping:**
```
Building is 100m x 50m

Actual Position → App Coordinates
(0m, 0m)        → (0, 0)
(50m, 25m)      → (50, 50)
(100m, 50m)     → (100, 100)
(25m, 40m)      → (25, 80)  [40/50 * 100 = 80]
```

### Step 5: Map Your Nodes

Create a spreadsheet with:

| Node ID | Name | X | Y | Floor | Type | QR Code |
|---------|------|---|---|-------|------|---------|
| entrance_main | Main Entrance | 50 | 95 | 0 | entrance | CAMPUS_MAIN_ENTRANCE |
| room_101 | Room 101 - Physics Lab | 10 | 70 | 0 | room | CAMPUS_ROOM_101 |
| corridor_1 | Main Corridor | 50 | 80 | 0 | corridor | - |

### Step 6: Define Connections (Edges)

List all walkable paths between nodes:

| From Node | To Node | Distance (approx) |
|-----------|---------|-------------------|
| entrance_main | corridor_1 | 5m |
| corridor_1 | room_101 | 8m |
| corridor_1 | corridor_2 | 10m |

## 📐 Tips for Accurate Floor Plans

### DO ✅
- Measure actual distances when possible
- Include ALL corridor intersections as nodes
- Place nodes at room entrances (not centers)
- Add waypoints at every turn in corridors
- Test paths by walking the actual route

### DON'T ❌
- Skip corridor nodes (paths will cut through walls)
- Place nodes inside rooms (only at entrances)
- Forget to connect nodes with edges
- Use unclear or inconsistent naming

## 🖼️ Adding Floor Plan to App

1. **Save your floor plan image** to:
   ```
   campus_wayfinder/assets/floor_plans/ground_floor.png
   ```

2. **Update pubspec.yaml** to include asset folder (already done)

3. **Load in FloorPlanViewer** widget:
   ```dart
   FloorPlanViewer(
     floorPlanImagePath: 'assets/floor_plans/ground_floor.png',
   )
   ```

## 📊 Sample Building Layout

Here's a visual example of how to structure nodes:

```
     ┌─────────────────────────────────────────┐
     │  [Admin Office]    [Principal]  [Library]│ ← y=25
     │       x=35           x=50         x=65   │
     │                                          │
     │            [Corridor North]              │ ← y=35
     │                 x=50                     │
     │                   │                      │
     │            [Staircase]                   │ ← y=45
     │                 x=50                     │
     │                   │                      │
     │  [Room 102]       │           [Room 104] │ ← y=55
     │    x=10           │              x=90    │
     │        ─────[Corridor 4-5-6]─────        │ ← y=50
     │                   │                      │
     │  [Room 101]       │           [Room 103] │ ← y=70
     │    x=10           │              x=90    │
     │        ─────[Corridor 2-1-3]─────        │ ← y=80
     │                   │                      │
     │            [Main Entrance]               │ ← y=95
     │                 x=50                     │
     └─────────────────────────────────────────┘
```

## 🔄 Iterative Improvement

1. **Start simple**: Add main corridors and rooms first
2. **Test navigation**: Walk routes to verify paths work
3. **Add details**: Restrooms, utilities, additional waypoints
4. **Refine positions**: Adjust coordinates for accuracy

## 📱 Testing Checklist

Before deploying, verify:
- [ ] All rooms appear in search
- [ ] Navigation works from entrance to all rooms
- [ ] Floor changes work correctly
- [ ] QR codes scan correctly
- [ ] Paths don't cut through walls
- [ ] Turn directions make sense

---

## Quick Reference: Node Types

| Type | Use For | Searchable |
|------|---------|------------|
| `entrance` | Building entrances | ✅ |
| `room` | Classrooms, labs, offices | ✅ |
| `corridor` | Hallway intersections | ❌ |
| `staircase` | Stairs between floors | ❌ |
| `elevator` | Elevator access points | ❌ |
| `restroom` | Restrooms/Washrooms | ✅ |
| `utility` | Service areas | ❌ |

---
Created for Campus Wayfinder Project
