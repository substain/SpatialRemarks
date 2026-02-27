@tool
class_name SRDDetail
extends HBoxContainer

signal save_srd()
signal delete_srd(srd: SRData)
signal unselect_srd()

@export var info_text: RichTextLabel
@export var text_edit: TextEdit

var srd: SRData

func _ready() -> void:
	pass

func load_srd(srd_new: SRData) -> void:
	srd = srd_new
	text_edit.text = srd_new.text
	info_text.text = get_info_text(srd_new)
	
func get_info_text(srd: SRData) -> String:
	var res: String = "Author: [i]" + str(srd.author) + "[/i]\n\n"
	res += "Version: [i]" + str(srd.project_version) + "[/i]\n\n"
	res += "Scene: [i]" + str(srd.scene) + "[/i]\n\n"
	res += "TargetNode: [i]" + str(srd.target_node) + "[/i]\n\n"
	res += "Position: [i]" + str(srd.get_global_position_tr()) + "[/i]"
	return res
	
func _on_save_button_pressed() -> void:
	if srd.text == text_edit.text:
		print("SRDetail: nothing to update. Skip saving.")
		return
	srd.text = text_edit.text
	save_srd.emit()

func _on_delete_button_pressed() -> void:
	delete_srd.emit(srd)

func _on_close_button_pressed() -> void:
	unselect_srd.emit()
