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


var current_state: State = State.GAME_SETUP

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
	current_state = State.GAME_IN_PROGRESS


func set_turn_order_label(is_player_turn: bool) -> void:
	turn_order_label.text = "[wave]Your turn![/wave]" if is_player_turn else "[shake]Enemy turn![/shake]"


func _on_enemy_grid_cell_selected(cell: Vector2i) -> void:
	if current_state != State.GAME_IN_PROGRESS:
		return
	GameManager.do_move.rpc(cell)


# This is called when a user is being attacked 
func handle_hit_on_own_field(hit: GameManager.HitResponse, pos: Vector2i) -> void:
	match hit:
		GameManager.HitResponse.INVALID:
			return # should never be called anyway
		GameManager.HitResponse.MISS:
			own_grid.add_marker(pos, HitMarker.MarkerType.MISS)
		GameManager.HitResponse.NEAR_MISS:
			own_grid.add_marker(pos, HitMarker.MarkerType.NEAR_MISS)
		GameManager.HitResponse.HIT:
			own_grid.add_marker(pos, HitMarker.MarkerType.HIT)
		GameManager.HitResponse.KILL:
			own_grid.add_marker(pos, HitMarker.MarkerType.HIT)

# This is called after user has sent their attack and needs to update the result of it
func handle_response_to_own_attack(hit: GameManager.HitResponse, pos: Vector2i) -> void:
	match hit:
		GameManager.HitResponse.INVALID:
			return # do absolutely nothing and wait for user to hit again
		GameManager.HitResponse.MISS:
			enemy_grid.add_marker(pos, HitMarker.MarkerType.MISS)
		GameManager.HitResponse.NEAR_MISS:
			enemy_grid.add_marker(pos, HitMarker.MarkerType.NEAR_MISS)
		GameManager.HitResponse.HIT:
			enemy_grid.add_marker(pos, HitMarker.MarkerType.HIT)
		GameManager.HitResponse.KILL:
			enemy_grid.add_marker(pos, HitMarker.MarkerType.HIT)
			print("Killed ship!")


func end_game(won: bool) -> void:
	turn_order_label.text = "[rainbow]VICTORY!!![/rainbow]" if won else "[pulse]lost:([/pulse]"
	current_state = State.GAME_OVER
