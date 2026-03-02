extends Control

var _should_hide: bool = false
var _focused_button: Control

func _ready() -> void:
	_focused_button = $ResumeButton
	_focused_button.grab_focus()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_toggle"):
		fade_toggle()

func _on_fade_animation_animation_finished(anim_name: StringName) -> void:
	if _should_hide:
		hide()
		
func _on_exit_desktop_button_button_down() -> void:
	get_tree().quit()

func _on_resume_button_pressed() -> void:
	var pause_toggle_event = InputEventAction.new()
	pause_toggle_event.action = "pause_toggle"
	pause_toggle_event.pressed = true
	
	Input.parse_input_event(pause_toggle_event) # Propagate event to keep the HUD handling the UI

func fade_in() -> void:
	_should_hide = false
	focus_mode = Control.FOCUS_ALL
	_focused_button.grab_focus.call_deferred()
	get_tree().paused = true
	
	$FadeAnimation.play("fade_anim")
	show()

func fade_out() -> void:
	$FadeAnimation.play_backwards("fade_anim")
	
	_should_hide = true
	focus_mode = Control.FOCUS_NONE
	get_tree().paused = false

func fade_toggle() -> void:
	# Checks should hide so you can reopen menu when it's fading out
	if _should_hide or not visible: fade_in()
	else: fade_out()

# Not sure if there is a better way to do this
func _on_resume_button_focus_entered() -> void: _focused_button = $ResumeButton
func _on_save_button_focus_entered() -> void: _focused_button = $SaveButton
func _on_load_button_focus_entered() -> void: _focused_button = $LoadButton
func _on_option_button_focus_entered() -> void: _focused_button = $OptionButton
func _on_exit_main_button_focus_entered() -> void: _focused_button = $ExitMainButton
func _on_exit_desktop_button_focus_entered() -> void: _focused_button = $ExitDesktopButton
