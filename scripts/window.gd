extends Window

@onready var _Camera: Camera2D = $Camera2D
@onready var frog: CharacterBody2D = $".."
@onready var window: Window = $"."

var last_position: = Vector2i.ZERO
var velocity: = Vector2i.ZERO

func _ready() -> void:
	# Set the anchor mode to "Fixed top-left"
	# Easier to work with since it corresponds to the window coordinates
	_Camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	
	close_requested.connect(queue_free) # Actually close the window when clicking the close button

func _process(_delta: float) -> void:
	velocity = position - last_position
	last_position = position
	_Camera.position = get_camera_pos_from_window()
	window.position = Vector2(frog.position.x - 96, frog.position.y - 96)

func get_camera_pos_from_window()->Vector2i:
	return position + velocity
	
