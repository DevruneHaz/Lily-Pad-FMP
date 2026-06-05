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
var array_type
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
	detectObject()
	
	if GameManager.objects.size() >= GameManager.maxObjects or spawnedObjects.size() >= limit and not limit == 0:
		active = false
		iconSprite.texture = disabled
		iconSprite.visible = true
	else:
		active = true
		iconSprite.texture = icon
	
	if type == preload("res://scenes/objects/ball.tscn"):
		array_type = GameManager.balls
	elif type == preload("res://scenes/creatures/grasshopper.tscn"):
		array_type = GameManager.grassHoppers
	elif type == preload("res://scenes/objects/lily_pad.tscn"):
		array_type = GameManager.lily_pads
	elif type == preload("res://scenes/objects/mushroom.tscn"):
		array_type = GameManager.mushrooms
	
	
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
	
func detectObject():
	for object in spawnedObjects:
		if object:
			pass
		else:
			spawnedObjects.erase(object)

func spawnObject():
	var object: Node2D = type.instantiate()
	object.position = position
	spawnedObjects.append(object)
	book.get_parent().add_child(object)
	

func destroyObject():
	if spawnedObjects.size() > 0 and array_type.size() > 0:
		var destroyobject = array_type.get(array_type.size() - 1)
		if destroyobject:
			spawnedObjects.erase(destroyobject)
			for value in GameManager.objects:
				if value == destroyobject:
					GameManager.objects.erase(value)
					GameManager.renderers.erase(value.renderer)
			for value in array_type:
				if value == destroyobject:
					array_type.erase(value)
			destroyobject.queue_free()
		else:
			spawnedObjects.erase(destroyobject)
