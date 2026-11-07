extends Node

var current_player_id: int

var turn_order: Array[int] = []
var turn_order_id: int

var player_armies: Dictionary[int, Dictionary] = {}
var player_attacks: Dictionary[int, Array] = {}
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
		print("%s out of 2 players are ready" % player_armies.size())
		if player_armies.size() == 2:
			start_combat_section()


@rpc("any_peer", "call_local", "reliable")
func discard_grid_layout() -> void:
	if multiplayer.is_server():
		player_armies.erase(multiplayer.get_remote_sender_id())

func start_combat_section() -> void:
	current_player_id = player_armies.keys().pick_random()
	turn_order = player_armies.keys()
	turn_order_id = turn_order.find(current_player_id)

	for user_id in player_armies:
		player_attacks[user_id] = []
		send_turn_info_to_user.rpc_id(user_id, current_player_id == user_id)
	get_tree().root.get_node("BattleScene3d").start_game.rpc()
	

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


func is_ship_sunk(attacker: int, target: int, ship: Boat.ShipType) -> bool:
	# sunk ship just means that all cells of it have been hit 
	return player_armies[target][ship]['cells'].all(func(cell: Vector2i): return cell in player_attacks[attacker])

# Calculate the id of the the player who won or return 0 if none did
func calculate_game_winner() -> int:
	for player in turn_order:
		var other = turn_order[0] if turn_order[1] == player else turn_order[1]
		if player_armies[player].keys().all(func(ship: Boat.ShipType): return is_ship_sunk(other, player, ship)):
			return other
	return 0

func get_hit_response_type(attacker: int, target: int, position: Vector2i) -> HitResponse:
	if attacker not in player_armies or target not in player_armies or position in player_attacks[attacker]:
		return HitResponse.INVALID
	for ship in player_armies[target]:
		if position in player_armies[target][ship]["cells"]:
			return HitResponse.HIT
	# near miss is a shot where ship was near but not on it, excluding diagonals
	var near_pos = [position + Vector2i.UP, position + Vector2i.DOWN, position + Vector2i.LEFT, position + Vector2i.RIGHT]
	for pos in near_pos:
		for ship in player_armies[target]:
			if position in player_armies[target][ship]["cells"]:
				return HitResponse.NEAR_MISS
	return HitResponse.MISS


## Attempt to send turn action 
@rpc("any_peer", "call_local", "reliable")
func do_move(grid_position: Vector2i) -> void: #
	if not multiplayer.is_server() or multiplayer.get_remote_sender_id() != current_player_id:
		return

	var target = turn_order[(turn_order_id + 1) % turn_order.size()]
	print("SERVER: client %s shot at %s" % [current_player_id, grid_position])
	print(player_armies)
	var result = get_hit_response_type(current_player_id, target, grid_position)
	send_respond_to_attacking_enemy.rpc_id(current_player_id, result, grid_position)
	handle_being_attacked.rpc_id(target, result, grid_position)
	if result != HitResponse.INVALID:
		player_attacks[current_player_id].append(grid_position)
		var winner = calculate_game_winner()
		if winner != 0:
			end_game.rpc_id(current_player_id, winner == current_player_id)
			end_game.rpc_id(target, winner == target)
		else:
			advance_turn_order()


@rpc("any_peer", "call_local", "reliable")
func send_turn_info_to_user(is_player_turn: bool) -> void:
	get_tree().root.get_node("BattleScene3d").set_turn_order_label(is_player_turn)

@rpc("any_peer", "call_local", "reliable")
func send_respond_to_attacking_enemy(response: HitResponse, pos: Vector2i) -> void:
	get_tree().root.get_node("BattleScene3d").handle_response_to_own_attack(response, pos)


@rpc("any_peer", "call_local", "reliable")
func handle_being_attacked(response: HitResponse, pos: Vector2i) -> void:
	get_tree().root.get_node("BattleScene3d").handle_hit_on_own_field(response, pos)

@rpc("any_peer", "call_local", "reliable")
func end_game(won_the_game: bool) -> void:
	get_tree().root.get_node("BattleScene3d").end_game(won_the_game)
	# print("i %s" % won_the_game)