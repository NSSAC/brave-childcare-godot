@tool
class_name CarpetObject
extends SmartObject

@export var carpet_texture: Texture2D:
	set(value):
		carpet_texture = value
		_apply_carpet_texture()

@onready var carpet_sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	super()
	_apply_carpet_texture()

func _apply_carpet_texture() -> void:
	var sprite: Sprite2D = carpet_sprite
	if sprite == null:
		sprite = get_node_or_null("Sprite2D") as Sprite2D
	if sprite == null:
		return
	if carpet_texture != null:
		sprite.texture = carpet_texture
