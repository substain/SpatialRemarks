@tool
class_name SRDataTable
extends VBoxContainer

enum Column {
	AUTHOR,
	VERSION,
	SCENE,
	TARGET_NODE,
	POSITION,
	TEXT,
}

const RESIZE_OFFSET: int = 100

signal select_entry(srd: SRData)
signal jump_entry(srd: SRData)

@export var _content_vbc: VBoxContainer
@export var _sr_data_row: PackedScene
@export var _data_headers_hbc: SRDataHeaders

var _col_text_sorted_ids: Array[int] = []
var _col_text_sizes: Dictionary[Column, int] = {}
var _col_text_eq_tresh_size: int = 0
var _col_text_full_size: int = 0
var _parent_size: int = 0

var _previous_size: int = 0
var _inner_resize: bool = false

var visible_columns: Array[Column] = [Column.TARGET_NODE, Column.AUTHOR, Column.TEXT, Column.POSITION]

var _sr_data: Dictionary[SRData, SRDataRow] = {}

func _ready() -> void:
	pass
		
func update_sr_data(sr_data_ar: Array[SRData]) -> void:
	for srdr: SRDataRow in _sr_data.values():
		srdr.queue_free()
		
	_sr_data.clear()
	
	for srd: SRData in sr_data_ar:
		var srdr: SRDataRow = _add_sr_data_row(srd)

	_update_column_data()
	
func _update_column_data() -> void:
	_col_text_sizes.clear()
	
	for col: Column in visible_columns:
		_col_text_sizes[col] = _data_headers_hbc.get_column_text_size(col)
	
	for srdr: SRDataRow in _sr_data.values():
		for col: Column in visible_columns:
			_col_text_sizes[col] = max(_col_text_sizes[col], srdr.get_column_text_size(col))

	_col_text_full_size = _col_text_sizes.values().reduce(func(a:int, b:int) -> int: return a+b)
	_col_text_eq_tresh_size = _col_text_sizes.values().min() * _col_text_sizes.size()
	_col_text_sorted_ids.assign(_col_text_sizes.keys())
	_col_text_sorted_ids.sort_custom(_sort_by_col_size)

	for c: Column in Column.values():
		_set_column_visible(c, visible_columns.has(c), true)

	_compute_column_sizes()

func _add_sr_data_row(from_srd: SRData) -> SRDataRow:
	var srdr: SRDataRow = _sr_data_row.instantiate()
	_content_vbc.add_child(srdr)
	srdr.init(from_srd)
	srdr.set_active_scene(from_srd.scene == EditorInterface.get_edited_scene_root().scene_file_path)

	_sr_data[from_srd] = srdr
	srdr.select_entry.connect(_on_select_entry)
	srdr.jump_selection.connect(_on_jump_to_entry)
	return srdr
	
func _sort_by_col_size(a: int, b: int) -> bool:
	return _col_text_sizes[a] < _col_text_sizes[b]
	
func update_column_sizes(parent_size: int) -> void:
	# Prevent retriggered _on_resized() calls from setting column sizes
	if _inner_resize:
		return
	
	#var psize: int = (get_parent() as EditorDock).size.x
	if parent_size == _parent_size:
		return
	_parent_size = parent_size
	_compute_column_sizes()
	
func _compute_column_sizes() -> void:
	var num_columns: int = visible_columns.size()

	# compute the full space that is available
	# if this is too close to the current size, the minimum size set in the children will slow down/block too big resizes
	var max_size_x: int = max(_parent_size * 0.8, _parent_size - RESIZE_OFFSET)

	var target_sizes: Dictionary[Column, int] = {}
	# shortcut: all columns have reached their content length
	if max_size_x >= _col_text_full_size:
		var available_rests: float = (max_size_x-_col_text_full_size) as float / num_columns

		for col: Column in visible_columns:
			target_sizes[col] = _col_text_sizes[col] + floori(available_rests)
			
		_set_column_sizes(target_sizes)
		#_set_column_sizes(_col_text_sizes) # TODO: use this instead for keeping the table centered?
		return
		
	var reserved_x_size: float = max_size_x as float / num_columns # the size that each column can have
	
	# shortcut: no column has reached its content length
	if max_size_x <= _col_text_eq_tresh_size:
		_set_column_sizes_uniform(reserved_x_size)
		return

	var remaining_size: int = max_size_x
	
	# share the rest size among the other columns
	var remaining_columns: int = num_columns
	for col: Column in visible_columns:
		var target_size_used: int = mini(floori(reserved_x_size), _col_text_sizes[col])
		target_sizes[col] = target_size_used
		remaining_size -= target_size_used
		remaining_columns -= 1
		if remaining_columns > 0:
			reserved_x_size = remaining_size as float / remaining_columns
		else: 
			reserved_x_size = 0
			
	_set_column_sizes(target_sizes)

func _set_column_sizes(sizes: Dictionary[Column, int]) -> void:
	_inner_resize = true

	for elem: SRDataRow in _sr_data.values():
		for column: Column in sizes.keys():
			elem.set_column_size(column, sizes[column])

	for column: Column in sizes.keys():
		_data_headers_hbc.set_column_size(column, sizes[column])
	_inner_resize = false

func _set_column_sizes_uniform(uni_size: int) -> void:
	_inner_resize = true
	for elem: SRDataRow in _sr_data.values():
		for column: Column in visible_columns:
			elem.set_column_size(column, uni_size)

	for column: Column in visible_columns:
		_data_headers_hbc.set_column_size(column, uni_size)
	_inner_resize = false

func _set_column_visible(col: Column, is_visible_new: bool, initial: bool = false) -> void:
	if !initial:
		var has_col: bool = visible_columns.has(col)
		
		if has_col == is_visible_new:
			return

	if is_visible_new && !visible_columns.has(col):
		visible_columns.append(col)

	elif !is_visible_new && visible_columns.has(col):
		visible_columns.erase(col)

	for elem: SRDataRow in _sr_data.values():
		elem.set_column_visible(col, is_visible_new)

	_data_headers_hbc.set_column_visible(col, is_visible_new)

	if !initial:
		_update_column_data()

func _on_select_entry(srd: SRData) -> void:
	select_entry.emit(srd)

func _on_jump_to_entry(srd: SRData) -> void:
	jump_entry.emit(srd)

func set_selected(srd: SRData, is_selected_new: bool) -> void:
	if !_sr_data.has(srd):
		return
		
	_sr_data[srd].set_selected(is_selected_new)

func toggle_column_visible(col: Column) -> void:
	_set_column_visible(col, !visible_columns.has(col))
