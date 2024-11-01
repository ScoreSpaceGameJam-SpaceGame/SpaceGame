class_name Player
extends CharacterBody2D

const SPEED = 50.0

@onready var aim_indicator_mount_point: Node2D = $AimIndicatorMountPoint

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("MoveLeft", "MoveRight")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	aim_indicator_mount_point.rotation = global_position.angle_to_point(get_global_mouse_position()) + .5*PI
	
	move_and_slide()
