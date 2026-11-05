extends Node
class_name BattleScene


@onready var own_grid: SeaGrid = $OwnSeaGrid
@onready var turn_order_label: Label = $TurnOrderLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Lobby.player_loaded.rpc_id(1)


@rpc("any_peer", "call_local", "reliable")
func start_game() -> void:
	print("Gaming!")
	GameManager.upload_grid_layout.rpc_id(1, own_grid.get_ship_layout())


func handle_response(response: GameManager.HitResponse) -> void:
	print(response)


func set_turn_order_label(is_player_turn: bool) -> void:
	turn_order_label.text = "Your turn!" if is_player_turn else "Enemy turn!"
