extends Area2D

@export var polygon: CollisionPolygon2D
@onready var owned_polygon: CollisionPolygon2D = $CollisionPolygon2D
@export var original_pos: Vector2
var renderer: Window
var mouse_pos: Vector2
@export var focussed: Array[Node2D]
var rendered: bool

func _ready() -> void:
	owned_polygon.polygon.clear()
	owned_polygon.polygon.append_array(polygon.polygon.duplicate())
	global_position = polygon.global_position + GameManager.screenCentre
	owned_polygon.global_position = polygon.global_position + GameManager.screenCentre
	
	for point in owned_polygon.polygon:
		point.x = point.x * 11
		point.y = point.y * 11

func _process(_delta: float) -> void:
	if renderer != null:
		visibility()
		if rendered == false:
			render()
		
		mouse_pos = get_viewport().get_mouse_position()
		
		if renderer.visible == true:
			if mouse_pos.x > (owned_polygon.polygon.get(0).x + global_position.x - GameManager.screenCentre.x - 60) and mouse_pos.x < (owned_polygon.polygon.get(1).x + global_position.x - GameManager.screenCentre.x + 60) and mouse_pos.y > (owned_polygon.polygon.get(1).y + global_position.y - GameManager.screenCentre.y - 60) and mouse_pos.y < (owned_polygon.polygon.get(3).y + global_position.y - GameManager.screenCentre.y + 60):
				polygon.get_parent().hovering = true
			else:
				polygon.get_parent().hovering = false

func render():
	for focus in focussed:
		
		focus.set_visibility_layer_bit(0, false)
		focus.set_visibility_layer_bit((renderer.visibilityLayer), true)
		if focus == focussed.get(focussed.size() - 1):
			rendered = true

func visibility():
	for focus in focussed:
		if focus != focussed.get(focussed.size() - 1):
			focus.visible = renderer.visible
