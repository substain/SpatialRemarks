@tool
class_name SRDDetail
extends HBoxContainer

signal save_srd(original: SRData, srd_updated: SRData)
signal delete_srd(original: SRData)

@export var info_text: RichTextLabel
@export var text_edit: TextEdit

var original_srd: SRData
var srd_updated: SRData

func _ready() -> void:
	pass

func load_srd(srd: SRData) -> void:
	original_srd = srd
	srd_updated = srd.duplicate()
	text_edit.text = srd.text
	info_text.text = get_info_text(srd)
	
func get_info_text(srd: SRData) -> String:
	var res = "version: [i]" + str(srd.project_version) + "[/i]\n"
	res += "position: [i]" + str(srd.global_position) + "[/i]\n"
	res += "target node: [i]" + str(srd.target_node) + "[/i]\n"
	res += "scene: [i]" + str(srd.scene) + "[/i]\n"
	res += "author: [i]" + str(srd.author) + "[/i]"
	return res
	
func _on_save_button_pressed() -> void:
	if srd_updated.text == text_edit.text:
		print("SRDetail: nothing to update. Skip saving.")
		return
	srd_updated.text = text_edit.text
	save_srd.emit(original_srd, srd_updated)
	print("SRDetail: saving not implemented.")

func _on_delete_button_pressed() -> void:
	delete_srd.emit(original_srd)
	print("SRDetail: deleting not implemented.")
