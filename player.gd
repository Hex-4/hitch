extends CharacterBody2D

@export_range(100, 500) var speed = 150
@export_range(-600, -100) var jump_speed = -220
@export_range(200.0, 1000.0) var gravity = 600
@export_range(0.0, 1.0) var friction = 0.1
@export_range(0.0 , 1.0) var acceleration = 0.1

@onready var hook = %Hook
@onready var anchor = %Anchor


var hooked = false
var hook_point = Vector2.ZERO
var max_rope_length = 60
var climb_speed = 60

func _physics_process(delta):
	%HookRay.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("hook"):
		if %HookRay.is_colliding():
			hook_point = %HookRay.get_collision_point()
			hooked = true

			
			max_rope_length = global_position.distance_to(hook_point)
			
	if Input.is_action_just_released("hook"):
		hooked = false
		
		# Tangent boost on release
		var dir_to_hook = (hook_point - global_position).normalized()
		var tangent = Vector2(-dir_to_hook.y, dir_to_hook.x)
		var release_boost = velocity.dot(tangent)

		if release_boost > 0:
			velocity += tangent * release_boost * 0.5  # convert rope tension into flight

		
	velocity.y += gravity * delta
	var dir = Input.get_axis("left", "right")
	if dir != 0:
		if !is_on_floor():
			velocity.x = lerp(velocity.x, dir * speed, 0.4)
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed
		
	if hooked:
		max_rope_length += Input.get_axis("up", "down") * climb_speed * delta
		var to_hook = global_position - hook_point
		var dist = to_hook.length()
		var dir_to_hook = to_hook.normalized()

		
		# generated with chatgpt ;c (but i forced myself to comment the code so I understand it)
		
		var radial = dir_to_hook
		var radial_speed = velocity.dot(radial)
		if dist > max_rope_length:
			# snap to rope length and remove all radial movement
			global_position = hook_point + dir_to_hook * max_rope_length
			if radial_speed > 0:
				velocity -= radial * radial_speed
		else:
			# rope is slack, only block inward motion
			if radial_speed < 0:
				velocity -= radial * radial_speed
				
		if dist >= max_rope_length:
			var tangent = Vector2(-dir_to_hook.y, dir_to_hook.x)
			var tangential_speed = velocity.dot(tangent)

			# Slightly reinforce tangential motion
			var swing_boost = 1.1
			velocity = tangent * tangential_speed * swing_boost

			

	
	move_and_slide()
	
	
	
		
func _process(delta: float) -> void:
	if hooked:
		
		$Line2D.visible = true
		$Line2D.points = [Vector2.ZERO, $Line2D.to_local(hook_point)]
	else:
		$Line2D.visible = false
	
	
