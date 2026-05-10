extends StaticBody2D

@onready var border: StaticBody2D = $"."
@onready var game_manager: Node = GameManager

@export var direction: int
var windowMin = Vector2(0,0)
var windowMax = DisplayServer.screen_get_size()
var taskbarHeight = DisplayServer.screen_get_size().y - DisplayServer.screen_get_usable_rect().size.y

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if direction == 1:
		border.global_rotation_degrees = 360
		border.global_position = Vector2(windowMax.x/2, windowMax.y - taskbarHeight)
	elif direction == 2:
		border.global_rotation_degrees = 90
		border.global_position = Vector2(windowMin.x, windowMax.y/2)
	elif direction == 3:
		border.global_rotation_degrees = 180
		border.global_position = Vector2(windowMax.x/2, windowMin.y)
	elif direction == 4:
		border.global_rotation_degrees = 270
		border.global_position = Vector2(windowMax.x, windowMax.y/2)
