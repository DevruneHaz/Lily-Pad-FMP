extends CharacterBody2D


@onready var game_manager: Node = %GameManager
@onready var frog: CharacterBody2D = $"."
@onready var _MainWindow: Window = game_manager._MainWindow
@onready var window: Window = $Window

var hovering = false

func _ready() -> void:
	window.world_2d = _MainWindow.world_2d

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()


func _on_mouse_entered() -> void:
	hovering = true
	game_manager.hovering = frog

func _on_mouse_exited() -> void:
	hovering = false
	game_manager.hovering = null
