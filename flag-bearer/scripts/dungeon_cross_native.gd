extends Node2D

# Native editable TileMapLayers. Rooms are assembled at startup from tile cells.
# Uses the existing TileSet from scenes/maps.tscn (source IDs 4=floor, 5=high wall, 6=low wall).
const TILESET_SCENE := "res://scenes/maps.tscn"
const FLOOR_SOURCE := 4
const WALL_SOURCE := 5
const FLOOR_TILE := Vector2i(0, 0)
const WALL_TILE := Vector2i(1, 0)
const TILE_SIZE := 16


func _ready() -> void:
    var tile_set_ref: TileSet = load(TILESET_SCENE).instantiate().get_node("TileMap").tile_set
    var floor_layer := TileMapLayer.new()
    floor_layer.name = "Floor"
    floor_layer.tile_set = tile_set_ref
    add_child(floor_layer)
    var wall_layer := TileMapLayer.new()
    wall_layer.name = "Walls"
    wall_layer.tile_set = tile_set_ref
    add_child(wall_layer)
    var props := Node2D.new()
    props.name = "RoomObjects"
    add_child(props)

    # Cross-shaped layout: four rooms connected to the central hub.
    var room1 := Rect2i(-6, 8, 12, 10)  # south room
    var room2 := Rect2i(-6, -18, 12, 10) # north room
    var room3 := Rect2i(-19, -5, 12, 10) # west room
    var room4 := Rect2i(7, -5, 12, 10)   # east room
    var hub := Rect2i(-4, -4, 8, 8)
    var corridors := [Rect2i(-2, 4, 4, 5), Rect2i(-2, -9, 4, 6), Rect2i(-7, -2, 4, 4), Rect2i(4, -2, 4, 4)]
    var regions: Array[Rect2i] = [room1, room2, room3, room4, hub]
    regions.append_array(corridors)

    var floor_cells := {}
    for region in regions:
        for x in range(region.position.x, region.position.x + region.size.x):
            for y in range(region.position.y, region.position.y + region.size.y):
                floor_cells[Vector2i(x, y)] = true
                floor_layer.set_cell(Vector2i(x, y), FLOOR_SOURCE, FLOOR_TILE)

    # Draw walls around the outside edge only; open cells form the doorways/corridors.
    for cell in floor_cells.keys():
        for offset in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
            var neighbor: Vector2i = cell + offset
            if not floor_cells.has(neighbor):
                wall_layer.set_cell(neighbor, WALL_SOURCE, WALL_TILE)

    # Small visual markers for room occupants and the goal flag; replace with scenes later.
    _marker(props, Vector2(-12 * TILE_SIZE, 0), Color(0.55, 0.95, 0.12), "Slime A")
    _marker(props, Vector2(12 * TILE_SIZE, 0), Color(0.55, 0.95, 0.12), "Slime B")
    _marker(props, Vector2(0, -12 * TILE_SIZE), Color(0.55, 0.95, 0.12), "Slime C")
    _marker(props, Vector2(0, 12 * TILE_SIZE), Color(0.55, 0.95, 0.12), "Slime D")
    _flag(props, Vector2(0, 12 * TILE_SIZE + 40))


func _marker(parent: Node2D, pos: Vector2, tint: Color, marker_name: String) -> void:
    var icon := Polygon2D.new()
    icon.name = marker_name
    icon.position = pos
    icon.color = tint
    icon.polygon = PackedVector2Array([Vector2(-5,-5), Vector2(5,-5), Vector2(5,5), Vector2(-5,5)])
    parent.add_child(icon)


func _flag(parent: Node2D, pos: Vector2) -> void:
    var pole := Line2D.new()
    pole.name = "FlagPole"
    pole.position = pos
    pole.points = PackedVector2Array([Vector2(0, 0), Vector2(0, -26)])
    pole.width = 3
    pole.default_color = Color(0.85, 0.78, 0.62)
    parent.add_child(pole)
    var pennant := Polygon2D.new()
    pennant.name = "Flag"
    pennant.position = pos + Vector2(1, -26)
    pennant.color = Color(0.95, 0.28, 0.42)
    pennant.polygon = PackedVector2Array([Vector2(0,0), Vector2(13,4), Vector2(0,9)])
    parent.add_child(pennant)
