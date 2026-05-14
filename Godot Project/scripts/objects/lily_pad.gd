extends CharacterBody2D

@onready var renderer: Window = $Renderer
@onready var attach_area: Area2D = $"Attach Area"
var speed: float
var maxSpeed: int = 355000
var direction: Vector2
var attached: bool
var pushable: bool = false

enum {
	IDLE,
	GRABBED
}
var state = IDLE

func _ready() -> void:
	GameManager.objects.append(self)

func _physics_process(_delta: float) -> void:
	attach()
	
	match state:
		IDLE:
			idleState()
			
	match state:
		GRABBED:
			Frog.renderer.grab_focus()
	
func attach():
	for overlapped_body in attach_area.get_overlapping_bodies():
		if overlapped_body == Frog:
			Frog.attachToLilypad(self)
			Frog.renderer.grab_focus()
				
				#Frog.global_position = attach_area.global_position + Vector2(0, 50)

func idleState():
	velocity = Vector2(0, 0)
