extends Area2D

@onready var book: Node2D = get_parent().get_parent()
@onready var gui: Node2D = get_parent()
@onready var renderer: Window = $Renderer
@onready var clickPolygon: CollisionPolygon2D = $CollisionPolygon2D

func _ready() -> void:
	global_position = global_position + GameManager.screenCentre
	
	
func _process(_delta: float) -> void:
	if renderer.grabbed == true:
		print("exit")
		book.close_gui()
		renderer.grabbed = false
	
	if gui.renderer.visible == true:
		renderer.visible = true
	else:
		renderer.visible = false
