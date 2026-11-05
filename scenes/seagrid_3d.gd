extends Node3D
class_name SeaGrid3D

signal ship_placement_updated

@export var grid_line_model: PackedScene
@export var grid_cell_button: PackedScene
@export var width: int = 10
@export var height: int = 10
@export var cell_size: int = 2

@export var ships: Array[Boat] = []
var buttons: Array[CellButton] = []
var current_ship: Boat
@export var allow_manual_ship_placement: bool = true

var allow_ship_placement: bool = true

func is_in_battle_mode() -> bool:
	return not allow_manual_ship_placement and not allow_ship_placement

func _ready() -> void:
	for ship in ships:
		ship.selected.connect(on_ship_selected.bind(ship))
		ship.visible = allow_manual_ship_placement

	if grid_line_model == null or grid_cell_button == null:
		return
	for x in range(width):
		for y in range(height):
			var button: CellButton = grid_cell_button.instantiate()
			button.position = cell_to_world_coordinates(Vector2i(x, y))
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


	change_interaction_state(false)



func cell_to_world_coordinates(pos: Vector2i) -> Vector3:
	return Vector3(pos.x * cell_size + cell_size / 2.0, 0, pos.y * cell_size + cell_size / 2.0)

func switch_to_battle_mode() -> void:
	allow_ship_placement = false
	change_interaction_state(true)

func _input(_event: InputEvent) -> void:
	if current_ship == null:
		return
	if Input.is_action_just_pressed("drop_boat"):
		current_ship.reset_to_start_position.call_deferred()
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
	ship_placement_updated.emit.call_deferred()

func on_ship_selected(ship: Boat) -> void:
	if is_in_battle_mode():
		return
	print("set ship to %s" % ship)
	current_ship = ship
	change_interaction_state(true)

func is_valid_ship_placement(ship: Boat) -> bool:
	return not ship.is_overlapping_other_boats() \
		and ship.get_cell_overlaps().size() == Boat.SHIP_SIZES[ship.type] \
		and ship.get_cell_overlaps().all(func(x: CellButton): return x in buttons)


func on_cell_pressed(cell: Vector2i) -> void:
	print("clicked %s " % cell)
	if current_ship != null and not is_in_battle_mode() and is_valid_ship_placement(current_ship):
		current_ship.position = cell_to_world_coordinates(cell)
		drop_ship()
	elif is_in_battle_mode():
		print("shooting at")
		

func on_cell_hovered_over(cell: Vector2i) -> void:
	if current_ship == null or is_in_battle_mode():
		return
	current_ship.position = cell_to_world_coordinates(cell)


func get_grid_state() -> Dictionary[Boat.ShipType, Dictionary]:
	var res: Dictionary[Boat.ShipType, Dictionary] = {}
	for ship in ships:
		if not is_valid_ship_placement(ship):
			# gdscript doesn't have Option<> so we will just return empty dict
			return {}
		# rotation will be used to display the blown up ship. 
		# In reality it could have been done by just checking if cells are more vertical than  horizontal
		res[ship.type] = {"rotation": ship.rotation_degrees.y, "cells": ship.get_cell_overlaps().map(func(x: CellButton): return x.grid_position)}
	print("current sea grid layout: %s" % res)
	return res
