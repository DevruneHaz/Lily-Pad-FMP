extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -500.0

@onready var sprite_2d: Sprite2D = $AnimatedSprite2D/Sprite2D
@onready var flingTimer: Timer = $Fling
@onready var heldTimer: Timer = $Held

@onready var Pet: AnimatedSprite2D = $AnimatedSprite2D #Reference to self
@onready var SpriteSize: Vector2i = Vector2i(160, 160) #The size of the character's hitbox.
var WindowMin = DisplayServer.screen_get_position(DisplayServer.get_keyboard_focus_screen()) #Top left corner of screen
var WindowMax = DisplayServer.screen_get_size(DisplayServer.get_keyboard_focus_screen()) #Bottom right corner of screen
var WindowScale #Total size of window

var canMove: bool = true
var isDragging: bool = false
var delay = 10
var flingVelocity
var flinging: bool = false
var grabLocation
var grabTime
var releaseLocation
var releaseTime

func leftclick():
	if flinging == false:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if isDragging == false:
				isDragging = true
				grabTime = Time
				grabLocation = global_position
				canMove = false
				heldTimer.start()
				SpriteSize = Vector2i(4000, 4000)
				
				print("down")
		else:
			if isDragging == true:
				isDragging = false
				releaseTime = Time
				releaseLocation = global_position
				fling_pet()
				heldTimer.paused
				SpriteSize = Vector2i(160, 160)
				print("up")

func fling_pet():
	flingVelocity = (releaseLocation - grabLocation) / (heldTimer.wait_time -heldTimer.time_left)
	print(heldTimer.wait_time -heldTimer.time_left)
	flinging = true
	flingTimer.start()

func _on_fling_timeout() -> void:
	canMove = true
	flinging = false

func _on_held_timeout() -> void:
	if isDragging:
		isDragging = false

func _process(_delta: float) -> void:
	set_passthrough()
	rightclick()
	leftclick()

func set_passthrough() -> void: #Sets coordinates of the hitbox
	var texture_center: Vector2 = SpriteSize / 2.0 # Center
	var texture_corners: PackedVector2Array = [
		Pet.global_position + texture_center * Vector2(-1, -1), # Top left corner
		Pet.global_position + texture_center * Vector2(1, -1), # Top right corner
		Pet.global_position + texture_center * Vector2(1 , 1), # Bottom right corner
		Pet.global_position + texture_center * Vector2(-1 ,1) # Bottom left corneR
		]
  
	DisplayServer.window_set_mouse_passthrough(texture_corners, 0) #Makes everything outside hitbox non-clickable

func _physics_process(delta: float) -> void:

	if isDragging == false:
		if canMove:
			if not is_on_floor():
				velocity += get_gravity() * delta
		
			# Handle jump.
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = JUMP_VELOCITY

			# Get direction
			var direction := Input.get_axis("move_left", "move_right")
	
			# Flip Sprite
			if direction > 0:
				Pet.flip_h = false
			elif direction < 0:
				Pet.flip_h = true
	
			# Player animation
			if is_on_floor():
				if direction == 0:
					Pet.play("idle")
				else:
					Pet.play("run")
			else:
				Pet.play("jump")
			
			#Apply movement
			if direction:
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
		elif flinging == true:
			velocity += flingVelocity * delta
		
		
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", get_global_mouse_position(), delay * delta)

	move_and_slide()

func rightclick():
	if Input.is_action_just_pressed("right_click"):
		detect_application("Chrome")
		
func detect_application(app: String) -> bool:
	var app_active = false
	if OS.get_name() == "Windows": # Verify that we are on Windows
		var output = []
		# Execute "get-process" in powershell and save data in "output":
		OS.execute('powershell.exe', ['/C', "get-process " + app +" | measure-object -line | select Lines -expandproperty Lines"], output)   
		var result = output[0].to_int()
		app_active = result > 0    # If there is more than 0 chrome processes, it will be true
		print("Number of " + app + " processes: " + str(result))
		if app_active == false:
			run_application("C:\\Users\\Damon\\OneDrive\\Desktop\\Applications\\Discord")
	return app_active

func run_application(path: String):
	var pid = OS.shell_open(path)
	print(pid)
