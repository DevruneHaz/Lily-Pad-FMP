extends CharacterBody2D

@onready var game_manager: Node = GameManager
@onready var frog: CharacterBody2D = $"."
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var renderer: Window = $Renderer

@onready var idle_timer: Timer = $IdleTimer
@onready var wander_timer: Timer = $WanderTimer

@onready var tongue: Line2D = $Tongue
@onready var tongue_end: Sprite2D = $Tongue/TongueEnd
const tongueRenderer = preload("uid://cyfbgcqqn2fdm")
@onready var frogTongueRenderer: Window = $Tongue/Renderer
@onready var tongue_polygon: Polygon2D = $Tongue/TonguePolygon

enum {
	IDLE,
	WANDER,
	JUMP,
	EAT,
	INTERACT,
	LILYPAD,
	GRABBED
}
var state = IDLE
var lastState = IDLE

var speed: float
var speedMultiplier: int = 25
var maxSpeed: int = 355000
var direction: Vector2
var grounded: bool
var grabbed: bool
var startGrabbing: bool
var wanderDirection: int = 1
var jumpDirection: int = 1
var isJumping: bool = false
var target: Node2D
var eating: bool
var interact: bool
var justInteracted: bool
var lilypad: Node2D

func _ready():
	sprite.play()
	idle_timer.start()
	frogTongueRenderer.visible = false

func animate():
	if state == IDLE:
		if lastState == WANDER:
			if speed > 0:
				walkAnimation()
			else:
				idleAnimation()
		elif lastState == JUMP:
			if speed > 0:
				jumpAnimation()
			else:
				idleAnimation()
		elif lastState == GRABBED:
			if speed != 0:
				jumpAnimation()
			else:
				idleAnimation()
		else:
			idleAnimation()
	elif state == GRABBED:
		idleAnimation()
	else:
		idleAnimation()

func idleAnimation():
	sprite.play()
	sprite.animation = "Idle"
	if direction.x > 0:
		sprite.flip_h = true
	elif direction.x < 0:
		sprite.flip_h = false

func walkAnimation():
	sprite.play()
	sprite.flip_h = false
	if direction.x > 0:
		sprite.animation = "Walk_Right"
	elif direction.x < 0:
		sprite.animation = "Walk_Left"

func jumpAnimation():
	sprite.flip_h = false
	sprite.pause()
	if direction.x > 0:
		sprite.animation = "Walk_Right"
	elif direction.x < 0:
		sprite.animation = "Walk_Left"

func fallingAnimation():
	sprite.flip_h = false
	sprite.animation = "Falling_Left"
	if direction.y < 0:
		print("Up")
		if direction.x > 0:
			print("Right")
			sprite.set_frame_and_progress(7, 0)
		elif direction.x < 0:
			print("Left")
			sprite.set_frame_and_progress(1, 0)
		elif direction.x == 0:
			sprite.set_frame_and_progress(0, 0)
			
	elif direction.y > 0:
		print("Down")
		if direction.x > 0:
			print("Right")
			sprite.set_frame_and_progress(5, 0)
		elif direction.x < 0:
			print("Left")
			sprite.set_frame_and_progress(3, 0)
		elif direction.x == 0:
			sprite.set_frame_and_progress(4, 0)
			
	elif direction.y == 0:
		if direction.x > 0:
			print("Right")
			sprite.set_frame_and_progress(6, 0)
		elif direction.x < 0:
			print("Left")
			sprite.set_frame_and_progress(2, 0)
		elif direction.x == 0:
			sprite.set_frame_and_progress(0, 0)
			
	sprite.pause()

func eatAnimation():
	pass

func _on_idle_timer_timeout() -> void:
	if game_manager.grassHoppers.is_empty():
		var jumping: bool = randi_range(0, 1)
		if jumping:
			jumpDirection = randi_range(-1, 0)
			if jumpDirection == 0:
				jumpDirection = 1
			isJumping = true
			state = JUMP
			lastState = IDLE
		else:
			wander_timer.wait_time = randf_range(2, 3)
			wanderDirection = randi_range(-1, 0)
			if wanderDirection == 0:
				wanderDirection = 1
			wander_timer.start()
			state = WANDER
			lastState = IDLE
	else:
		target = game_manager.grassHoppers.pick_random()
		state = EAT
		lastState = IDLE

func _on_jump_complete() -> void:
	idle_timer.wait_time = randf_range(2, 5)
	idle_timer.start()
	velocity = Vector2(0, 0)
	state = IDLE
	lastState = JUMP

func _on_wander_timer_timeout() -> void:
	idle_timer.wait_time = randf_range(1, 2)
	idle_timer.start()
	velocity = Vector2(0, 0)
	state = IDLE
	lastState = WANDER

