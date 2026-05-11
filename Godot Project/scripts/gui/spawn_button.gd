extends Area2D

@onready var book: Node2D = get_parent().get_parent()
@onready var gui: Node2D = get_parent()
@onready var renderer: Window = $Renderer
@onready var clickPolygon: CollisionPolygon2D = $CollisionPolygon2D
@onready var buttonSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite: Sprite2D = $Sprite
@export var type: PackedScene
@export var icon: Texture
@onready var cooldown: Timer = $Cooldown
var hovering: bool = false
var beginHovering: bool = false
var clickedLeft: bool = false
var clickedRight: bool = false
var spawnedObjects: Array
var active: bool = true
@export var limit: int

func _ready() -> void:
	sprite.texture = icon
	global_position = global_position + GameManager.screenCentre
	sprite.visibility_layer = 0
	
func _on_cooldown_timeout() -> void:
	active = true
	
func _process(_delta: float) -> void:
	if GameManager.objects.size() >= GameManager.maxObjects or spawnedObjects.size() >= limit and not limit == 0:
		active = false
		buttonSprite.animation = "deny"
	else:
		active = true
		buttonSprite.animation = "allow"
	
	sprite.set_visibility_layer_bit(renderer.visibilityLayer, true)
	
	if active == true:
		if renderer.grabbed == true and clickedLeft == false:
			clickedLeft = true
			if GameManager.objects.size() < GameManager.maxObjects:
				if limit == 0 or spawnedObjects.size() < limit:
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
	if spawnedObjects.size() > 0:
		var oldObject = instance_from_id(spawnedObjects.get(spawnedObjects.size() - 1))
		if oldObject:
			spawnedObjects.remove_at(spawnedObjects.size() - 1)
			for value in GameManager.objects:
				if value == oldObject:
					GameManager.objects.erase(value)
					GameManager.renderers.erase(value.renderer)
			for value in GameManager.grassHoppers:
				if value == oldObject:
					GameManager.grassHoppers.erase(value)
			oldObject.queue_free()
		else:
			spawnedObjects.erase(instance_from_id(spawnedObjects.get(spawnedObjects.size() - 1)))
			
