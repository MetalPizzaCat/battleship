extends Area3D
class_name Boat

signal selected

enum ShipType {
	CARRIER,
	BATTLESHIP,
	CRUISER,
	SUBMARINE,
	PATROL_BOAT,
	INFLATABLE_BOAT
}

const SHIP_SIZES: Array[int] = [5, 4, 3, 3, 2, 1]

@onready var start_position: Vector3 = position
@export var type: ShipType = ShipType.INFLATABLE_BOAT

var cell_overlaps: Array[CellButton] = []
var boat_overlaps: Array[Boat] = []

func can_be_placed() -> bool:
	return true

func _input_event(_camera: Camera3D, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
		selected.emit()
		print("boat selected")


func reset_to_start_position() -> void:
	position = start_position
	cell_overlaps.clear()
	boat_overlaps.clear()

func rotate90() -> void:
	rotate_y(deg_to_rad(90))


func get_cell_overlaps() -> Array[CellButton]:
	return cell_overlaps

func is_overlapping_other_boats() -> bool:
	return not boat_overlaps.is_empty()

func _on_area_exited(area: Area3D) -> void:
	if area is CellButton and area in cell_overlaps:
		cell_overlaps.erase(area)
	if area is Boat and area in boat_overlaps:
		boat_overlaps.erase(area)

func _on_area_entered(area: Area3D) -> void:
	if area is Boat:
		boat_overlaps.append(area)
	elif area is CellButton:
		cell_overlaps.append(area)
