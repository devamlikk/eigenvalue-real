extends Area2D

var speed: float = 400.0
var damage: float = 10.0
var direction: Vector2 = Vector2.ZERO
var max_range: float = 1000.0
var distance_traveled: float = 0.0
var persistent: bool = false
var piercing: bool = false
var hit_enemies: Array = []
var exploding: bool = false
var explosion_radius: float = 0.0
var boomerang: bool = false
var boomerang_returning: bool = false
var boomerang_origin: Vector2 = Vector2.ZERO
var boomerang_range: float = 250.0

func _ready():
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	if boomerang:
		if not boomerang_returning:
			var dist = global_position.distance_to(boomerang_origin)
			if dist >= boomerang_range:
				boomerang_returning = true
				direction = (boomerang_origin - global_position).normalized()
		else:
			direction = (boomerang_origin - global_position).normalized()
			if global_position.distance_to(boomerang_origin) < 10:
				queue_free()
				return
	
	var movement = direction * speed * delta
	global_position += movement
	
	if not boomerang:
		distance_traveled += movement.length()
		if distance_traveled >= max_range:
			queue_free()

func _on_body_entered(body):
	print("Projectile hit: ", body.name)
	if body.is_in_group("enemy"):
		print("Hit enemy, charge before: ", PlayerStats.charge)
		if piercing and body in hit_enemies:
			return
		if exploding:
			_explode()
		body.take_damage(damage * PlayerStats.damage_multiplier)
		hit_enemies.append(body)
		PlayerStats.charge = min(PlayerStats.charge + 1.0, PlayerStats.max_charge)
		PlayerStats.charge_changed.emit(PlayerStats.charge, PlayerStats.max_charge)
		if not persistent and not piercing:
			queue_free()

func _explode():
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = explosion_radius
	query.shape = shape
	query.transform = Transform2D(0, global_position)
	query.collision_mask = 2
	var results = space_state.intersect_shape(query)
	for result in results:
		var body = result["collider"]
		if body.is_in_group("enemy"):
			body.take_damage(50.0 * PlayerStats.damage_multiplier)
	queue_free()

func setup(dir: Vector2, dmg: float):
	direction = dir
	damage = dmg
