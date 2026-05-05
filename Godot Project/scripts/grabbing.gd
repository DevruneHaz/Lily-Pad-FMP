extends Node2D

@onready var parent: Node2D = get_parent()
@onready var game_manager: Node = GameManager
@export var torque = 1000.0
var renderer: Window
var grabbed: bool
var startGrabbing: bool
var speed: float
var speedMultiplier: int = 25
var maxSpeed: int = 355000
var direction: Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if parent:
		renderer = parent.get_child(parent.get_child_count() - 1)

func _process(_delta: float) -> void:
	grabbed = renderer.grabbed
	if grabbed == true and startGrabbing == false:
		parent.state = 1
		print(startGrabbing)
		startGrabbing = true
	elif grabbed == false and startGrabbing == true:
		parent.state = 0
		print(startGrabbing)
		startGrabbing = false



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	grabbed = renderer.grabbed
	
	if grabbed:
		direction = (get_global_mouse_position() - parent.position).normalized()
		parent.direction = direction
		game_manager.hovering = get_parent()
		parent.velocity = Vector2(0, 0)
			
		if speed >= maxSpeed:
			speed = maxSpeed
		else:
			speed = parent.position.distance_to(get_global_mouse_position()) * speedMultiplier
		parent.speed = speed
		
		var collision = parent.move_and_collide(direction * speed * delta)
		if collision:
			direction = direction.bounce(collision.get_normal())
			
		parent.move_and_slide()
