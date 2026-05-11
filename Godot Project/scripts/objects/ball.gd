extends CharacterBody2D

@onready var renderer: Window = $Renderer
var speed: float
var maxSpeed: int = 355000
var direction: Vector2
var grounded: bool

enum {
	IDLE,
	GRABBED
}
var state = IDLE

func _ready() -> void:
	GameManager.objects.append(self)

func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			idleState(delta)

func idleState(desiredDelta: float):
	velocity.x = velocity.x * 0.5
	if not is_on_floor():
		if grounded:
			grounded = false
		velocity += get_gravity() * 1.5 * desiredDelta
		if speed > 0:
			speed = speed * 0.95
		elif speed < 0:
			speed = speed * 1.05
	else:
		if grounded == false:
			grounded = true
		if speed > 0:
			speed = speed * 0.95
		elif speed < 0:
			speed = speed * 1.05
	
	var collision = move_and_collide(direction * speed * desiredDelta)
	if collision:
		direction = direction.bounce(collision.get_normal())
		
	move_and_slide()
