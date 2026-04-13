extends Node

var enemy_scene = preload("res://scenes/enemies/Enemy.tscn")

var wave: int = 0
var enemies_per_wave: int = 3
var enemies_remaining: int = 0
var spawn_interval: float = 1.5
var spawn_timer: float = 0.0
var wave_in_progress: bool = false
var spawn_radius_min: float = 300.0
var spawn_radius_max: float = 600.0

var player: Node = null

func _ready():
	SignalBus.enemy_died.connect(func(pos, xp): _on_enemy_died(pos, xp))
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	start_wave()

func _process(delta):
	if wave_in_progress and enemies_remaining > 0:
		spawn_timer -= delta
		if spawn_timer <= 0:
			spawn_with_warning()
			spawn_timer = spawn_interval

func start_wave():
	wave += 1
	GameManager.wave = wave
	enemies_remaining = enemies_per_wave + (wave * 2)
	wave_in_progress = true
	print("Wave ", wave, " started — enemies: ", enemies_remaining)

func spawn_with_warning():
	if not player:
		return
	var pos = _get_spawn_position()
	enemies_remaining -= 1
	
	# Draw X Warning
	var warning = Label.new()
	warning.text = "X"
	warning.add_theme_font_size_override("font_size", 32)
	warning.add_theme_color_override("font_color", Color("#FF4444"))
	warning.global_position = pos
	get_tree().current_scene.add_child(warning)
	
	# Wait then spawn enemy
	await get_tree().create_timer(0.8).timeout
	warning.queue_free()
	
	var enemy = enemy_scene.instantiate()
	enemy.global_position = pos
	get_tree().current_scene.add_child(enemy)

func _get_spawn_position() -> Vector2:
	var angle = randf() * TAU
	var distance = randf_range(spawn_radius_min, spawn_radius_max)
	var offset = Vector2(cos(angle), sin(angle)) * distance
	return player.global_position + offset

func _on_enemy_died(_position, xp_value):
	if enemies_remaining <= 0 and wave_in_progress:
		wave_in_progress = false
		print("Wave ", wave, " complete!")
		await get_tree().create_timer(3.0).timeout
		start_wave()
