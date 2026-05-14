extends Window

@onready var _Camera: Camera2D = $Camera2D
@export var focus: Node2D
@export var focusSize: Vector2
@onready var window: Window = $"."
@onready var game_manager: Node = GameManager
@export var sprite: Node2D
@export_range(1, 20) var visibilityLayer: int = 0
@export var offset: Vector2

var last_position: = Vector2i.ZERO
var velocity: = Vector2i.ZERO
var hovering = false

var speed: float
var speedMultiplier: int = 25
var maxSpeed: int = 355000
var direction: Vector2
var grounded: bool
var grabbed: bool
var startGrabbing: bool
var grabPoint: Vector2
var interacted: bool = false

func _ready() -> void:
	# Set the anchor mode to "Fixed top-left"
	# Easier to work with since it corresponds to the window coordinates
	_Camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	close_requested.connect(queue_free) # Actually close the window when clicking the close button
	window.world_2d = game_manager._MainWindow.world_2d # Sets the window to view the main world
	window.size = focusSize * 6
	
	game_manager.renderers.append(self)
	
	#Removes the original render layers of the object
	get_parent().visibility_layer = 0
	sprite.visibility_layer = 0
	window.canvas_cull_mask = 0
	_Camera.visibility_layer = 0

func set_visibility_layers(layer: int):
	#Sets the render layers of the object
	get_parent().set_visibility_layer_bit(layer, true)
	sprite.set_visibility_layer_bit(layer, true)
	window.set_canvas_cull_mask_bit(layer, true)
	_Camera.set_visibility_layer_bit(layer, true)
	
	if visibilityLayer != 0:
		get_parent().set_visibility_layer_bit(0, false)
		sprite.set_visibility_layer_bit(0, false)
		window.set_canvas_cull_mask_bit(0, false)
		_Camera.set_visibility_layer_bit(0, false)
	

func _physics_process(_delta: float) -> void:
	velocity = position - last_position
	last_position = position
	_Camera.position = get_camera_pos_from_window()
	window.position = Vector2(focus.position.x - ((focusSize.x * 6) / 2), focus.position.y - ((focusSize.y * 6) / 2)) + offset
	set_visibility_layers(visibilityLayer)
	

func get_camera_pos_from_window()->Vector2i:
	return position + velocity
	
func _process(_delta: float) -> void:
	position = Vector2(focus.position.x - ((focusSize.x * 6) / 2), focus.position.y - ((focusSize.y * 6) / 2)) + offset

func _input(event):
	if hovering:
		if event.is_action_pressed("left_click"):
			print("Grabbing ", focus)
			grabbed = true
			
		if event.is_action_released("left_click"):
			grabbed = false
			
		if event.is_action_pressed("right_click"):
			print("Interacting ", focus)
			interacted = true
			
		if event.is_action_released("right_click"):
			interacted = false


func _on_mouse_entered() -> void:
	hovering = true
	game_manager.hovering = focus

func _on_mouse_exited() -> void:
	if grabbed == false:
		hovering = false
		game_manager.hovering = null
