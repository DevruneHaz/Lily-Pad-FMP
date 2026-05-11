extends CharacterBody2D

@onready var gui: Node2D = $"Book GUI"
@onready var renderer: Window = $Renderer
var interact: bool = false
var guiOpen: bool = false

enum {
	IDLE,
	GRABBED
}
var state = IDLE

var grounded: bool
var speed: float
var direction: Vector2
var rotationAngle: float
var justHitFloor: bool

func _ready():
	position = GameManager.screenCentre

func _process(_delta: float) -> void:
	interact = renderer.interacted
	if interact == true:
		open_gui()
		renderer.interacted = false

func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			idleState(delta)
		
	match state:
		GRABBED:
			justHitFloor = false
			
	rotationState(delta)

func idleState(desiredDelta: float):
	velocity.x = velocity.x * 0.5
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

func rotationState(desiredDelta):
	if is_on_floor_only():
		if justHitFloor == false:
			justHitFloor = true
			rotation_degrees = snapped(rotation_degrees, 90)
			
	if not justHitFloor:
		var angleTo = transform.x.angle_to(direction)
		rotate(sign(angleTo) * min(desiredDelta * speed, abs(angleTo)))

func open_gui():
	if guiOpen == false:
		gui.renderer.visible = true
		gui.visible = true
		guiOpen = true
		for button in gui.spawnButtons:
			button.renderer.grab_focus()

func close_gui():
	if guiOpen == true:
		gui.renderer.visible = false
		gui.visible = false
		guiOpen = false
	
