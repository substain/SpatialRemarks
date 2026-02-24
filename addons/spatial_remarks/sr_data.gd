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
	#res.context = self.context.duplicate()
	#res.category = self.category

	return res
