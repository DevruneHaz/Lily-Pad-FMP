extends CharacterBody2D


@onready var game_manager: Node = %GameManager
@onready var frog: CharacterBody2D = $"."
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var renderer: Window = $Renderer

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

func _ready():
	sprite.play()

func _process(_delta: float) -> void:
	grabbed = renderer.grabbed
	if grabbed == true and startGrabbing == false:
		state = GRABBED
		print(startGrabbing)
		startGrabbing = true
	elif grabbed == false and startGrabbing == true:
		state = IDLE
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
