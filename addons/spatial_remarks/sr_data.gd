@tool
class_name SRData
extends RefCounted

var author: String
#var project_name: String -> do we really need this?
var project_version: String
var scene: String
var target_node: String
var text: String
var global_position: Vector3
var creation_date: String
#var context: Dictionary
#var category: Category
var is_2d: bool = false

func duplicate() -> SRData:
	var res: SRData = SRData.new()
	res.author = self.author
	#res.project_name = self.project_name
	res.project_version = self.project_version
	res.scene = self.scene
	res.target_node = self.target_node
	res.text = self.text
	res.global_position = self.global_position
	res.creation_date = self.creation_date
	res.is_2d = self.is_2d
	#res.context = self.context.duplicate()
	#res.category = self.category
	return res
	
func update_from_reference(srd: SRData) -> void:
	self.author = srd.author
	self.project_version = srd.project_version
	self.scene = srd.scene
	self.target_node = srd.target_node
	self.text = srd.text
	self.global_position = srd.global_position
	self.creation_date = srd.creation_date
	self.is_2d = srd.is_2d
	
func get_global_position_tr(snap_steps: float = 0.01) -> String:
	var res: String = "(" + str(snappedf(global_position.x, snap_steps)) + ", " + str(snappedf(global_position.y, snap_steps))
	if !is_2d:
		res += ", " + str(snappedf(global_position.z, snap_steps))
	return res + ")"


	
