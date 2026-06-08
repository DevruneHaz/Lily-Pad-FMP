extends CharacterBody2D

#Create Variables-----------------------------------------------------------------------------------

#Import Frog Components
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var renderer: Window = $Renderer
@onready var stateTimer: Timer = $StateTimer

#Import Tongue Components
@onready var tongue: Line2D = $Tongue
@onready var tongueEnd: Sprite2D = $Tongue/TongueEnd
@onready var tongueRenderer: Window = $Tongue/Renderer
@onready var tonguePolygon: Polygon2D = $Tongue/TonguePolygon

#Movement Variables
var speed: float
var speedMultiplier: int = 25
var maxSpeed: int = 355000
var direction: Vector2
var wanderDirection: int = 1
var jumpDirection: int = 1
var grounded: bool
var pushable: bool = false

#State Variables
var grabbed: bool
var interact: bool
var justInteracted: bool
var startGrabbing: bool
var isJumping: bool = false
var onMushroom: bool = false
var eating: bool
var tongueStrength: float = -5
var attached: bool
enum {
	IDLE,
	WANDER,
	JUMP,
	EAT,
	INTERACT,
	LILYPAD,
	MUSHROOM,
	GRABBED
}
var state = IDLE
var lastState = IDLE

#Animation variables
@export var colourPallette: Texture2D
var pallette: Image
var primaryColour: int = 0
var secondaryColour: int = 0
var idleAnim: int = 0

#Relationship Variables
var target: Node2D
var lilypad: Node2D
var mushroom: Node2D

#Generic--------------------------------------------------------------------------------------------
func _ready():
	#Runs when the game starts.
	replaceColours()
	sprite.play()
	stateTimer.start()
	tongueRenderer.visible = false

func _process(_delta: float) -> void:
	animate()
	window_check()
	
	if state == MUSHROOM:
		if mushroom != null:
			global_position.x = mushroom.position.x
		else:
			state = IDLE
		
	if state != EAT:
		grabbed = renderer.grabbed
		interact = renderer.interacted
		
		
		if interact == true:
			justInteracted = true
			lastState = state
			state = INTERACT
			stateTimer.stop()
			sprite.animation = "Interact"
		elif interact == false and justInteracted == true:
			justInteracted = false
			lastState = state
			state = IDLE
			stateTimer.start()
		
		if grabbed == true and startGrabbing == false:
			lastState = state
			state = GRABBED
			stateTimer.stop()
			startGrabbing = true
			detachFromLilypad()
			stepOffMushroom()
		elif grabbed == false and startGrabbing == true:
			lastState = state
			state = IDLE
			stateTimer.start()
			startGrabbing = false

func window_check():
	#Detects when the frog's window is closed and exits the game.
	if renderer:
		pass
	else:
		get_tree().quit()

#Animation------------------------------------------------------------------------------------------
func replaceColours():
	#Changes the colour pallete of the frog.
	primaryColour = 0
	secondaryColour = 0
	pallette = colourPallette.get_image()
	
	while primaryColour != 6:
		sprite.material.set_shader_parameter(("primary_replace_" + str(primaryColour)), pallette.get_pixel(primaryColour, 0))
		primaryColour = primaryColour + 1
		
	while secondaryColour != 4:
		sprite.material.set_shader_parameter(("secondary_replace_" + str(secondaryColour)), pallette.get_pixel((secondaryColour + 6), 0))
		secondaryColour = secondaryColour + 1

func animate():
	#Switches the frog's animation based on state.
	if state != EAT:
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
			elif lastState == EAT:
				eatAnimation(true)
			else:
				idleAnimation()
		elif state == GRABBED:
			idleAnimation()
		else:
			idleAnimation()
	else:
		eatAnimation(false)

func idleAnimation():
	
	if idleAnim == 0:
		sprite.animation = "Idle"
	elif idleAnim == 1:
		sprite.animation = "Croak"
	sprite.play()
	
	if direction.x > 0:
		sprite.flip_h = true
	elif direction.x < 0:
		sprite.flip_h = false
		
	sprite.play()

func idleAnimationLooped():
	#Switches between blinking and croaking in idle animation.
	if sprite.animation == "Idle" or sprite.animation == "Croak":
		idleAnim = randi_range(0, 1)

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

func eatAnimation(backwards: bool):
	sprite.flip_h = false
	sprite.animation = "Eat"
	if backwards == false:
		if sprite.frame == 4:
			sprite.pause()
		else:
			sprite.play()
	elif backwards == true:
		if sprite.frame == 0:
			sprite.pause()
		else:
			sprite.play_backwards()

#Physics States-------------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	#Changs the frog's movement based om state.
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
		EAT:
			eatState()
	
	match state:
		LILYPAD:
			lilypadState()
	
	match state:
		MUSHROOM:
			mushroomState(delta)
	
	match state:
		GRABBED:
			grabbedState(delta)

	if state != LILYPAD:
		var pushForce = 10000
		if self.move_and_slide(): # true if collided
			for i in self.get_slide_collision_count():
				var col = self.get_slide_collision(i)
				if col.get_collider() is RigidBody2D:
					col.get_collider().apply_force(col.get_normal() * -pushForce)
				elif col.get_collider() is CharacterBody2D:
					if col.get_collider().pushable == true:
						col.get_collider().velocity = (col.get_normal() * -100)

func idleState(desiredDelta):
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

	var idleCollision = move_and_collide(direction * speed * desiredDelta)
	if idleCollision:
		direction = direction.bounce(idleCollision.get_normal())
	move_and_slide()

