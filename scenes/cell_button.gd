extends Area3D
class_name CellButton

signal pressed
signal mouse_in

@onready var highlight_mesh: MeshInstance3D = $CursorHighlightMesh
@onready var preview_mesh: MeshInstance3D = $PreviewCellMesh

var grid_position : Vector2i

func _on_mouse_exited() -> void:
	highlight_mesh.visible = false
	

func _on_mouse_entered() -> void:
		highlight_mesh.visible = true
		mouse_in.emit()


func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
		pressed.emit()


func _on_area_exited(area: Area3D) -> void:
	print("%s left" % area)
	if get_overlapping_areas().size() == 0:
		preview_mesh.visible = false

func _on_area_entered(area: Area3D) -> void:
	if area is Boat:
		preview_mesh.visible = true
