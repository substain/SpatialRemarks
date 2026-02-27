class_name SRCreation
extends CanvasLayer

const RAY_3D_MAX_ITERATIONS: int = 5
const RAY_3D_MIN_OFFSET: float = 0.1
const RAY_3D_MAX_DISTANCE: int = 25

const NO_VALUE: String = "-"

const ORIGIN_POS_NAME: String = "Self"

class TargetNodeData:
	var node: Node
	var target_position: Vector3
	var target_name: String
	var is_2d: bool
		
	func _init(node_new: Node, target_position_new: Vector3, is_2d_new: bool, custom_name_new: String = "") -> void:
		node = node_new
		target_position = target_position_new
		is_2d = is_2d_new
		target_name = custom_name_new if !custom_name_new.is_empty() else node_new.name

@export var _position_label: RichTextLabel
@export var _position_value_label: RichTextLabel
@export var _target_object_label: RichTextLabel
@export var _target_object_option_button: OptionButton
@export var _target_object_value_label: RichTextLabel
@export var _scene_label: RichTextLabel
@export var _scene_value_label: RichTextLabel
@export var _author_line_edit: LineEdit
@export var _author_value_label: RichTextLabel
@export var _creation_time_value_label: RichTextLabel
@export var _remark_text_edit: TextEdit
@export var _background_rect: ColorRect
@export var _canvas_group: CanvasGroup
@export var _background_mask: TextureRect

var _remark_to_create: SRData
var _config: SRDataAccess.Config
var _possible_targets: Array[TargetNodeData]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_background_rect.size = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
	_background_rect.position = -_background_rect.size / 2
	_canvas_group.position = _background_rect.size / 2
	
func init(config: SRDataAccess.Config) -> void:
	_config = config
	_remark_to_create = collect_sr_data(config)#, target_position, scene_name, possible_targets[0]) #
	
	# DISPLAY PROJECT INFORMATION?
	#config.project_name
	#config.project_version
	
	# AUTHOR
	_author_line_edit.text = _remark_to_create.author
	_author_value_label.visible = !config.author_editable
	_author_line_edit.visible = config.author_editable
	_author_line_edit.editable = config.author_editable

	# SCENE VALUE
	match config.scene_name_display:
		SRDataAccess.NodeReferenceDisplay.PATH:
			_scene_value_label.text = get_viewport().get_tree().current_scene.scene_file_path
			_scene_value_label.visible = true
			_scene_label.visible = true
		SRDataAccess.NodeReferenceDisplay.NAME:
			_scene_value_label.text = get_viewport().get_tree().current_scene.name
			_scene_value_label.visible = true
			_scene_label.visible = true
		_: # SRDataAccess.NodeReferenceDisplay.NONE:
			_scene_value_label.visible = false
			_scene_label.visible = false

	_remark_to_create.creation_date = Time.get_datetime_string_from_system(true, false)
	_creation_time_value_label.text = Time.get_datetime_string_from_system(false, true)
	
	_possible_targets = _query_possible_targets(config)
	var current_target_idx: int = _get_best_target(_possible_targets)

	_position_value_label.text = NO_VALUE
	_target_object_value_label.text = NO_VALUE

	for idx: int in _possible_targets.size():
		_target_object_option_button.add_item(_possible_targets[idx].target_name)
		
	if current_target_idx >= 0:
		_target_object_option_button.select(current_target_idx)
		_remark_to_create.target_node = _possible_targets[current_target_idx].target_name
		_target_object_value_label.text = _possible_targets[current_target_idx].target_name
		_position_value_label.text = str(_possible_targets[current_target_idx].target_position)
		_remark_to_create.is_2d = _possible_targets[current_target_idx].is_2d
		_remark_to_create.global_position = _possible_targets[current_target_idx].target_position

	_target_object_label.visible = config.show_target_node
	_target_object_value_label.visible = config.show_target_node && (_possible_targets.size() == 0 || !config.target_node_selectable)
	_target_object_option_button.visible = config.show_target_node && _possible_targets.size() > 0 && config.target_node_selectable
	_target_object_option_button.disabled = _possible_targets.size() <= 1 || !config.target_node_selectable

	_position_label.visible = config.show_position
	_position_value_label.visible = config.show_position
	
	
	_background_mask.position = get_viewport().get_mouse_position() -_background_rect.size / 2 - _background_mask.size / 2
	#TODO: context?
	#_remark_to_create.context = ...
	
	#TODO: category
	#if config.category_selectable:
	#...


