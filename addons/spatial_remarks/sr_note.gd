@tool
class_name SRNote
extends Node3D

@export var _note_empty: CompressedTexture2D
@export var _note_visible: CompressedTexture2D
@export var _sprite_3d: Sprite3D
@export var _area_3d: Area3D

var _sr_data: SRData

var is_in_editor: bool = false

func init(sr_data: SRData, target_collision_layer_number: int, in_editor: bool = false) -> void:
	_sr_data = sr_data	
	global_position = sr_data.global_position
	_area_3d.collision_layer = 0
	if target_collision_layer_number > 0:
		_area_3d.set_collision_layer_value(target_collision_layer_number, true)
	#modulate = SRHandler.get_color_by_category(sr_data.category)

func set_highlighted(is_highlighted: bool) -> void:
	_sprite_3d.texture = _note_empty if is_highlighted else _note_visible
	scale = Vector3(1.5, 1.5, 1.5) if is_highlighted else Vector3.ONE
	if is_highlighted:
		if is_in_editor:
			SRHandler.show_sr_note(_sr_data)
	else:
		if is_in_editor:
			SRHandler.hide_sr_note()

func _on_area_3d_mouse_entered() -> void:
	set_highlighted(true)
	
func _on_area_3d_mouse_exited() -> void:
	set_highlighted(false)
