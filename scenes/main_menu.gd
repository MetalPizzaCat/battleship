extends Control

@export var default_ip: String = "localhost"
@export var default_port: int = 8080

@export_file("*.tscn") var game_scene_path : String

func _on_join_game_button_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(default_ip, default_port)
	multiplayer.multiplayer_peer = peer
	get_window().title = "Client!"

func _on_host_game_button_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(default_port, 1)
	multiplayer.multiplayer_peer = peer
	get_window().title = "Server :3"


func _on_start_game_button_pressed() -> void:
	if multiplayer.is_server():
		print("starting...")
		Lobby.load_game.rpc(game_scene_path)