func _on_create_pressed() -> void:
	_remark_to_create.text = _remark_text_edit.text
	
	if _config.author_editable:
		_remark_to_create.author = _author_line_edit.text

	if _config.target_node_selectable:
		var idx: int = _target_object_option_button.selected
		if idx >= 0:
			_remark_to_create.target_node = _possible_targets[idx].target_name
			_remark_to_create.global_position = _possible_targets[idx].target_position
			_remark_to_create.is_2d = _possible_targets[idx].is_2d

	SRHandler.add_data([_remark_to_create])
	finish()
	
func _on_cancel_pressed() -> void:
	finish()
	
func finish() -> void:
	SRHandler.end_remark_input()
	queue_free()
	
func collect_sr_data(config: SRDataAccess.Config) -> SRData:#, target_position: Vector3, scene_name: String, first_target: String) -> SRData:	
	var sr_data: SRData = SRData.new()
	sr_data.author = config.author
	#sr_data.project_name = _config.project_name # Do we need this?
	sr_data.project_version = config.project_version
	sr_data.scene = get_viewport().get_tree().current_scene.scene_file_path
	#sr_data.category = config.default_category #TODO

	return sr_data

func _get_best_target(targets: Array[TargetNodeData]) -> int:
	if targets.size() == 0:
		return -1
	if targets.size() > 1:
		#TODO: we could check here if the targets are visible
		return 1
	
	return 0

static func _get_node_name(node: Node) -> String:
	return node.name
	
func _query_possible_targets(config: SRDataAccess.Config) -> Array[TargetNodeData]:
	if get_viewport().get_camera_3d() != null:
		return _query_possible_targets_3d(config, get_viewport())
		
	if get_viewport().get_camera_2d() != null:
		return _query_possible_targets_2d(config, get_viewport())
		
	return _query_possible_targets_no_camera(config, get_viewport())

static func get_current_datetime_str() -> void:
	return Time.get_datetime_string_from_system()

static func _query_possible_targets_no_camera(config: SRDataAccess.Config, _viewport: Viewport) -> Array[TargetNodeData]:
	return []

static func _query_possible_targets_2d(config: SRDataAccess.Config, _viewport: Viewport) -> Array[TargetNodeData]:
	var camera_2d: Camera2D = _viewport.get_camera_2d()
	return []
	
static func _query_possible_targets_3d(config: SRDataAccess.Config, _viewport: Viewport) -> Array[TargetNodeData]:
	var camera_3d = _viewport.get_camera_3d()
	var space_state: PhysicsDirectSpaceState3D = _viewport.get_world_3d().direct_space_state
	#var look_dir: Vector3 = -camera_3d.global_transform.basis.z.normalized()
	#var start: Vector3 = camera_3d.global_position + look_dir * RAY_3D_MIN_OFFSET
	#var end: Vector3 = camera_3d.global_position + look_dir * RAY_3D_MAX_DISTANCE
	var mouse_pos: Vector2 = _viewport.get_mouse_position()
	var look_dir: Vector3 = camera_3d.project_ray_normal(mouse_pos)
	var start = camera_3d.project_ray_origin(mouse_pos) + look_dir * RAY_3D_MIN_OFFSET
	var end = start + look_dir * RAY_3D_MAX_DISTANCE

	var current_scene: Node = _viewport.get_tree().current_scene
	var current_scene_name: String = _viewport.get_tree().current_scene.name
	
	var collision_rids: Array[RID] = []
	
	var results: Array[TargetNodeData] = [TargetNodeData.new(camera_3d, camera_3d.global_position, false, ORIGIN_POS_NAME)]
	
	for i in RAY_3D_MAX_ITERATIONS:
		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(start, end)
		query.exclude = collision_rids
		var collision_result: Dictionary = space_state.intersect_ray(query)
		if collision_result.has("collider"):
			results.append(TargetNodeData.new(collision_result["collider"] as Node, collision_result["position"], false))
			collision_rids.append(collision_result["rid"] as RID)
		else:
			break
	#print("results: ", results)

	return results


func _on_target_object_option_button_item_selected(index: int) -> void:
	_position_value_label.text = str(_possible_targets[index].target_position)
