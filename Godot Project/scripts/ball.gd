extends RigidBody2D

var speed: float
var maxSpeed: int = 355000
var direction: Vector2

enum {
	IDLE,
	GRABBED
}
var state = IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta: float) -> void:
#	#Make pet attach to cursor
#	direction = (get_global_mouse_position() - position).normalized()
#	game_manager.hovering = self
#	velocity = Vector2(0, 0)
#		
#	if speed >= maxSpeed:
#		speed = maxSpeed
#	else:
#		speed = position.distance_to(get_global_mouse_position()) * speedMultiplier
#	
#	var collision = move_and_collide(direction * speed * delta)
#	if collision:
#		direction = direction.bounce(collision.get_normal())
#	
#	move_and_slide()
