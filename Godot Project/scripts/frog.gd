extends CharacterBody2D

@onready var game_manager: Node = %GameManager
@onready var frog: CharacterBody2D = $"."
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var renderer: Window = $Renderer

@onready var idle_timer: Timer = $IdleTimer
@onready var wander_timer: Timer = $WanderTimer

enum {
	IDLE,
	WANDER,
	JUMP,
	EAT,
	GRABBED,
}
var state = IDLE

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

func _ready():
	sprite.play()
	idle_timer.start()

func _on_idle_timer_timeout() -> void:
	var jumping: bool = randi_range(0, 1)
	if jumping:
		jumpDirection = randi_range(-1, 0)
		if jumpDirection == 0:
			jumpDirection = 1
		isJumping = true
		state = JUMP
	else:
		wander_timer.wait_time = randf_range(2, 5)
		wanderDirection = randi_range(-1, 0)
		if wanderDirection == 0:
			wanderDirection = 1
		wander_timer.start()
		state = WANDER

func _on_jump_complete() -> void:
	idle_timer.wait_time = randf_range(1, 1.5)
	idle_timer.start()
	velocity = Vector2(0, 0)
	state = IDLE

func _on_wander_timer_timeout() -> void:
	idle_timer.wait_time = randf_range(1, 1.5)
	idle_timer.start()
	velocity = Vector2(0, 0)
	state = IDLE

func _process(_delta: float) -> void:
	grabbed = renderer.grabbed
	if grabbed == true and startGrabbing == false:
		state = GRABBED
		idle_timer.stop()
		wander_timer.stop()
		print(startGrabbing)
		startGrabbing = true
	elif grabbed == false and startGrabbing == true:
		state = IDLE
		idle_timer.start()
		print(startGrabbing)
		startGrabbing = false

func _physics_process(delta: float) -> void:
	#Flip Sprite
	if direction.x > 0:
		sprite.flip_h = true
	elif direction.x < 0:
		sprite.flip_h = false
	
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

func idleState(desiredDelta: float):
	if not is_on_floor():
		if grounded:
			grounded = false
		velocity += get_gravity() * 2 * desiredDelta
		if speed > 0:
			speed = speed * 0.95
		elif speed < 0:
			speed = speed * 1.05
	else:
		if grounded == false:
			grounded = true
			speed = 0
	
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
		speed = position.distance_to(get_global_mouse_position()) * speedMultiplier
	
	var collision = move_and_collide(direction * speed * desiredDelta)
	if collision:
		direction = direction.bounce(collision.get_normal())
	
	move_and_slide()

func wanderState():
	direction = Vector2(10 * wanderDirection, 0)
	speed = randf_range(15, 35)
	
	move_and_slide()

func jumpState():
	if isJumping:
		direction = Vector2(randf_range(40, 60) * jumpDirection, randf_range(60, 80))
		speed = randf_range(30, 50)
		isJumping = false
		_on_jump_complete()
	move_and_slide()
