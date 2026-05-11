extends CharacterBody2D

@onready var renderer: Window = $Renderer
@onready var attach_area: Area2D = $"Attach Area"
var speed: float
var maxSpeed: int = 355000
var direction: Vector2
var attached: bool

enum {
	IDLE,
	GRABBED
}
var state = IDLE


func _physics_process(delta: float) -> void:
	attach()
	
	match state:
		IDLE:
			idleState()
	
	if self.move_and_slide(): # true if collided
		for i in self.get_slide_collision_count():
			var col = self.get_slide_collision(i)
			if col.get_collider() is Frog:
				print("GRAHHH")
				
func attach():
	for overlapped_body in attach_area.get_overlapping_bodies():
		if overlapped_body == Frog:
			if Frog.state != GRABBED:
				if attached == false:
					Frog.attachToLilypad(self)
					Frog.idle_timer.paused = true
					Frog.wander_timer.paused = true
					attached = true
				
				#Frog.global_position = attach_area.global_position + Vector2(0, 50)

func idleState():
	velocity = Vector2(0, 0)
