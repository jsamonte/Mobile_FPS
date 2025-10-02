extends Node3D
@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/EnterAddress
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar
@onready var current_address = $CanvasLayer/HUD/Address
@onready var port = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/EnterPort
@onready var address = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/EnterAddress
# Called when the node enters the scene tree for the first time

const PORT = 6000
const LOCAL_PORT = 9999
const Player = preload("res://Player.tscn")
const INTERNET_HOST = "35.188.128.109" # External IP from Google Cloud
const LOCAL_HOST = "localhost"
var enet_peer = ENetMultiplayerPeer.new()

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_host_button_pressed():
	main_menu.hide()
	hud.show()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())
	upnp_set_up()



func _on_join_button_pressed():
	main_menu.hide()
	hud.show()
	#enet_peer.create_client(LOCAL_HOST, PORT)
	enet_peer.create_client(INTERNET_HOST, PORT)
	#enet_peer.create_client(LOCAL_HOST, port.text.to_int())
	#enet_peer.create_client(address.text, PORT)
	current_address.text = "Address: "  + address.text
	multiplayer.multiplayer_peer = enet_peer
	
func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	print(player.name)
	add_child(player)
	if player.is_multiplayer_authority():
		player.health_changed.connect(update_health_bar)
		
func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
	
	
func update_health_bar(health_value):
	health_bar.value = health_value
	


func _on_multiplayer_spawner_spawned(player):
	if player.is_multiplayer_authority():
		player.health_changed.connect(update_health_bar)
		
func upnp_set_up():
	var upnp = UPNP.new()
	var discorver_result = upnp.discover()
	assert(discorver_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discorver_result)
		
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP is Invalid Gateway")
		
	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())
	current_address.text = "Address: "  + str(upnp.query_external_address())
