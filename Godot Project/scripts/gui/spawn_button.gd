extends Area2D

@onready var book: Node2D = get_parent().get_parent()
@onready var gui: Node2D = get_parent()
@export var renderer: Window
#@onready var renderer: Window = $Renderer
@onready var renderer_gui: Area2D = $renderer_gui
@onready var drawingSprite: Sprite2D = $Drawing
@onready var iconSprite: Sprite2D = $Drawing/Icon
@export var type: PackedScene
@export var icon: Texture
@export var drawing: Texture
@export var disabled: Texture
var hovering: bool = false
var beginHovering: bool = false
var clickedLeft: bool = false
var clickedRight: bool = false
var spawnedObjects: Array
var active: bool = true
@export var limit: int

func _ready() -> void:
	renderer_gui.renderer = renderer
	drawingSprite.texture = drawing
	iconSprite.texture = icon
	
	global_position = global_position + GameManager.screenCentre
	drawingSprite.global_position = global_position
	iconSprite.global_position = global_position
	
func _on_cooldown_timeout() -> void:
	active = true
	
func _process(_delta: float) -> void:
	
	
	if GameManager.objects.size() >= GameManager.maxObjects or spawnedObjects.size() >= limit and not limit == 0:
		active = false
		iconSprite.texture = disabled
		iconSprite.visible = true
	else:
		active = true
		iconSprite.texture = icon
	
	
	if active == true:
		if type != null:
			if hovering == true:
				iconSprite.visible = true
			else:
				iconSprite.visible = false
			
			if hovering == true and renderer.grabbed == true and clickedLeft == false:
				clickedLeft = true
				if GameManager.objects.size() < GameManager.maxObjects:
					if limit == 0 or spawnedObjects.size() < limit:
						spawnObject()
		
		if hovering == true and renderer.grabbed == false and clickedLeft == true:
			clickedLeft = false
		
	if hovering == true and renderer.interacted == true and clickedRight == false:
		if type != null:
			clickedRight = true
			destroyObject()
	
	if hovering == true and renderer.interacted == false and clickedRight == true:
		clickedRight = false
	
	
#	if gui.renderer.visible == true:
#		renderer.visible = true
#	else:
#		renderer.visible = false
		
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
			
