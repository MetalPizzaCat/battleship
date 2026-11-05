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

@onready var start_position: Vector3 = position
@export var type : ShipType = ShipType.INFLATABLE_BOAT

func can_be_placed() -> bool:
	return true

func _input_event(_camera: Camera3D, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
		selected.emit()
		print("boat selected")

func reset_to_start_position() -> void:
	position = start_position

func rotate90() -> void:
	rotate_y(deg_to_rad(90))