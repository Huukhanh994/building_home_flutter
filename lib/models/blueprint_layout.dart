import 'package:flutter/foundation.dart';

enum FurnitureType {
  bedDouble,
  bedSingle,
  sofa,
  coffeeTable,
  diningTable,
  toilet,
  bathtub,
  sink,
  stove,
  wardrobe,
  tvUnit,
  altarTable,
}

@immutable
class BlueprintFurniture {
  const BlueprintFurniture({required this.type, required this.normRect});

  /// Furniture type for rendering.
  final FurnitureType type;

  /// Position/size in 0–1 space relative to the containing room rect.
  final NormalizedRect normRect;
}

/// A room defined in normalized coordinates (0.0–1.0) relative to the house
/// footprint. [rect] maps directly onto the canvas rectangle.
@immutable
class BlueprintRoom {
  const BlueprintRoom({
    required this.label,
    required this.rect,
    this.furniture = const [],
  });

  /// Label shown inside the room on the floor plan.
  final String label;

  /// Normalized rect: all values in 0.0–1.0 relative to house width/length.
  final NormalizedRect rect;

  /// Optional furniture items positioned relative to this room.
  final List<BlueprintFurniture> furniture;
}

/// A door opening on one of the four walls.
@immutable
class BlueprintDoor {
  const BlueprintDoor({required this.wall, required this.position});

  /// Which wall the door is on.
  final Wall wall;

  /// Position along that wall (0.0 = left/top, 1.0 = right/bottom).
  final double position;
}

/// A window opening on one of the four walls.
@immutable
class BlueprintWindow {
  const BlueprintWindow({required this.wall, required this.position});

  final Wall wall;
  final double position;
}

enum Wall { top, bottom, left, right }

/// A rectangle in normalized 0–1 space.
@immutable
class NormalizedRect {
  const NormalizedRect(this.left, this.top, this.width, this.height);

  final double left;
  final double top;
  final double width;
  final double height;
}

/// The complete layout definition for one floor of a house.
@immutable
class BlueprintLayout {
  const BlueprintLayout({
    required this.rooms,
    this.doors = const [],
    this.windows = const [],
    this.floorLabel = 'Tầng trệt',
  });

  final List<BlueprintRoom> rooms;
  final List<BlueprintDoor> doors;
  final List<BlueprintWindow> windows;
  final String floorLabel;
}
