extends Area2D

var xp_value: int = 5
var move_speed: float = 0.0
var player: Node = null

func _ready():
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance < 80:
			var direction = (player.global_position - global_position).normalized()
			global_position += direction * 150 * delta
			if distance < 10:
				GameManager.score += xp_value
				print("XP collected, total: ", GameManager.score)
				queue_free()
