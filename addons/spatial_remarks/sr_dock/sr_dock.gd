@tool
class_name SRDock
extends PanelContainer

@export var _content_vbc: VBoxContainer
@export var _sr_data_row: PackedScene
@export var _srd_detail: SRDDetail

var _config: SRDataAccess.Config
var _sr_data: Dictionary[SRData, SRDataRow] = {}

func _ready() -> void:
	update_sr_data(true)
	
	_srd_detail.visible = false
	
#func _process(delta: float) -> void:
	#pass

func update_sr_data(reload_config: bool = false) -> void:
	if reload_config:
		_config = SRDataAccess.load_config()
	
	var sr_data: Array[SRData] = SRDataAccess.load_sr_data(_config)
	_sr_data.clear()	
	for srd: SRData in sr_data:
		var srdr: SRDataRow = _sr_data_row.instantiate()
		_content_vbc.add_child(srdr)
		srdr.init(srd)
		_sr_data[srd] = srdr
		srdr.select_entry.connect(_on_select_entry)


func _on_select_entry(entry: SRData) -> void:
	_srd_detail.visible = true
	_srd_detail.load_srd(entry)
	
func _on_resized() -> void:
	pass # Replace with function body.


func _on_import_button_pressed() -> void:
	pass # Replace with function body.


func _on_refresh_button_pressed() -> void:
	print("refresh pressed")
	update_sr_data(true)
