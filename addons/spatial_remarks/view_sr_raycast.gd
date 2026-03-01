class_name ViewSRRaycast extends RayCast3D

var current_sr_note: SRNote = null

func _ready() -> void:
	var col_layer: int = SRHandler.get_collision_layer_number()
	collision_mask = 0
	if col_layer > 0:
		set_collision_mask_value(col_layer, true)
		

func _physics_process(delta: float) -> void:
	if !SRHandler.remarks_visible:
		return
	
	if is_colliding():
		var collider: Node3D = get_collider()
		if collider is SRNote:
			var target_sr_note: SRNote = (collider as SRNote)
			if target_sr_note == current_sr_note:
				return
			current_sr_note = (collider as SRNote)
			current_sr_note.set_highlighted(true)
			return

	unhighlight_previous()
	
func unhighlight_previous() -> void:
	if current_sr_note == null:
		return
	
	current_sr_note.set_highlighted(false)
	current_sr_note = null
