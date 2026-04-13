extends CharacterBody2D

var knockback: Vector2 = Vector2.ZERO
var shoot_cooldown: float = 0.0
var projectile_scene = preload("res://scenes/weapons/projectile.tscn")
var curl_orbs: Array = []
var curl_orb_count: int = 3
var curl_radius: float = 60.0
var curl_speed: float = 2.0
var curl_angle: float = 0.0
var curl_radius_min: float = 60.0
var curl_radius_max: float = 160.0
var curl_expanded: bool = false
var dash_speed: float = 1000.0
var dash_duration: float = 0.2
var dash_timer: float = 0.0
var dash_cooldown: float = 3.0
var dash_cooldown_timer: float = 0.0
var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.ZERO
var dash_damage: float = 35.0
var invincible: bool = false
var curl_ability_active: bool = false
var current_weapon: String = "vector"

func _ready():
	current_weapon = GameManager.selected_weapon
	print("Player ready, weapon: ", current_weapon)
	PlayerStats.hp_changed.emit(PlayerStats.current_hp, PlayerStats.max_hp)
	add_to_group("player")
	$PickupRange.area_entered.connect(_on_pickup_range_area_entered)
	if current_weapon == "curl":
		await get_tree().process_frame
		_setup_curl()

func _on_pickup_range_area_entered(area):
	if area.has_method("attract"):
		area.attract()

func _handle_movement():
	if is_dashing:
		velocity = dash_direction * dash_speed
		move_and_slide()
		_check_dash_damage()
		return
		
	var direction = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()
	velocity = direction * PlayerStats.speed + knockback
	knockback = knockback.lerp(Vector2.ZERO, 0.3)
	move_and_slide()

func _check_dash_damage():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body.is_in_group("enemy"):
			body.take_damage(dash_damage)

func _start_dash():
	if dash_cooldown_timer > 0 or is_dashing:
		return
	var direction = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()
	if direction == Vector2.ZERO:
		direction = transform.x
	dash_direction = direction
	is_dashing = true
	invincible = true
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown

func _update_dash(delta):
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			invincible = false
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

func _physics_process(delta):
	_update_dash(delta)
	_handle_movement()
	if not is_dashing:
		look_at(get_global_mouse_position())

func take_damage(amount: float):
	if invincible:
		return
	var actual_damage = max(0, amount - PlayerStats.armor)
	PlayerStats.current_hp -= actual_damage
	print("HP: ", PlayerStats.current_hp)
	PlayerStats.hp_changed.emit(PlayerStats.current_hp, PlayerStats.max_hp)
	SignalBus.player_hit.emit(actual_damage)
	if PlayerStats.current_hp <= 0:
		GameManager.game_over.emit()

func apply_knockback(source_position: Vector2, force: float = 300.0):
	knockback = (global_position - source_position).normalized() * force

func _process(delta):
	shoot_cooldown -= delta
	if GameManager.selected_weapon == "curl":
		_update_curl(delta)
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_shoot()
	if Input.is_action_just_pressed("ui_accept"):
		_start_dash()
	if Input.is_action_just_pressed("ability"):
		_use_ability()

func _shoot():
	if shoot_cooldown > 0:
		return
	print("Shooting weapon: ", GameManager.selected_weapon)
	match GameManager.selected_weapon:
		"vector":
			shoot_cooldown = 0.25 / PlayerStats.attack_speed_multiplier
			_shoot_vector()
		"divergence":
			shoot_cooldown = 0.8 / PlayerStats.attack_speed_multiplier
			_shoot_divergence()
		"gradient":
			shoot_cooldown = 1.2 / PlayerStats.attack_speed_multiplier
			_shoot_gradient()
		"eigenbeam":
			shoot_cooldown = 0.1 / PlayerStats.attack_speed_multiplier
			_shoot_eigenbeam()
		"nullspace":
			shoot_cooldown = 3.0 / PlayerStats.attack_speed_multiplier
			_shoot_nullspace()

func _use_ability():
	if PlayerStats.charge < 100.0:
		print("Not enough charge!")
		return
	PlayerStats.charge = 0.0
	PlayerStats.charge_changed.emit(PlayerStats.charge, PlayerStats.max_charge)
	
	match GameManager.selected_weapon:
		"vector":
			_ability_vector()
		"divergence":
			_ability_divergence()
		"curl":
			_ability_curl()
		"gradient":
			_ability_gradient()
		"eigenbeam":
			_ability_eigenbeam()
		"nullspace":
			_ability_nullspace()

func _shoot_vector():
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	var dir = (get_global_mouse_position() - global_position).normalized()
	projectile.setup(dir, 12.0)
	projectile.max_range = 500.0
	get_tree().current_scene.add_child(projectile)