func _process(_delta: float) -> void:
	animate()
	if state != EAT:
		grabbed = renderer.grabbed
		interact = renderer.interacted
		
		if interact == true:
			justInteracted = true
			lastState = state
			state = INTERACT
			idle_timer.stop()
			wander_timer.stop()
			sprite.animation = "Interact"
		elif interact == false and justInteracted == true:
			justInteracted = false
			lastState = state
			state = IDLE
			idle_timer.start()
		
		if grabbed == true and startGrabbing == false:
			lastState = state
			state = GRABBED
			idle_timer.stop()
			wander_timer.stop()
			startGrabbing = true
		elif grabbed == false and startGrabbing == true:
			lastState = state
			state = IDLE
			idle_timer.start()
			startGrabbing = false

func _physics_process(delta: float) -> void:
	match state:
		GRABBED:
			grabbedState(delta)
	
	match state:
		IDLE:
			idleState(delta)
	
	match state:
		WANDER:
			wanderState()
	
	match state:
		JUMP:
			jumpState()
			
	match state:
		LILYPAD:
			lilypadState()
			
	match state:
		EAT:
			eatState()
			
	if state != LILYPAD:
		var pushForce = 10000
		if self.move_and_slide(): # true if collided
			for i in self.get_slide_collision_count():
				var col = self.get_slide_collision(i)
				if col.get_collider() is RigidBody2D:
					col.get_collider().apply_force(col.get_normal() * -pushForce)
				elif col.get_collider() is CharacterBody2D:
					col.get_collider().velocity = (col.get_normal() * -100)

func idleState(desiredDelta: float):
	if not is_on_floor():
		if grounded == true:
			grounded = false
		velocity += get_gravity() * 2 * desiredDelta
		if speed > 0:
			speed = speed * 0.95
		elif speed < 0:
			speed = speed * 1.05
	else:
		if grounded == false:
			velocity = Vector2(0, 0)
			speed = 0
			direction = Vector2(0, 0)
			grounded = true
			
	var collision = move_and_collide(direction * speed * desiredDelta)
	if collision:
		direction = direction.bounce(collision.get_normal())
	move_and_slide()

func grabbedState(desiredDelta: float):
	#Make pet attach to cursor
	direction = (get_global_mouse_position() - position).normalized()
	game_manager.hovering = self
	velocity = Vector2(0, 0)
		
	if speed >= maxSpeed:
		speed = maxSpeed
	else:
		if round(position.distance_to(get_global_mouse_position())) == 0:
			speed = 0
		else:
			speed = position.distance_to(get_global_mouse_position()) * speedMultiplier
	
	var collision = move_and_collide(direction * speed * desiredDelta)
	if collision:
		direction = direction.bounce(collision.get_normal())

func wanderState():
	direction = Vector2(wanderDirection, 0)
	speed = randf_range(150, 250)

func jumpState():
	if isJumping:
		direction = Vector2(randf_range(40, 60) * jumpDirection, randf_range(60, 80))
		speed = randf_range(30, 50)
		isJumping = false
		_on_jump_complete()

func eatState():
	if target:
		tongue.visible = true
		tongue_end.visible = true
		frogTongueRenderer.visible = true
		frogTongueRenderer.get_parent().set_visibility_layer_bit(1, true)
		frogTongueRenderer.sprite.set_visibility_layer_bit(1, true)
		frogTongueRenderer.window.set_canvas_cull_mask_bit(1, true)
		frogTongueRenderer._Camera.set_visibility_layer_bit(1, true)
		
		frogTongueRenderer.grab_focus()
		target.eaten(self)
		tongue.set_point_position(0, tongue.to_local(self.global_position))
		tongue.set_point_position(1, tongue.to_local(target.global_position))
		tongue_end.position = (tongue.to_local(target.global_position))
		#set_tongue_passthrough()
		
	else:
		idle_timer.wait_time = randf_range(1.5, 3)
		idle_timer.start()
		frogTongueRenderer.visible = false
		tongue.visible = false
		tongue_end.visible = false
		state = IDLE
		lastState = EAT

func set_tongue_passthrough():
	tongue_polygon.polygon.set(0 , Vector2(frog.position.x, frog.position.y))
	tongue_polygon.polygon.set(1 , Vector2(frog.position.x, frog.position.y))
	tongue_polygon.polygon.set(2 , (target.global_position + Vector2(5, 5)))
	tongue_polygon.polygon.set(3 , (target.global_position - Vector2(5, 5)))
	frogTongueRenderer.mouse_passthrough_polygon = tongue_polygon.polygon

func lilypadState():
	global_position = lilypad.attach_area.global_position + Vector2(0, -10)

func attachToLilypad(attach: Node2D):
	state = LILYPAD
	lilypad = attach

func detachFromLilypad():
	state = GRABBED
