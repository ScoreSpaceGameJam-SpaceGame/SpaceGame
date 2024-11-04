class_name Player
extends CharacterBody2D

const SPEED : float = 200.0
const FIRE_POWER_MULTIPLYER : float = 1.25
const MAX_GUN_ENERGY = 100

var player_state : Enums.player_actions = Enums.player_actions.AIMING
var firing_vector : Vector2
var original_mouse_position_when_firing : Vector2
var firing_power : float
var is_shooting: bool = false
var gun_model_x_offset : float = 22
var walk_direction : Enums.directions = Enums.directions.LEFT
var aim_direction : Enums.directions = Enums.directions.LEFT
var gun_energy: float = 100

var failed_teleport_sfx = preload("res://characters/player/failed_teleport.wav")

signal remaining_gun_energy

@onready var aim_indicator_mount_point: Node2D = $AimIndicatorMountPoint

func _physics_process(delta: float) -> void:
	# Tracking the directions for our animation tree
	if velocity.x > 0:
		walk_direction = Enums.directions.RIGHT
	else:
		walk_direction = Enums.directions.LEFT
	
	if -PI/2 <= firing_vector.angle() and firing_vector.angle() <= PI/2:
		aim_direction = Enums.directions.RIGHT
	else:
		aim_direction = Enums.directions.LEFT
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	match player_state:
		Enums.player_actions.AIMING:
			handle_aiming_state()
		Enums.player_actions.POWERING:
			handle_powering_state()
		Enums.player_actions.FIRING:
			if Input.is_action_pressed("Teleport"):
				# Teleport player to the grenade
				player_state = Enums.player_actions.AIMING
				aim_indicator_mount_point.visible = true
			handle_firing_state()
		_:
			push_error("Player has entered into a state that is not allowed");
	
	move_and_slide()

func handle_aiming_state():
	# Get the movement direction and aiming direction
	var direction := Input.get_axis("MoveLeft", "MoveRight")
	firing_vector = global_position.direction_to(get_global_mouse_position())
	
	# Assign velocity to the player
	# IMPORTANT move and slide must be called in the physics process method
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	
	# Rotate the aim indicator to match the firing angle
	aim_indicator_mount_point.global_rotation = firing_vector.angle() + .5 * PI
	if velocity.is_zero_approx():
		$GunMountPoint.global_rotation = 0
	else:
		if aim_direction == Enums.directions.LEFT:
			$GunMountPoint.global_rotation = firing_vector.angle() + PI
		else:
			$GunMountPoint.global_rotation = firing_vector.angle()
	$Telenade.translate(global_position - $Telenade.global_position)
	if Input.is_action_just_pressed("FiringAction"):
		player_state = Enums.player_actions.POWERING
		original_mouse_position_when_firing = get_global_mouse_position()

func handle_powering_state():
	velocity = Vector2.ZERO
	var x_power : float = get_global_mouse_position().distance_to(original_mouse_position_when_firing)
	$Telenade.translate(global_position - $Telenade.global_position)
	firing_power = clamp(log(x_power) * x_power / 2, 0, 500) # TODO use this
	
	if Input.is_action_just_released("FiringAction"):
		if aim_direction == Enums.directions.LEFT:
			$GunMountPoint.global_rotation = firing_vector.angle() + PI
		else:
			$GunMountPoint.global_rotation = firing_vector.angle()
		
		# Handle the gun not having enough energy by returning telenade and playing sfx
		if gun_energy - global_position.distance_to($Telenade.global_position) / 50 < 0:
			player_state = Enums.player_actions.AIMING
			$SFXPlayer.stream = failed_teleport_sfx
			$SFXPlayer.play()
			return
		
		is_shooting = true
		player_state = Enums.player_actions.FIRING
		$Telenade.visible = true
		$Telenade.linear_velocity = Vector2.ZERO
		$Telenade.angular_velocity = 0
		$Telenade.apply_central_impulse(firing_vector * 500 * FIRE_POWER_MULTIPLYER)

func handle_firing_state():
	if Input.is_action_pressed("Teleport"):
		# Let everyone know we're done shooting
		is_shooting = false
		
		# Decrease gun energy and let listeners know by how much
		gun_energy -= global_position.distance_to($Telenade.global_position) / 50
		remaining_gun_energy.emit(gun_energy)
		
		# Complete the teleport and resize
		global_position = $Telenade.global_position
		
		# Reset player state
		player_state = Enums.player_actions.AIMING
		$Telenade.visible=false

func recharge_gun(amount: float) -> void:
	gun_energy = min(gun_energy + amount, 100)
	remaining_gun_energy.emit(gun_energy)
