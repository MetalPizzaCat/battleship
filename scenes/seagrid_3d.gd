extends Node3D
class_name SeaGrid3D

@export var grid_line_model: PackedScene
@export var grid_cell_button: PackedScene
@export var width: int = 10
@export var height: int = 10
@export var cell_size: int = 2

@export var ships: Array[Boat] = []
var buttons: Array[CellButton] = []
var current_ship: Boat

var is_in_battle_mode: bool = false

func _ready() -> void:
	for ship in ships:
		ship.selected.connect(on_ship_selected.bind(ship))

	if grid_line_model == null or grid_cell_button == null:
		return
	for x in range(width):
		for y in range(height):
			var button: CellButton = grid_cell_button.instantiate()
			button.position = Vector3(x * cell_size + cell_size / 2.0, 0, y * cell_size + cell_size / 2.0)
			button.pressed.connect(on_cell_pressed.bind(Vector2i(x, y)))
			button.mouse_in.connect(on_cell_hovered_over.bind(Vector2i(x, y)))
			buttons.append(button)
			button.grid_position = Vector2i(x, y)
			add_child(button)

	for x in range(width + 1):
		var line: Node3D = grid_line_model.instantiate()
		line.position = Vector3(x * cell_size, 0, 0)
		line.rotation_degrees = Vector3(0, 0, 0)
		add_child(line)
	for y in range(height + 1):
		var line: Node3D = grid_line_model.instantiate()
		line.position = Vector3(0, 0, y * cell_size)
		line.rotation_degrees = Vector3(0, 90, 0)
		add_child(line)

func switch_to_battle_mode() -> void:
	is_in_battle_mode = true
	change_interaction_state(true)

func _input(_event: InputEvent) -> void:
	if current_ship == null:
		return
	if Input.is_action_just_pressed("drop_boat"):
		current_ship.reset_to_start_position()
		drop_ship()
	elif Input.is_action_just_pressed("rotate"):
		current_ship.rotate90()

func change_interaction_state(grid_state: bool) -> void:
	for ship in ships:
		ship.input_ray_pickable = not grid_state
	for button in buttons:
		button.input_ray_pickable = grid_state

func drop_ship() -> void:
	current_ship = null
	change_interaction_state(false)

func on_ship_selected(ship: Boat) -> void:
	if is_in_battle_mode:
		return
	print("set ship to %s" % ship)
	current_ship = ship
	change_interaction_state(true)

func on_cell_pressed(cell: Vector2i) -> void:
	print("clicked %s " % cell)
	if current_ship != null:
		current_ship.position = Vector3(cell.x * cell_size + cell_size / 2.0, 0, cell.y * cell_size + cell_size / 2.0)
		drop_ship()

func on_cell_hovered_over(cell: Vector2i) -> void:
	if current_ship == null:
		return
	current_ship.position = Vector3(cell.x * cell_size + cell_size / 2.0, 0, cell.y * cell_size + cell_size / 2.0)


func get_grid_state() -> Dictionary[Boat.ShipType, Array]:
	var res: Dictionary[Boat.ShipType, Array] = {}
	for ship in ships:
		res[ship.type] = ship.get_overlapping_areas().map(func(x: CellButton): return x.grid_position)
	print(res)
	return res
