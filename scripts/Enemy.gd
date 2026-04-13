extends CharacterBody2D

var hp: float = 50.0
var speed: float = 80.0
var damage: float = 10.0
var xp_value: int = 5

var player: Node = null

func _ready():
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	print("Player found: ", player)
	add_to_group("enemy")

var damage_cooldown: float = 0.0

func _physics_process(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
	
	if damage_cooldown > 0:
		damage_cooldown -= delta

func take_damage(amount: float):
	hp -= amount
	if hp <= 0:
		die()

func die():
	SignalBus.enemy_died.emit(global_position, xp_value)
	queue_free()

func _on_damage_area_body_entered(body):
	if body.is_in_group("player") and damage_cooldown <= 0:
		body.take_damage(damage)
		body.apply_knockback(global_position, 200.0)
		damage_cooldown = 0.3
