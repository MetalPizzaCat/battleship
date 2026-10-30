extends Node

var current_player_id: int

var turn_order: Array[int] = []
var turn_order_id: int

var player_armies: Dictionary[int, Dictionary] = {}
enum HitResponse {
	INVALID,
	MISS,
	NEAR_MISS,
	HIT,
	KILL
}


var battle_scene: BattleScene

@rpc("any_peer", "call_local", "reliable")
func upload_grid_layout(grid: Dictionary) -> void:
	if multiplayer.is_server():
		player_armies[multiplayer.get_remote_sender_id()] = grid
		if player_armies.size() == 2:
			start_combat_section()


func start_combat_section() -> void:
	current_player_id = player_armies.keys().pick_random()
	turn_order = player_armies.keys()
	turn_order_id = turn_order.find(current_player_id)

	for user_id in player_armies:
		send_turn_info_to_user.rpc_id(user_id, current_player_id == user_id)

func advance_turn_order() -> void:
	turn_order_id = (turn_order_id + 1) % turn_order.size()
	current_player_id = turn_order[turn_order_id]
	for user_id in player_armies:
		send_turn_info_to_user.rpc_id(user_id, current_player_id == user_id)

func is_hit(id: int, position: Vector2i) -> bool:
	if id not in player_armies:
		return false
		
	for ship in player_armies[id]:
		if position in player_armies[id][ship]:
			return true
	return false

## Attempt to send turn action 
@rpc("any_peer", "call_local", "reliable")
func do_move(grid_position: Vector2i) -> void: #
	if multiplayer.is_server() and multiplayer.get_remote_sender_id() == current_player_id:
		print("SERVER: client %s shot at %s" % [multiplayer.get_remote_sender_id(), grid_position])
		print(player_armies)
		send_turn_response_to_client.rpc_id(multiplayer.get_remote_sender_id(), HitResponse.HIT if is_hit(multiplayer.get_remote_sender_id(), grid_position) else HitResponse.MISS)
		advance_turn_order()


@rpc("any_peer", "call_local", "reliable")
func send_turn_info_to_user(is_player_turn: bool) -> void:
	get_tree().root.get_node("BattleScene").set_turn_order_label(is_player_turn)

@rpc("any_peer", "call_local", "reliable")
func send_turn_response_to_client(response: HitResponse) -> void:
	get_tree().root.get_node("BattleScene").handle_response(response)
