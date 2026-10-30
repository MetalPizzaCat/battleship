extends Node2D
class_name SeaGrid

@export var enemy_grid: bool = false
@export var grid_size: Vector2i = Vector2i(10, 10)
@export var cell_size: Vector2 = Vector2(64, 64)
@export var button_prefab: PackedScene


func _ready() -> void:
	if button_prefab == null:
		printerr("Missing scene for button")
		return
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var btn: Button = button_prefab.instantiate()
			btn.pressed.connect(grid_cell_pressed.bind(Vector2i(x, y)))
			add_child(btn)
			btn.position = Vector2(x * cell_size.x, y * cell_size.x)
			btn.size = cell_size


func get_ship_layout() -> Dictionary[int, Array]:
	return {1: [Vector2i(0, 0), Vector2i(0, 1)]}

func grid_cell_pressed(cell: Vector2i) -> void:
	print("Clicked %s" % cell)
	GameManager.do_move.rpc(cell)
