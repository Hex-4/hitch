extends CharacterBody2D

@export_range(100, 500) var speed = 150
@export_range(-600, -100) var jump_speed = -220
@export_range(200.0, 1000.0) var gravity = 600
@export_range(0.0, 1.0) var friction = 0.1
@export_range(0.0 , 1.0) var acceleration = 0.1

@onready var hook = %Hook
@onready var anchor = %Anchor

var hooked = false

func _physics_process(delta):
	%HookRay.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("hook"):
		if %HookRay.is_colliding():
			hook.global_position = $HookRay.get_collision_point()
			hooked = true
			var original_global_pos = global_position
			reparent(anchor, false)
			global_position = original_global_pos
			
		
	if (!hooked):
		velocity.y += gravity * delta
		var dir = Input.get_axis("ui_left", "ui_right")
		if dir != 0:
			if !is_on_floor():
				velocity.x = lerp(velocity.x, dir * speed, 0.4)
			velocity.x = lerp(velocity.x, dir * speed, acceleration)
		else:
			velocity.x = lerp(velocity.x, 0.0, friction)
			
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = jump_speed
		move_and_slide()
	
		
func _process(delta: float) -> void:
	print(position)
	
