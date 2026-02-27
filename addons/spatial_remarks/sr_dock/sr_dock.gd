@tool
class_name SRDock
extends PanelContainer

const SR_NOTE_SCENE_PATH: String = "/sr_note.tscn"

static var _sr_note_scene: PackedScene

@export var _srd_detail: SRDDetail
@export var _sr_data_table: SRDataTable
@export var column_button: Button

var _config: SRDataAccess.Config

var _sr_data_ar: Array[SRData]

var _node_in_scene: Node
var _instantiated_nodes: Dictionary[SRData, SRNote] = {}
var _selected_srd: SRData = null

# if this is viewed as a scene in the editor and not in the dock, some things might not work
var _is_dock_child: bool = false
var _file_dialog: EditorFileDialog
var col_selection: PopupMenu

func _ready() -> void:
	_sr_note_scene = load(SRDataAccess.get_plugin_path() + SR_NOTE_SCENE_PATH) as PackedScene

	_srd_detail.visible = false

	update_sr_data(true)

	if get_parent() is EditorDock:
		_is_dock_child = true
		(get_parent() as EditorDock).resized.connect(_on_resized)
	else:
		print("no editor dock parent - resized not connected")
	
func scene_changed() -> void:
	update_sr_data()
	
func update_sr_data(reload_config: bool = false) -> void:
	if reload_config:
		_config = SRDataAccess.load_config()
	
	_sr_data_ar = SRDataAccess.load_sr_data(_config)
		
	_sr_data_table.update_sr_data(_sr_data_ar)
	_update_sr_node_display()
	if _selected_srd != null:
		var date: String = _selected_srd.creation_date
		var author: String = _selected_srd.author
		var selected: bool = false
		for srd: SRData in _sr_data_ar:
			if srd.creation_date == date && srd.author == author:
				_on_select_entry(srd)
				selected = true
		if !selected:
			_on_unselect_entry()

func _update_sr_node_display() -> void:
	if !_is_dock_child:
		return
	cleanup_nodes()
	
	_node_in_scene = Node.new()
	
	if EditorInterface.get_edited_scene_root() != null:
		EditorInterface.get_edited_scene_root().add_child(_node_in_scene)

	for srd: SRData in _sr_data_ar:
		_add_sr_node_to_scene(srd)
	
	#print("num instantiated nodes: ", _node_in_scene.get_children().size())
	
func _add_sr_node_to_scene(from_srd: SRData) -> void:
	if !EditorInterface.get_edited_scene_root() is Node3D:
		return
	
	if from_srd.scene != EditorInterface.get_edited_scene_root().scene_file_path:
		return
		
	var target_node: SRNote = _sr_note_scene.instantiate() as SRNote
	_node_in_scene.add_child(target_node)
	_instantiated_nodes[from_srd] = target_node
	target_node.init(from_srd, 0, true)
	
func cleanup_nodes() -> void:
	for node: Node in _instantiated_nodes.values():
		node.queue_free()
	
	_instantiated_nodes.clear()

func _on_resized() -> void:
	var psize: int = (get_parent() as EditorDock).size.x	
	_sr_data_table.update_column_sizes(psize)

func _on_unselect_entry() -> void:
	if !_is_dock_child:
		return
		
	_sr_data_table.set_selected(_selected_srd, false)

	if _instantiated_nodes.has(_selected_srd):
		_instantiated_nodes[_selected_srd].set_highlighted(false)
	_srd_detail.visible = false

func _on_select_entry(entry: SRData) -> void:
	if !_is_dock_child:
		return
	if _selected_srd != null:
		_sr_data_table.set_selected(_selected_srd, false)
		if _instantiated_nodes.has(_selected_srd):
			_instantiated_nodes[_selected_srd].set_highlighted(false)
		
	_selected_srd = entry
	_srd_detail.visible = true
	_srd_detail.load_srd(entry)
	if _instantiated_nodes.has(entry):
		_instantiated_nodes[entry].set_highlighted(true)
	_sr_data_table.set_selected(entry, true)

func _on_sr_table_select_entry(srd: SRData) -> void:
	_on_select_entry(srd)
	
func _on_import_button_pressed() -> void:
	# show import selection menu
	# connect its finished-btn to do_import()
	if _file_dialog != null:
		_file_dialog.queue_free()
	
	_file_dialog = EditorFileDialog.new()
	var favorites: PackedStringArray = _file_dialog.get_favorite_list().duplicate()
	if !favorites.has(ProjectSettings.globalize_path("res://")):
		favorites.append(ProjectSettings.globalize_path("res://"))
	if !favorites.has(ProjectSettings.globalize_path("user://")):
		favorites.append(ProjectSettings.globalize_path("user://"))
	_file_dialog.set_favorite_list(favorites)
	_file_dialog.visible = false
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	_file_dialog.display_mode = FileDialog.DISPLAY_LIST
	_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_file_dialog.filters = ["*.json"]
	_file_dialog.ok_button_text = "Import"
	_file_dialog.files_selected.connect(_do_import_from_paths)
	EditorInterface.popup_dialog_centered(_file_dialog)
	#_file_dialog.visible = true

	#_file_dialog.popup_centered()

func _do_import_from_paths(paths: PackedStringArray) -> void:
	var added_data: Array[SRData] = []
	
	for path: String in paths:
		if !path.ends_with(".json"):
			push_warning("SRDock: loading non-json files is not supported currently. Path was: '", path, "'")
			continue		
		var res: Array[SRData] = SRDataAccess.load_srd_from_json_file(path)
		added_data.append_array(res)
	
	if added_data.size() > 0:
		_do_import(added_data)
	else:
		print("SRDock: No data found to import.")
	if _file_dialog != null:
		_file_dialog.queue_free()

func _do_import(added_data: Array[SRData]) -> void:
	_sr_data_ar.append_array(added_data)
	SRDataAccess._save_srd(_config, _sr_data_ar)
	update_sr_data(false)

func _on_refresh_button_pressed() -> void:
	update_sr_data(true)

func _on_srd_detail_delete_srd(srd: SRData) -> void:
	_sr_data_ar.erase(srd)
	SRDataAccess._save_srd(_config, _sr_data_ar)
	_on_unselect_entry()
	update_sr_data(false)

# we don't need an id, since the reference is already updated in SRDetail
func _on_srd_detail_save_srd() -> void:
	SRDataAccess._save_srd(_config, _sr_data_ar)
	update_sr_data(false)

func _on_column_button_pressed() -> void:
	if col_selection != null:
		col_selection.queue_free()
		
	col_selection = PopupMenu.new()
	col_selection.hide_on_checkable_item_selection = false
	
	var visible_columns: Array[SRDataTable.Column] = _sr_data_table.visible_columns
	for col: SRDataTable.Column in SRDataTable.Column.values():
		var col_name: String = (SRDataTable.Column.keys()[col] as String).to_pascal_case()
		col_selection.add_check_item(col_name, col)
		col_selection.set_item_checked(col, visible_columns.has(col))
	col_selection.index_pressed.connect(_toggle_col_selection)
	EditorInterface.popup_dialog(col_selection, Rect2i(get_screen_transform() * get_local_mouse_position(), Vector2i.ZERO))
	#col_selection.position = column_button.get_global_mouse_position()

func _toggle_col_selection(col_idx: int) -> void:
	_sr_data_table.toggle_column_visible(col_idx as SRDataTable.Column)
	if col_selection != null:
		col_selection.set_item_checked(col_idx, _sr_data_table.visible_columns.has(col_idx))
		
func _on_srd_detail_unselect_srd() -> void:
	_on_unselect_entry()
