extends Node3D

enum State {
	GAME_SETUP,
	GAME_IN_PROGRESS,
	GAME_OVER
}


@onready var own_grid: SeaGrid3D = $OwnGrid
@onready var enemy_grid: SeaGrid3D = $EnemyGrid
@onready var ready_button: Button = $BattleInteraface/Button
@onready var turn_order_label: RichTextLabel = $BattleInteraface/TurnOrderLabel

var selected_ship_size: int = 1
var has_ship_selected: bool = false
var ship_rotation: int = 0
var current_ship: Boat

var ship_positions: Dictionary[Boat.ShipType, Array] = {}


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("test"):
		own_grid.get_grid_state()

func _on_own_grid_ship_placement_updated() -> void:
	ready_button.disabled = own_grid.get_grid_state() == {}


func _on_ready_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if own_grid.get_grid_state() == {}:
			ready_button.disabled = true
			return
		print(own_grid.get_grid_state())
		GameManager.upload_grid_layout.rpc_id(1, own_grid.get_grid_state())
	else:
		GameManager.discard_grid_layout.rpc_id(1)


@rpc("any_peer", "call_local", "reliable")
func start_game() -> void:
	ready_button.visible = false
	enemy_grid.switch_to_battle_mode()

func handle_response(response: GameManager.HitResponse) -> void:
	print(response)


func set_turn_order_label(is_player_turn: bool) -> void:
	turn_order_label.text = "[wave]Your turn![/wave]" if is_player_turn else "[shake]Enemy turn![/shake]"
