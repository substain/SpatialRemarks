@tool
class_name SRDataRow
extends Container

const NORMAL_BASE_COLOR: Color = Color("18181899")
const HOVER_BASE_COLOR: Color = Color("27272799")
const SELECTED_BASE_COLOR: Color = Color("474747b4")

const NORMAL_IN_SCENE_COLOR: Color = Color("111f1599")
const HOVER_IN_SCENE_COLOR: Color = Color("182b1d99")
const SELECTED_IN_SCENE_COLOR: Color = Color("2a3d2fb1")

const TEXT_SIZE_OFFSET: int = 40

signal select_entry(srd: SRData)
signal jump_selection(srd: SRData)

@export var _selected_color: Color

@export var _version_label: Label
@export var _position_label: Label
@export var _target_node_label: Label
@export var _author_label: Label
@export var _scene_label: Label
@export var _text_label: Label

var srdata: SRData

var used_font: Font

var is_in_active_scene: bool = false
var is_hover: bool = false
var is_selected: bool = false

func _ready() -> void:
	used_font = _version_label.get_theme_default_font()
	
func _process(delta: float) -> void:
	pass

func init(srd: SRData) -> void:
	srdata = srd
	_position_label.text = str(srd.get_global_position_tr())
	_text_label.text = srd.text
	_author_label.text = srd.author
	_target_node_label.text = srd.target_node
	_scene_label.text = srd.scene
	_version_label.text = srd.project_version
	
func get_column_text_size(column: SRDataTable.Column) -> int:
	return used_font.get_string_size(get_column(column).text).x + TEXT_SIZE_OFFSET

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

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var iemb: InputEventMouseButton = event as InputEventMouseButton
		if iemb.double_click:
			jump_selection.emit(srdata)
		
		if iemb.pressed && iemb.button_index == MOUSE_BUTTON_LEFT:
			select_entry.emit(srdata)

func set_selected(is_selected_new: bool) -> void:
	is_selected = is_selected_new
	update_color()

func set_active_scene(is_in_active_scene_new: bool) -> void:
	is_in_active_scene = is_in_active_scene_new
	update_color()
		
func _on_mouse_entered() -> void:
	is_hover = true
	update_color()

func _on_mouse_exited() -> void:
	is_hover = false
	update_color()

func update_color() -> void:
	if is_selected:
		set_color(SELECTED_IN_SCENE_COLOR if is_in_active_scene else SELECTED_BASE_COLOR)
		return

	if is_hover:
		set_color(HOVER_IN_SCENE_COLOR if is_in_active_scene else HOVER_BASE_COLOR)
		return
		
	set_color(NORMAL_IN_SCENE_COLOR if is_in_active_scene else NORMAL_BASE_COLOR)

func set_color(color: Color) -> void:
	(get("theme_override_styles/panel") as StyleBox).bg_color = color
