extends Node

@onready var _MainWindow: Window = get_window()

@export var hovering: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().get_root().set_transparent_background(true)
	_MainWindow.borderless = true
	_MainWindow.always_on_top = true
	set_passthrough()

func set_passthrough() -> void: #Sets coordinates of the hitbox
	var texture_corners: PackedVector2Array = [
		Vector2(0, 0), # Top left corner
		Vector2(0, 0), # Top right corner
		Vector2(0, 0), # Bottom right corner
		Vector2(0, 0) # Bottom left corner
		]
  
	DisplayServer.window_set_mouse_passthrough(texture_corners, 0) #Makes everything outside hitbox non-clickable
