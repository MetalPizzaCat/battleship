extends Node3D

enum State {
	GAME_SETUP,
	GAME_IN_PROGRESS,
	GAME_OVER
}


@onready var own_grid: SeaGrid3D = $OwnGrid
@onready var enemy_grid: SeaGrid3D = $EnemyGrid


var selected_ship_size: int = 1
var has_ship_selected: bool = false
var ship_rotation: int = 0
var current_ship: Boat

var ship_positions: Dictionary[Boat.ShipType, Array] = {}


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("test"):
		own_grid.get_grid_state()