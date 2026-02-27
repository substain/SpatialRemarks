@tool
class_name SRDataHeaders
extends HBoxContainer

@export var _version_label: Label
@export var _position_label: Label
@export var _target_node_label: Label
@export var _scene_label: Label
@export var _author_label: Label
@export var _text_label: Label

var used_font: Font

func _ready() -> void:
	used_font = _version_label.get_theme_default_font()

func get_column_text_size(column: SRDataTable.Column) -> int:
	return used_font.get_string_size(get_column(column).text).x + SRDataRow.TEXT_SIZE_OFFSET

func set_column_visible(column: SRDataTable.Column, is_visible_new: bool) -> void:
	get_column(column).visible = is_visible_new
	
func set_column_size(column: SRDataTable.Column, size_new: int) -> void:
	get_column(column).custom_minimum_size.x = size_new

func get_column(column: SRDataTable.Column) -> Label:
	match column:
		SRDataTable.Column.POSITION: return _position_label
		SRDataTable.Column.TEXT: return _text_label
		SRDataTable.Column.AUTHOR: return _author_label
		SRDataTable.Column.TARGET_NODE: return _target_node_label
		SRDataTable.Column.SCENE: return _scene_label
		SRDataTable.Column.VERSION: return _version_label
		
	push_warning("handling for column ", SRDataTable.Column.keys()[column], " not implemented")
	return null
