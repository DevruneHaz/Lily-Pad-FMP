extends Node2D

@onready var renderer: Window = $Renderer
@export var spawnButtons: Array[Node2D]
var visibilityLayer: int
var interact: bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = GameManager.screenCentre
	renderer.visible = false

#func _process(_delta: float) -> void:
	#interact = renderer.interacted
	#if interact == true:
		#renderer.visible = false
	#else:
		#renderer.visible = true
