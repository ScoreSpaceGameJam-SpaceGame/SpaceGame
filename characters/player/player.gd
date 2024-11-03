class_name Player
extends CharacterBody2D

const SPEED : float = 200.0
const FIRE_POWER_MULTIPLYER : float = 1.25

var player_state : Enums.player_actions = Enums.player_actions.AIMING
var firing_vector : Vector2
var original_mouse_position_when_firing : Vector2
var firing_power : float
var is_shooting: bool = false
var gun_model_x_offset : float = 22

@onready var aim_indicator_mount_point: Node2D = $AimIndicatorMountPoint

func _physics_process(delta: float) -> void:
	# Flip sprite to oriented direction
	if velocity.x > 0:
		$PlayerModel.flip_h = true
		$GunMountPoint/GunModel.flip_h = false
		$GunMountPoint/GunModel.position.x = gun_model_x_offset
	else:
		$PlayerModel.flip_h = false
		$GunMountPoint/GunModel.flip_h = true
		$GunMountPoint/GunModel.position.x = -gun_model_x_offset
		
	
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
	$Telenade.translate(global_position - $Telenade.global_position)
	if Input.is_action_just_pressed("FiringAction"):
		player_state = Enums.player_actions.POWERING
		original_mouse_position_when_firing = get_global_mouse_position()

func handle_powering_state():
	velocity = Vector2.ZERO
	var x_power : float = get_global_mouse_position().distance_to(original_mouse_position_when_firing)
	$Telenade.translate(global_position - $Telenade.global_position)
	firing_power = clamp(log(x_power) * x_power / 2, 0, 100) # TODO use this
	
	if Input.is_action_just_released("FiringAction"):
		is_shooting = true
		player_state = Enums.player_actions.FIRING
		$Telenade.visible = true
		$Telenade.global_rotation = firing_vector.angle()
		$Telenade.apply_central_impulse(firing_vector.normalized() * 500 * FIRE_POWER_MULTIPLYER)

func handle_firing_state():
	if Input.is_action_pressed("Teleport"):
		is_shooting = false
		global_position = $Telenade.global_position
		player_state = Enums.player_actions.AIMING
		$Telenade.visible=false
