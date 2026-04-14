extends RigidBody2D
@onready var renderer: Window = $Renderer
@onready var sprite: Sprite2D = $Sprite2D
@onready var camera: Camera2D = renderer._Camera
@export_range(0, 19) var visibilityLayer: int = 0

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#visibility_layer = visibilityLayer
	#renderer.set_canvas_cull_mask_bit(visibilityLayer, true)
	#camera.visibility_layer = visibilityLayer
	#sprite.visibility_layer = visibilityLayer
