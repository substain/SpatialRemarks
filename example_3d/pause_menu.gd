extends VBoxContainer

@export var settings_button: Button

var sb_initial_pos: Vector2
var used_mouse_mode: int

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	sb_initial_pos = settings_button.position
	set_paused(false)

func set_paused(is_paused_new: bool) -> void:
	if SRHandler.remark_input_active:
		return
	
	get_tree().paused = is_paused_new
	visible = is_paused_new
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if is_paused_new else Input.MOUSE_MODE_CAPTURED

func _on_continue_button_pressed() -> void:
	set_paused(false)

func _input(event: InputEvent) -> void:
	if !event is InputEventKey:
		return
		
	var iek: InputEventKey = event as InputEventKey
	if iek.pressed && iek.keycode == KEY_ESCAPE:
		set_paused(!get_tree().paused)
		
func _on_button_pivot_mouse_entered() -> void:
	_move_button(true)

func _on_button_pivot_mouse_exited() -> void:
	_move_button(false)

func _on_settings_button_mouse_entered() -> void:
	_move_button(true)

func _on_settings_button_mouse_exited() -> void:
	_move_button(false)

func _move_button(to_offset: bool) -> void:
	if to_offset:
		settings_button.position.x = sb_initial_pos.x + 200 * (1 if randf() > 0.5 else -1)
	else:
		settings_button.position.x = sb_initial_pos.x


func _on_quit_button_pressed() -> void:
	get_tree().quit()
