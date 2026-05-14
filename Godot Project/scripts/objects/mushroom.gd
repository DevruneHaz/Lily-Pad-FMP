extends CharacterBody2D

@onready var renderer: Window = $Renderer
@onready var attach_area: Area2D = $"Attach Area"
var speed: float
var maxSpeed: int = 355000
var direction: Vector2
var grounded: bool
var pushable: bool = false

enum {
	IDLE,
	GRABBED
}
var state = IDLE

func _ready() -> void:
	GameManager.objects.append(self)


func _physics_process(delta: float) -> void:
	bounceFrog()
	
	match state:
		IDLE:
			idleState(delta)

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
	
func bounceFrog():
	for overlapped_body in attach_area.get_overlapping_bodies():
		if overlapped_body == Frog:
			Frog.stepOnMushroom(self)
