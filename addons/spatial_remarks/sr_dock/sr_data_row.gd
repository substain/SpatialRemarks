@tool
class_name SRDataRow
extends HBoxContainer

signal select_entry(srd: SRData)

enum Column {
	POSITION,
	TEXT,
	AUTHOR,
	TARGET_NODE,
	SCENE,
	VERSION
}

@export var _position_label: Label
@export var _text_label: Label
@export var _author_label: Label
@export var _target_node_label: Label
@export var _scene_label: Label
@export var _version_label: Label

var srdata: SRData

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func init(srd: SRData) -> void:
	srdata = srd
	_position_label.text = str(srd.global_position)
	_text_label.text = srd.text
	_author_label.text = srd.author
	_target_node_label.text = srd.target_node
	_scene_label.text = srd.scene
	_version_label.text = srd.project_version
	

func set_column_visible(column: Column, is_visible_new: bool) -> void:
	get_column(column).visible = is_visible_new
	
func set_column_size(column: Column, size_new: int) -> void:
	get_column(column).custom_minimum_size.x = size_new

func get_column(column: Column) -> Label:
	match column:
		Column.POSITION: return _position_label
		Column.TEXT: return _text_label
		Column.AUTHOR: return _author_label
		Column.TARGET_NODE: return _target_node_label
		Column.SCENE: return _scene_label
		Column.VERSION: return _version_label
		
	push_warning("handling for column ", Column.keys()[column], " not implemented")
	return null


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var iemb: InputEventMouseButton = event as InputEventMouseButton
		if iemb.pressed && iemb.button_index == MOUSE_BUTTON_LEFT:
			select_entry.emit(srdata)
		

func _on_mouse_entered() -> void:
	pass
	#highlight here

func _on_mouse_exited() -> void:
	pass
	#unhighlight here
