extends Node2D

@onready var renderer: Window = $Renderer
@onready var gui: Control = $Control
var visibilityLayer: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visibilityLayer = renderer.visibilityLayer
	#get_children().set_visibility_layer_bit(1, false)
	#get_children().set_visibility_layer_bit(visibilityLayer, true)
	for i in range(gui.get_children().size()):
		gui.get_child(i).set_visibility_layer_bit(1, false)
		gui.get_child(i).set_visibility_layer_bit(visibilityLayer, true)
