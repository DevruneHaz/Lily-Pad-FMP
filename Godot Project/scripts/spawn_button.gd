extends Area2D

@onready var book: Node2D = get_parent().get_parent()
@onready var gui: Node2D = get_parent()
@onready var renderer: Window = $Renderer
@onready var clickPolygon: CollisionPolygon2D = $CollisionPolygon2D
@onready var sprite: Sprite2D = $Sprite
@export var type: PackedScene
@export var icon: Texture
var hovering: bool = false
var beginHovering: bool = false
var clickedLeft: bool = false
var clickedRight: bool = false
var spawnedObjects: Array

func _ready() -> void:
	sprite.texture = icon
	sprite.visibility_layer = 0
	sprite.set_visibility_layer_bit(renderer.visibilityLayer, true)
	global_position = global_position + Vector2(960, 530)
	
	
func _process(_delta: float) -> void:
	if renderer.grabbed == true and clickedLeft == false:
		clickedLeft = true
		spawnObject()
		
	if renderer.grabbed == false and clickedLeft == true:
		clickedLeft = false
		
	if renderer.interacted == true and clickedRight == false:
		clickedRight = true
		destroyObject()
	
	if renderer.interacted == false and clickedRight == true:
		clickedRight = false
	
	
	if gui.renderer.visible == true:
		renderer.visible = true
	else:
		renderer.visible = false
		
func spawnObject():
	var object: Node2D = type.instantiate()
	object.position = position
	spawnedObjects.append(object.get_instance_id())
	book.get_parent().add_child(object)
	
func destroyObject():
	var oldObject = instance_from_id(spawnedObjects.get(spawnedObjects.size() - 1))
	spawnedObjects.remove_at(spawnedObjects.size() - 1)
	oldObject.queue_free()
