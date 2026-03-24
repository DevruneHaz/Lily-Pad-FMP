extends CharacterBody2D


var speed: float
var speedMultiplier: int = 25
var maxSpeed: int = 35000
var direction: Vector2

@onready var player: CharacterBody2D = $"."
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var Pet: AnimatedSprite2D = $AnimatedSprite2D #Reference to self
@onready var SpriteSize: Vector2i = Vector2i(160, 160) #The size of the character's hitbox.

var hovering: bool = false
var canMove: bool = true
var isDragging: bool = false
var grounded: bool


func leftclick(): #Grab / Drop pet
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if hovering:
			if isDragging == false:
				isDragging = true
				SpriteSize = Vector2i(4000, 4000)
	else:
		if isDragging == true:
			isDragging = false
			hovering = false
			SpriteSize = Vector2i(320, 320)

func _process(_delta: float) -> void:
	#set_passthrough()
	leftclick()
	#set_window_position(Pet.global_position)
	

func set_passthrough() -> void: #Sets coordinates of the hitbox
	var texture_center: Vector2 = SpriteSize / 2.0 # Center
	var texture_corners: PackedVector2Array = [
		Pet.global_position + texture_center * Vector2(-1, -1), # Top left corner
		Pet.global_position + texture_center * Vector2(1, -1), # Top right corner
		Pet.global_position + texture_center * Vector2(1 , 1), # Bottom right corner
		Pet.global_position + texture_center * Vector2(-1 ,1) # Bottom left corneR
		]
  
	DisplayServer.window_set_mouse_passthrough(texture_corners, 0) #Makes everything outside hitbox non-clickable

func _physics_process(delta: float) -> void: #Create physics

	#Flip Sprite
	if direction.x > 0:
		Pet.flip_h = false
	elif direction.x < 0:
		Pet.flip_h = true

	if isDragging == false: #Give the pet physics
		if not is_on_floor():
			if grounded:
				grounded = false
			velocity = get_gravity() * 50 * delta
			if speed > 0:
				speed = speed * 0.95
			elif speed < 0:
				speed = speed * 1.05
		else:
			if grounded == false:
				grounded = true
				speed = 0
	else: #Make pet attach to cursor
		direction = (get_global_mouse_position() - position).normalized()
		hovering = true
		
		if speed >= maxSpeed:
			speed = maxSpeed
		else:
			speed = position.distance_to(get_global_mouse_position()) * speedMultiplier

	move_and_slide()

	#Bounce Pet
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		direction = direction.bounce(collision.get_normal())


#Detects when mouse is hovering over character
func _on_mouse_entered() -> void:
	hovering = true


func _on_mouse_exited() -> void:
	hovering = false