func wanderState():
	direction = Vector2(wanderDirection, 0)
	speed = randf_range(150, 250)

func jumpState():
	if isJumping:
		direction = Vector2(randf_range(40, 60) * jumpDirection, randf_range(60, 80))
		speed = randf_range(30, 50)
		isJumping = false
		jumpComplete()

func eatState():
	if target:
		velocity = Vector2(0, 0)
		direction = Vector2(0, 0)
		speed = 0
		tongue.visible = true
		tongueEnd.visible = true
		tongueRenderer.visible = true
		tongueRenderer.get_parent().set_visibility_layer_bit(1, true)
		tongueRenderer.sprite.set_visibility_layer_bit(1, true)
		tongueRenderer.window.set_canvas_cull_mask_bit(1, true)
		tongueRenderer._Camera.set_visibility_layer_bit(1, true)
		
		for overlapped_body in target.eat_area.get_overlapping_bodies():
			if overlapped_body == self:
				for value in GameManager.grassHoppers:
					if value == target:
						GameManager.objects.erase(value)
						GameManager.grassHoppers.erase(value)
						GameManager.renderers.erase(value.renderer)
						target.queue_free()
		
		if target.grabbing.grabbed == true:
			target.state = 1
			tongueStrength = tongueStrength * 1.002
			var mousePos: Vector2 = tongueRenderer.get_mouse_position()
			var mouseDir: Vector2 = Vector2((self.position.x - 12) - target.renderer.position.x, (self.position.y + 24) - target.renderer.position.y).normalized()
			var newMousePosX: float = mousePos.x - (mouseDir.x * tongueStrength)
			var newMousePosY: float = mousePos.y - (mouseDir.y * tongueStrength)
			
			DisplayServer.warp_mouse(Vector2(newMousePosX, newMousePosY))
		else:
			target.state = 3
		
		tongueRenderer.grab_focus()
		target.eaten(self)
		tongue.set_point_position(0, tongue.to_local(self.global_position + Vector2(-12, 24)))
		tongue.set_point_position(1, tongue.to_local(target.global_position))
		tongueEnd.position = (tongue.to_local(target.global_position))
		
	else:
		tongueStrength = -5
		stateTimer.wait_time = randf_range(1.5, 3)
		idleAnim = randi_range(0, 1)
		stateTimer.start()
		tongueRenderer.visible = false
		tongue.visible = false
		tongueEnd.visible = false
		state = IDLE
		lastState = EAT

func lilypadState():
	if lilypad != null:
		global_position = lilypad.attach_area.global_position + Vector2(0, -10)
		renderer.grab_focus()
	else:
		detachFromLilypad()

func mushroomState(desiredDelta):
	if mushroom != null:
		renderer.grab_focus()
		if is_on_floor():
			direction = Vector2(direction.x, -50)
			speed = randf_range(30, 50)
	
		elif not is_on_floor():
			if grounded == true:
				grounded = false
			velocity += get_gravity() * 2 * desiredDelta
			if speed > 0:
				speed = speed * 0.95
			elif speed < 0:
				speed = speed * 1.05
	
		var mushroomCollision = move_and_collide(direction * speed * desiredDelta)
		if mushroomCollision:
			direction = direction.bounce(mushroomCollision.get_normal())
	
		move_and_slide()
	else:
		state = IDLE
		idleAnim = randi_range(0, 1)
		stateTimer.start()

func grabbedState(desiredDelta):
	#Make pet attach to cursor
	direction = (get_global_mouse_position() - position).normalized()
	GameManager.hovering = self
	velocity = Vector2(0, 0)
		
	if speed >= maxSpeed:
		speed = maxSpeed
	else:
		if round(position.distance_to(get_global_mouse_position())) == 0:
			speed = 0
		else:
			speed = position.distance_to(get_global_mouse_position()) * speedMultiplier
	
	var grabbedCollision = move_and_collide(direction * speed * desiredDelta)
	if grabbedCollision:
		direction = direction.bounce(grabbedCollision.get_normal())

#Triggers-------------------------------------------------------------------------------------------
func stateTimerTimeout():
	if GameManager.grassHoppers.is_empty():
		var jumping: bool = randi_range(0, 1)
		if jumping:
			jumpDirection = randi_range(-1, 0)
			if jumpDirection == 0:
				jumpDirection = 1
			isJumping = true
			state = JUMP
			lastState = IDLE
		else:
			stateTimer.wait_time = randf_range(2, 3)
			wanderDirection = randi_range(-1, 0)
			if wanderDirection == 0:
				wanderDirection = 1
			stateTimer.start()
			state = WANDER
			lastState = IDLE
	else:
		target = GameManager.grassHoppers.pick_random()
		state = EAT
		lastState = IDLE

func jumpComplete():
	stateTimer.wait_time = randf_range(2, 5)
	idleAnim = randi_range(0, 1)
	stateTimer.start()
	velocity = Vector2(0, 0)
	state = IDLE
	
	lastState = JUMP

func attachToLilypad(targetLilypad):
	if state != GRABBED:
		if attached == false:
			stateTimer.stop()
			renderer.grab_focus()
			state = LILYPAD
			lilypad = targetLilypad
			attached = true

func detachFromLilypad():
	lilypad = null
	state = GRABBED
	attached = false

func stepOnMushroom(targetMushroom):
	if state != GRABBED:
		if onMushroom == false:
			stateTimer.stop()
			state = MUSHROOM
			mushroom = targetMushroom
			onMushroom = true

func stepOffMushroom():
	state = GRABBED
	onMushroom = false
