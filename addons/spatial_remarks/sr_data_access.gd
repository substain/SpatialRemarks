class_name SRDataAccess
extends Node

enum DataSourceType {
	JSON
}

enum NodeReferenceDisplay {
	PATH,
	NAME,
	NONE
}

class Config:
	
	# General
	var author: String
	var project_name: String
	var project_version: String

	# Data
	var data_source_type: DataSourceType
	var data_location: String
	
	# Remark Creation
	var author_editable: bool
	var show_position: bool
	var scene_name_display: NodeReferenceDisplay
	var show_target_node: bool
	var target_node_selectable: bool
	var category_selectable: bool
	
	# Display
	var collision_layer_number: int
	
	static func get_default(plugin_path: String) -> Config:
		var default_config: Config = Config.new()
		default_config.author = "unknown"
		default_config.project_name = "unspecified"
		default_config.project_version = "unspecified"
		default_config.data_source_type = DataSourceType.JSON
		default_config.data_location = "user://spatial_remarks/sr_data.json"
		default_config.author_editable = false
		default_config.show_position = false
		default_config.scene_name_display = NodeReferenceDisplay.NONE
		default_config.show_target_node = false
		default_config.target_node_selectable = false
		default_config.category_selectable = false
		default_config.collision_layer_number = 32
		
		return default_config
		
## Note: this is computed from the asset folder. Retrieve via get_plugin_path()
static var plugin_path: String = ""

## The file path for the default configuration below the addon path. This will usually be addons/spatial_remarks/DEFAULT_ADDON_CFG_PATH
const DEFAULT_ADDON_CFG_PATH: String = "/sr_config.cfg"
	
## If a configuration file exists at CFG_OVERRIDE_PATH, use it to override the default configuration for each listed attribute.
## This can be used to override specific values for different users (e.g. the author property) and ignore it in the version control.
const CFG_OVERRIDE_PATH: String = "user://spatial_remarks/sr_config_override.cfg"

const PROJECT_SETTINGS_IDENTIFIER: String = "[project]"

static func load_sr_data(config: Config) -> Array[SRData]:
	print("loading sr data..")

	var current_sr_data: Array[SRData] = []
	match config.data_source_type:
		DataSourceType.JSON: current_sr_data = _load_srd_from_json_files(config)
	
		_: push_warning("SRDataHandler: No handling implemented for data source type '", DataSourceType.keys()[config.data_source_type], "'. Saving data ignored.")
	return current_sr_data

static func _load_srd_from_json_files(config: Config) -> Array[SRData]:	
	if !FileAccess.file_exists(config.data_location):
		print("SRDataHandler: No spatial remark data found at '", config.data_location ,"'")
		return []# We don't have a file to load.
	
	var res: Array[SRData] = []
	var json_file_access: FileAccess = FileAccess.open(config.data_location, FileAccess.READ)
	
	while json_file_access.get_position() < json_file_access.get_length():
		var json_string: String = json_file_access.get_line()
		var json: JSON = JSON.new()
		var parse_result: Error = json.parse(json_string)
		if parse_result != OK:
			push_warning("SRDataHandler: JSON Parse Error: '" + json.get_error_message() + "'  at line " + str(json.get_error_line()))
			continue
		
		var sr_data_from_json: Array[SRData] = str_to_var(json.get_data())
		res.append_array(sr_data_from_json)
		
	json_file_access.close()
	print("SRDataHandler: loaded ", res.size(), " spatial remark(s).")

	return res

static func _save_srd(config: Config, sr_data: Array[SRData]) -> void:
	match config.data_source_type:
		DataSourceType.JSON: _save_srd_to_json_file(config, sr_data)
		_: push_warning("SRDataHandler: No handling implemented for data source type '", DataSourceType.keys()[config.data_source_type], "'. Saving data ignored.")

static func _save_srd_to_json_file(config: Config, sr_data: Array[SRData]) -> void:
	var target_path: String = config.data_location
	
	var path_available = prepare_path(target_path)
	if !path_available:
		push_warning("SRDataHandler: could not save to json file")
		return
			
	var json_file_access: FileAccess = FileAccess.open(config.data_location, FileAccess.WRITE)

	var json_string: String = JSON.stringify(var_to_str(sr_data))
	json_file_access.store_line(json_string)
	json_file_access.close()
	print("SRDataHandler: saved ", sr_data.size(), " spatial remark(s).")

