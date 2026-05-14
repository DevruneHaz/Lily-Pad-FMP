extends Area2D

@onready var book: Node2D = get_parent().get_parent()
@onready var gui: Node2D = get_parent()
@export var renderer: Window

@onready var renderer_gui: Area2D = $renderer_gui
@onready var dyeSprite: Sprite2D = $Dye
@onready var outlineSprite: Sprite2D = $Dye/Outline
@export var dye: Texture
@export var outline: Texture
@export var colourPallette: Texture2D

var hovering: bool = false
var clickedLeft: bool = false
var clickedRight: bool = false

func _ready() -> void:
	renderer_gui.renderer = renderer
	dyeSprite.texture = dye
	outlineSprite.texture = outline
	
	global_position = global_position + GameManager.screenCentre
	dyeSprite.global_position = global_position
	outlineSprite.global_position = global_position

func _process(_delta: float) -> void:
	if hovering == true:
		outlineSprite.visible = true
	else:
		outlineSprite.visible = false
		
	if hovering == true and renderer.grabbed == true and clickedLeft == false:
		Frog.colourPallette = colourPallette
		Frog.replaceColours()
		clickedLeft = true
		
	if hovering == true and renderer.grabbed == false and clickedLeft == true:
		clickedLeft = false
		
	if hovering == true and renderer.interacted == true and clickedRight == false:
		Frog.colourPallette = colourPallette
		Frog.replaceColours()
		clickedRight = true
	
	if hovering == true and renderer.interacted == false and clickedRight == true:
		clickedRight = false