func _shoot_divergence():
	var spread_angles = [-20, -10, 0, 10, 20]
	var base_dir = (get_global_mouse_position() - global_position).normalized()
	for angle in spread_angles:
		var projectile = projectile_scene.instantiate()
		projectile.global_position = global_position
		var dir = base_dir.rotated(deg_to_rad(angle))
		projectile.setup(dir, 15.0)
		projectile.max_range = 250.0
		get_tree().current_scene.add_child(projectile)

func _shoot_gradient():
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	var dir = (get_global_mouse_position() - global_position).normalized()
	projectile.setup(dir, 50.0)
	projectile.max_range = 800.0
	projectile.speed = 700.0
	projectile.piercing = true
	get_tree().current_scene.add_child(projectile)

func _shoot_eigenbeam():
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	var dir = (get_global_mouse_position() - global_position).normalized()
	projectile.setup(dir, 8.0)
	projectile.max_range = 200.0
	projectile.speed = 600.0
	get_tree().current_scene.add_child(projectile)

func _shoot_nullspace():
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	var dir = (get_global_mouse_position() - global_position).normalized()
	projectile.setup(dir, 0.0)
	projectile.speed = 150.0
	projectile.max_range = 600.0
	projectile.exploding = true
	projectile.explosion_radius = 150.0
	get_tree().current_scene.add_child(projectile)

func _setup_curl(count: int = 3, dmg: float = 45.0):
	for orb in curl_orbs:
		if is_instance_valid(orb):
			orb.queue_free()
	curl_orbs.clear()
	for i in count:
		var orb = projectile_scene.instantiate()
		get_tree().current_scene.add_child(orb)
		orb.setup(Vector2.ZERO, dmg)
		orb.speed = 0.0
		orb.max_range = 99999.0
		orb.persistent = true
		curl_orbs.append(orb)

func _update_curl(delta):
	if not curl_ability_active:
		curl_expanded = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		var target_count = 6 if curl_expanded else 3
		if curl_orbs.size() != target_count:
			_setup_curl(target_count)
	
	var target_radius = curl_radius_max if curl_expanded else curl_radius_min
	curl_radius = lerp(curl_radius, target_radius, 0.1)
	curl_speed = 1.2 if curl_expanded else 2.5
	
	curl_angle += curl_speed * delta
	for i in range(curl_orbs.size()):
		if not is_instance_valid(curl_orbs[i]):
			continue
		var angle = curl_angle + (TAU / curl_orbs.size()) * i
		var offset = Vector2(cos(angle), sin(angle)) * curl_radius
		curl_orbs[i].global_position = global_position + offset

func _ability_vector():
	# Fires 8 projectiles in all directions (3 bursts of 3)
	for burst in 3:
		for shot in 3:
			await get_tree().create_timer(0.08).timeout
			for i in 8:
				var projectile = projectile_scene.instantiate()
				projectile.global_position = global_position
				var dir = Vector2.RIGHT.rotated(TAU / 8 * i)
				projectile.setup(dir, 25.0)
				projectile.max_range = 500.0
				get_tree().current_scene.add_child(projectile)
		await get_tree().create_timer(0.4).timeout

func _ability_divergence():
	# Massive spread of 12 pellets
	var base_dir = (get_global_mouse_position() - global_position).normalized()
	for i in 15:
		var projectile = projectile_scene.instantiate()
		projectile.global_position = global_position
		var angle = deg_to_rad(-45 + (90.0 / 14) * i)
		var dir = base_dir.rotated(angle)
		projectile.setup(dir, 30.0)
		projectile.speed = 350.0
		projectile.boomerang = true
		projectile.boomerang_origin = global_position
		projectile.boomerang_range = 250.0
		get_tree().current_scene.add_child(projectile)

func _ability_curl():
	# Temporarily doubles orb count and more damage
	curl_ability_active = true
	curl_orb_count = 8
	_setup_curl(8, 55.0)
	await get_tree().create_timer(15.0).timeout
	curl_ability_active = false
	curl_orb_count = 3
	_setup_curl(3, 45.0)

func _ability_gradient():
	# Fires 3 piercing shots in quick succession
	for i in 3:
		await get_tree().create_timer(0.1).timeout
		var projectile = projectile_scene.instantiate()
		projectile.global_position = global_position
		var dir = (get_global_mouse_position() - global_position).normalized()
		projectile.setup(dir, 150.0)
		projectile.max_range = 900.0
		projectile.piercing = true
		get_tree().current_scene.add_child(projectile)

func _ability_eigenbeam():
	# Short invincibility + damage boost for 3 seconds
	invincible = true
	PlayerStats.damage_multiplier *= 1.5
	await get_tree().create_timer(5.0).timeout
	invincible = false
	PlayerStats.damage_multiplier /= 3

func _ability_nullspace():
	# Massive AOE, tripe radius
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 450.0
	query.shape = shape
	query.transform = Transform2D(0, global_position)
	query.collision_mask = 2
	var results = space_state.intersect_shape(query)
	for result in results:
		var body = result["collider"]
		if body.is_in_group("enemy"):
			body.take_damage(100.0 * PlayerStats.damage_multiplier)