static func prepare_path(target_path: String) -> bool:
	if target_path.begins_with("res://"):
		# This is to avoid issues with exported folder locations.
		push_error("SRDataHandler: saving to 'res://' paths is not supported (used path: '", target_path, "')")
		return false
		
	var dir_end_idx: int = max(target_path.rfind("\\"), target_path.rfind("/")) + 1
	var target_dir: String = target_path.substr(0, dir_end_idx)
	
	if !DirAccess.dir_exists_absolute(target_dir):
		DirAccess.make_dir_recursive_absolute(target_dir)
		
	return true
	
static func load_config() -> Config:
	print("loading config..")
	var config: Config = Config.get_default(get_plugin_path())
	
	var default_filepath: String = get_plugin_path() + DEFAULT_ADDON_CFG_PATH
	if FileAccess.file_exists(default_filepath):
		_update_config_from_path(config, default_filepath)
		
	if FileAccess.file_exists(CFG_OVERRIDE_PATH):
		_update_config_from_path(config, CFG_OVERRIDE_PATH)
		
	return config

static func _update_config_from_path(config: Config, path: String) -> void:
	var config_file: ConfigFile = ConfigFile.new()
	var status: Error = config_file.load(path)
	if status != OK:
		push_warning("SRDataHandler: Could not load SR configuration file from '", path, "', error was: ", status)
		return

	# General
	var author: String = _load_value(config_file, "general", "author")
	if !author.is_empty():
		config.author = author
		
	var project_name: String = _load_value(config_file, "general", "project_name", "application/config/name")
	if !project_name.is_empty():
		config.project_name = project_name
		
	var project_version: String = _load_value(config_file, "general", "project_version", "application/config/version")
	if !project_version.is_empty():
		config.project_version = project_version

	# Data		
	var data_source_type: String = _load_value(config_file, "data", "source_type")
	if !data_source_type.is_empty():
		config.data_source_type = _to_data_source_type(data_source_type)
		
	var data_location: String = _load_value(config_file, "data", "location")
	if !data_location.is_empty():
		config.data_location = data_location
		
	# Remark Creation
	var author_editable: String = _load_value(config_file, "creation", "author_editable")
	if !author_editable.is_empty():
		config.author_editable = str_to_var(author_editable)
		
	var show_position: String = _load_value(config_file, "creation", "show_position")
	if !show_position.is_empty():
		config.show_position = str_to_var(show_position)
		
	var scene_name_display: String = _load_value(config_file, "creation", "scene_name_display")
	if !scene_name_display.is_empty():
		config.scene_name_display = _to_node_reference_display(scene_name_display)
		
	var show_target_node: String = _load_value(config_file, "creation", "show_target_node")
	if !show_target_node.is_empty():
		config.show_target_node = str_to_var(show_target_node)
		
	var target_node_selectable: String = _load_value(config_file, "creation", "target_node_selectable")
	if !target_node_selectable.is_empty():
		config.target_node_selectable = str_to_var(target_node_selectable)
		
	var category_selectable: String = _load_value(config_file, "creation", "category_selectable")
	if !category_selectable.is_empty():
		config.category_selectable = str_to_var(category_selectable)
	
	# display
	var collision_layer_number: String = _load_value(config_file, "display", "collision_layer_number")
	if !collision_layer_number.is_empty():
		config.collision_layer_number = str_to_var(collision_layer_number)

static func _load_value(config: ConfigFile, config_section: String, config_value: String, project_settings_path: String = "") -> String:
	var cfg_value: Variant = config.get_value(config_section, config_value, "")
	if !cfg_value is String:
		cfg_value = var_to_str(config.get_value(config_section, config_value, ""))
	if cfg_value.strip_edges().is_empty():
		return ""
		
	if !project_settings_path.is_empty() && cfg_value.strip_edges().to_lower() == PROJECT_SETTINGS_IDENTIFIER:
		var project_settings_value: String = ProjectSettings.get_setting(project_settings_path, "") as String
		if project_settings_value.strip_edges().is_empty():
			return ""
		
		cfg_value = project_settings_value
	return cfg_value

static func _to_data_source_type(dst_string: String) -> DataSourceType:
	if dst_string.to_lower().strip_edges() == "json":
		return DataSourceType.JSON

	push_warning("SRDataHandler: DataSourceType '", dst_string, "' not recognized. Defaulting to JSON")
	return DataSourceType.JSON

static func _to_node_reference_display(nrd_string: String) -> NodeReferenceDisplay:
	if nrd_string.to_lower().strip_edges() == "path":
		return NodeReferenceDisplay.PATH
	elif nrd_string.to_lower().strip_edges() == "name":
		return NodeReferenceDisplay.NAME

	return NodeReferenceDisplay.NONE

static func get_plugin_path() -> String:
	if plugin_path.is_empty():
		plugin_path = (new().get_script() as Script).resource_path.get_base_dir()
		
	return plugin_path
