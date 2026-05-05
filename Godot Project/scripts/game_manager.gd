extends Node2D

@onready var _MainWindow: Window = get_window()
@export var hovering: Node2D
@onready var layer: int = 0
@onready var grassHopperLayer: int = 1
@onready var mousePosition: Vector2

var grassHoppers: Array[Node2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().get_root().set_transparent_background(true)
	_MainWindow.borderless = true
	_MainWindow.always_on_top = true
	_MainWindow.unfocusable = true
	_MainWindow.transient = true
	_MainWindow.minimize_disabled = true
	_MainWindow.maximize_disabled = true
	set_passthrough()
	
func _process(_delta: float) -> void:
	mousePosition = get_global_mouse_position()

func set_passthrough() -> void: #Sets coordinates of the hitbox
	var texture_corners: PackedVector2Array = [
		Vector2(0, 0), # Top left corner
		Vector2(0, 0), # Top right corner
		Vector2(0, 0), # Bottom right corner
		Vector2(0, 0) # Bottom left corner
		]
  
	DisplayServer.window_set_mouse_passthrough(texture_corners, 0) #Makes everything outside hitbox non-clickable
