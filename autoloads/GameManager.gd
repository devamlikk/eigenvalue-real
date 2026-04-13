extends Node

var wave: int = 0
var score: int = 0
var currency: int = 0
var game_running: bool = false
var xp_orb_scene = preload("res://scenes/items/xporb.tscn")
var selected_weapon: String = "eigenbeam"


signal wave_started(wave_number)
signal wave_ended
signal game_over

func _ready():
	SignalBus.enemy_died.connect(_on_enemy_died)
	game_over.connect(_on_game_over)

func _on_enemy_died(position, xp_value):
	print("Enemy died, spawning orb at: ", position)
	var orb = xp_orb_scene.instantiate()
	orb.global_position = position
	get_tree().current_scene.add_child(orb)
	orb.xp_value = xp_value

func _on_player_hit(damage):
	print("Player took damage: ", damage)

func _on_game_over():
	print("Game Over!")
	PlayerStats.reset()
	get_tree().call_deferred("reload_current_scene")
