extends Window

@onready var _Camera: Camera2D = $Camera2D
@onready var focus: Node2D = $".."
@export var focusSize: Vector2
@onready var window: Window = $"."
@onready var game_manager: Node = GameManager
@export var sprite: Node2D
@export_range(1, 20) var visibilityLayer: int = 0

var last_position: = Vector2i.ZERO
var velocity: = Vector2i.ZERO
var hovering = false

func _ready() -> void:
	# Set the anchor mode to "Fixed top-left"
	# Easier to work with since it corresponds to the window coordinates
	_Camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	close_requested.connect(queue_free) # Actually close the window when clicking the close button
	window.world_2d = game_manager._MainWindow.world_2d # Sets the window to view the main world
	window.size = focusSize * 6
	
	visibilityLayer = game_manager.layer + 1
	game_manager.layer = visibilityLayer
	
	#Sets the render layers of the object
	get_parent().set_visibility_layer_bit(visibilityLayer, true)
	#window.canvas_cull_mask = visibilityLayer
	window.set_canvas_cull_mask_bit(visibilityLayer, true)
	#_Camera.visibility_layer = visibilityLayer
	_Camera.set_visibility_layer_bit(visibilityLayer, true)
	#sprite.visibility_layer = visibilityLayer
	sprite.set_visibility_layer_bit(visibilityLayer, true)
	

func _physics_process(_delta: float) -> void:
	velocity = position - last_position
	last_position = position
	_Camera.position = get_camera_pos_from_window()
	window.position = Vector2(focus.position.x - ((focusSize.x * 6) / 2), focus.position.y - ((focusSize.y * 6) / 2))

func get_camera_pos_from_window()->Vector2i:
	return position + velocity

func _on_mouse_entered() -> void:
	hovering = true
	game_manager.hovering = focus
	print("hovering")
	
	print(get_parent().visibility_layer)
	print(window.canvas_cull_mask)
	print(_Camera.visibility_layer)
	print(sprite.visibility_layer)

func _on_mouse_exited() -> void:
	hovering = false
	game_manager.hovering = null
