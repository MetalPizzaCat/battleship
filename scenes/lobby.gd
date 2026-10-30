extends Node


signal player_connected(peer_id)
var players: Array[int] = []
var players_loaded: int = 0


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)

@rpc("any_peer", "call_local", "reliable")
func player_loaded() -> void:
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			get_tree().root.get_node("BattleScene").start_game.rpc()


# this function should be called by the server when both users have joined and are ready
@rpc("call_local", "reliable")
func load_game(game_scene_path : String):
	get_tree().change_scene_to_file(game_scene_path)
	
func _on_player_connected(id):
	_register_player.rpc_id(id)

@rpc("any_peer", "reliable")
func _register_player():
	var new_player_id = multiplayer.get_remote_sender_id()
	players.append(new_player_id)
	player_connected.emit(new_player_id)
	print("User connected and was given id %s"%new_player_id)


func get_player_list() -> Dictionary:
	return {}