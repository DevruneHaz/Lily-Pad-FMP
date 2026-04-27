extends CharacterBody2D

@export var sprite: Node2D
@onready var jump_timer: Timer = $JumpTimer
@onready var game_manager: Node = %GameManager
@onready var grasshopper: CharacterBody2D = $"."
@onready var eat_area: Area2D = $EatArea
@onready var frog: CharacterBody2D = %Frog
const JUMP_VELOCITY = -400.0
var direction: Vector2
var speed: float
var grounded
var isJumping
var jumpDirection
var was_on_floor
var collisionLayer
var justEaten: bool = false

enum {
	IDLE,
	JUMP,
	EATEN
}
var state = IDLE

func _ready() -> void:
	collisionLayer = game_manager.grassHopperLayer + 1
	game_manager.grassHopperLayer = collisionLayer
	self.collision_mask = 0
	self.collision_layer = 0
	
	self.set_collision_mask_value(collisionLayer, true)
	self.set_collision_layer_value(collisionLayer, true)
	
	game_manager.grassHoppers.append(grasshopper)
	

func _physics_process(delta: float) -> void:
	if state != EATEN:
		if not is_on_floor():
			state = IDLE
		
		if is_on_floor() and not was_on_floor:
			jumpDirection = randi_range(-1, 0)
			if jumpDirection == 0:
				jumpDirection = 1
			isJumping = true
			state = JUMP
		was_on_floor = is_on_floor()
	
	#Flip Sprite
	if direction.x > 0:
		sprite.flip_h = true
	elif direction.x < 0:
		sprite.flip_h = false
	
	match state:
		IDLE:
			idleState(delta)
	
	match state:
		JUMP:
			jumpState()
	
	match state:
		EATEN:
			eatenState(delta)

func idleState(desiredDelta: float):
	velocity += get_gravity() * 2 * desiredDelta
	if speed > 0:
		speed = speed * 0.95
	elif speed < 0:
		speed = speed * 1.05
	
	var collision = move_and_collide(direction * speed * desiredDelta)
	if collision:
		direction = direction.bounce(collision.get_normal())
		
	move_and_slide()

func jumpState():
	if isJumping:
		direction = Vector2(randf_range(60, 80) * jumpDirection, randf_range(40, 60))
		speed = randf_range(30, 50)
		isJumping = false
		on_jump_complete()
	move_and_slide()
	
func on_jump_complete() -> void:
	velocity = Vector2(0, 0)
	state = IDLE

func eaten(newFrog: Node2D):
	if justEaten == false:
		state = EATEN
		frog = newFrog
		print(newFrog)
		justEaten = true

func eatenState(desiredDelta: float):
	velocity = Vector2(0, 0)
	direction = (frog.position - position).normalized()
	speed = position.distance_to(frog.position) * randf_range(7, 10)
	
	for overlapped_body in eat_area.get_overlapping_bodies():
		if overlapped_body == frog:
			for value in game_manager.grassHoppers:
				if value == self:
					game_manager.grassHoppers.erase(value)
					queue_free()
	
	
	var collision = move_and_collide(direction * speed * desiredDelta)
	if collision:
		direction = direction.bounce(collision.get_normal())
	
	move_and_slide()
	
