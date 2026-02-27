extends Node

const SR_NOTE_SCENE_PATH: String = "/sr_note.tscn"
const SR_CREATION_SCENE_PATH: String = "/sr_creation.tscn"
const SR_IG_OVERLAY_SCENE_PATH: String = "/sr_ingame_overlay.tscn"

static var _sr_creation_scene: PackedScene
static var _sr_note_scene: PackedScene
static var _sr_ingame_overlay_scene: PackedScene

var _config: SRDataAccess.Config

var _sr_data: Dictionary[SRData, Node]
var _sr_editor_dirty: bool = false
var _sr_data_parent: Node3D = Node3D.new()
var sr_ingame_overlay: SRIngameOverlay

var _currently_paused: bool
var _current_mouse_mode: Input.MouseMode

var _start_remark_callback: Callable = Callable(_default_start_remark_callback)
var _end_remark_callback: Callable = Callable(_default_end_remark_callback)

var remark_input_active: bool = false
var remarks_visible: bool = false

func _ready() -> void:
	_sr_creation_scene = load(SRDataAccess.get_plugin_path() + SR_CREATION_SCENE_PATH) as PackedScene
	_sr_note_scene = load(SRDataAccess.get_plugin_path() + SR_NOTE_SCENE_PATH) as PackedScene
	_sr_ingame_overlay_scene = load(SRDataAccess.get_plugin_path() + SR_IG_OVERLAY_SCENE_PATH) as PackedScene

	process_mode = Node.PROCESS_MODE_ALWAYS
	_config = SRDataAccess.load_config()
	var srds: Array[SRData] = SRDataAccess.load_sr_data(_config)
	_sr_editor_dirty = true

	get_tree().current_scene.ready.connect(init.bind(srds))
	
func init(srds: Array[SRData]) -> void:
	_sr_data_parent.name = "SpatialRemarks"
	_sr_data_parent.visible = remarks_visible
	get_tree().current_scene.add_child(_sr_data_parent)
	
	sr_ingame_overlay = _sr_ingame_overlay_scene.instantiate() as SRIngameOverlay
	_sr_data_parent.add_child(sr_ingame_overlay)

	_add_all_srds(srds)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("create_sr"):
		start_remark_input()
	elif event.is_action_pressed("show_sr"):
		set_remarks_visible(!remarks_visible)
	
func set_author(author_new: String) -> void:
	_config.author = author_new

func set_custom_pause_callbacks(start_remark_callback: Callable, end_remark_callback: Callable) -> void:
	_start_remark_callback = start_remark_callback
	_end_remark_callback = end_remark_callback

func add_data(srds: Array[SRData], do_save: bool = true) -> void:
	_add_all_srds(srds)
	_sr_editor_dirty = true
	if do_save:
		save()

func save() -> void:
	SRDataAccess._save_srd(_config, _sr_data.keys())

func start_remark_input() -> void:
	if remark_input_active:
		return
	remark_input_active = true
	var sr_creation: SRCreation = _sr_creation_scene.instantiate() as SRCreation
	get_tree().current_scene.add_child(sr_creation)
	sr_creation.init(_config)
	_sr_data_parent.visible = true

	_start_remark_callback.call()
	
func end_remark_input() -> void:
	_end_remark_callback.call()
	_sr_data_parent.visible = remarks_visible
	remark_input_active = false
		
func _default_start_remark_callback() -> void:
	_currently_paused = get_tree().paused
	get_tree().paused = true
	_current_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _default_end_remark_callback() -> void:
	get_tree().paused = _currently_paused
	Input.mouse_mode = _current_mouse_mode

func set_remarks_visible(visible_new: bool) -> void:
	if remark_input_active:
		return
	_sr_data_parent.visible = visible_new
	remarks_visible = visible_new
	if !remarks_visible:
		hide_sr_note()
		
func get_collision_layer_number() -> int:
	return _config.collision_layer_number

func _add_all_srds(srds: Array[SRData]) -> void:
	for srd: SRData in srds:
		_add_sr_node_to_tree(srd)

func _add_sr_node_to_tree(srd: SRData) -> void:
	if get_tree().current_scene.scene_file_path != srd.scene:
		_sr_data[srd] = null
		return
	var target_node: SRNote = _sr_note_scene.instantiate() as SRNote
	
	_sr_data_parent.add_child(target_node)
	_sr_data[srd] = target_node
	target_node.init(srd, _config.collision_layer_number, false)

func show_sr_note(srd: SRData) -> void:
	sr_ingame_overlay.show_remark(srd)
	
func hide_sr_note() -> void:
	sr_ingame_overlay.hide_remark()
