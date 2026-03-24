extends Node

var score = 0

@onready var boundary_bottom: AnimatableBody2D = %BoundaryBottom
@onready var boundary_left: AnimatableBody2D = %BoundaryLeft
@onready var boundary_right: AnimatableBody2D = %BoundaryRight
@onready var boundary_top: AnimatableBody2D = %BoundaryTop

@onready var player: CharacterBody2D = $"../Player"
@onready var camera: Camera2D = $"../Camera2D"
@onready var _MainWindow: Window = get_window()

var WindowMin = Vector2(0, 0) #Top left corner of screen
var WindowMax = Vector2(2560, 1440) #Bottom right corner of screen

func get_taskbar_height():
	return (WindowMax.y - DisplayServer.screen_get_usable_rect(DisplayServer.window_get_current_screen()).size.y)

func _ready() -> void:
	get_tree().get_root().set_transparent_background(true)
	boundary_bottom.position.y = WindowMax.y - get_taskbar_height() - 80
	boundary_top.position.y = WindowMin.y - 80
	boundary_left.position.x = WindowMin.x - 80
	boundary_right.position.x = WindowMax.x - 80
	
	_MainWindow.min_size = (Vector2(160, 160))
	_MainWindow.size = _MainWindow.min_size
	_MainWindow.position = player.global_position
	

func _process(_delta: float) -> void:
	camera.position = get_window().position

func add_point(value):
	score += value
