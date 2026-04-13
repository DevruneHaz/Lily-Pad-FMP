extends CharacterBody2D


@onready var game_manager: Node = %GameManager
@onready var frog: CharacterBody2D = $"."
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.play()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
