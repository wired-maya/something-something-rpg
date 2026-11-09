@tool class_name FilmWindowOld extends Panel

# TODO: MAKE IN RUST!!!!
# TODO: MAKE AN EDITOR FOR THESE IN RUST!!!!

# TODO: Make display in theme scene correctly

#region Data Classes

class RectStateOld:
	var current: Rect2
	var final: Rect2

	func _init(_rect_cur: Rect2, _rect_final: Rect2) -> void:
		current = _rect_cur
		final = _rect_final

class TweenInfoOld:
	var trans_type: Tween.TransitionType
	var ease_type: Tween.EaseType
	var delay: float
	var duration: float

	func _init(
		_trans_type: Tween.TransitionType,
		_ease_type: Tween.EaseType,
		_delay: float,
		_duration: float
	) -> void:
		trans_type = _trans_type
		ease_type = _ease_type
		delay = _delay
		duration = _duration

#endregion

#region Enums

enum TweenOffsetMode {
	BOTH,
	BEFORE,
	AFTER,
	NONE
}

enum TweenClipMode {
	STRETCH,
	CLIP_CURRENT_SIZE,
	CLIP_FINAL_SIZE
}

enum TweenBufferMode {
	BUFFER,
	IGNORE
}

enum TweenOffsetMotion {
	APART,
	TOGETHER
}

#endregion

#region Signals
# Signals at every stage of animation for further animations
# Coordinates are all global
signal tween_content_container_changed(window: FilmWindow, state: RectStateOld, tween: TweenInfoOld)
signal tween_content_container_changed_start(window: FilmWindow, state: RectStateOld, tween: TweenInfoOld)
signal tween_content_container_changed_end(window: FilmWindow, state: RectStateOld, tween: TweenInfoOld)

signal tween_shadow_changed(window: FilmWindow, state: RectStateOld, tween: TweenInfoOld)
signal tween_shadow_changed_start(window: FilmWindow, state: RectStateOld, tween: TweenInfoOld)
signal tween_shadow_changed_end(window: FilmWindow, state: RectStateOld, tween: TweenInfoOld)

signal tween_window_changed(window: FilmWindow, content_container_state: RectStateOld, shadow_state: RectStateOld, tween: TweenInfoOld)
signal tween_window_changed_start(window: FilmWindow, content_container_state: RectStateOld, shadow_state: RectStateOld, tween: TweenInfoOld)
signal tween_window_changed_end(window: FilmWindow, content_container_state: RectStateOld, shadow_state: RectStateOld, tween: TweenInfoOld)

signal tween_offset_changed(window: FilmWindow, content_container_state: RectStateOld, shadow_state: RectStateOld, tween: TweenInfoOld)
signal tween_offset_changed_start(window: FilmWindow, content_container_state: RectStateOld, shadow_state: RectStateOld, tween: TweenInfoOld)
signal tween_offset_changed_end(window: FilmWindow, content_container_state: RectStateOld, shadow_state: RectStateOld, tween: TweenInfoOld)

# Delay is the smallest between the window size and shadow offset delays, which is to say it's the delay to any animations starting
# Similarly, duration is the total duration for all actions to finish
signal tween_entered(window: FilmWindow, window_content_container_state: RectStateOld, window_shadow_state: RectStateOld, window_tween: TweenInfoOld, offset_content_container_state: RectStateOld, offset_shadow_state: RectStateOld, offset_tween: TweenInfoOld, delay: float, duration: float)
signal tween_changed(window: FilmWindow, window_content_container_state: RectStateOld, window_shadow_state: RectStateOld, window_tween: TweenInfoOld, offset_content_container_state: RectStateOld, offset_shadow_state: RectStateOld, offset_tween: TweenInfoOld, delay: float, duration: float)
signal tween_exited(window: FilmWindow, window_content_container_state: RectStateOld, window_shadow_state: RectStateOld, window_tween: TweenInfoOld, offset_content_container_state: RectStateOld, offset_shadow_state: RectStateOld, offset_tween: TweenInfoOld, delay: float, duration: float)

# Signals for tweening clipping control
signal tween_clipping_control_changed(control: Control, state: RectStateOld, tween: TweenInfoOld)
signal tween_clipping_control_changed_start(control: Control, state: RectStateOld, tween: TweenInfoOld)
signal tween_clipping_control_changed_end(control: Control, state: RectStateOld, tween: TweenInfoOld)

# Signals for tweening the child controls
signal tween_content_control_changed(control: Control, state: RectStateOld, tween: TweenInfoOld)
signal tween_content_control_changed_start(control: Control, state: RectStateOld, tween: TweenInfoOld)
signal tween_content_control_changed_end(control: Control, state: RectStateOld, tween: TweenInfoOld)

#endregion

#region Exported Variables

# Group of properties that correspond to the animations used after updating window sizing
# The offset tweens correspond to animating the offsets of the content container and shadow rects
@export_group("Tweening", "tween_")

@export var tween_buffer_mode: TweenBufferMode = TweenBufferMode.IGNORE

@export_subgroup("Do Offset Tweens", "do_tween_offset_")
@export var do_tween_offset_change: bool = true # Offsets tween in, window resizes, offsets tween out
@export var do_tween_offset_enter: bool = true # Window resizes, offsets tween out
@export var do_tween_offset_exit: bool = true # Offsets tween in, window resizes

@export_subgroup("On Enter/Window Size", "tween_window_enter_")
@export var tween_window_enter_transition: Tween.TransitionType = Tween.TRANS_CUBIC
@export var tween_window_enter_easing: Tween.EaseType = Tween.EASE_IN
@export var tween_window_enter_delay: float = 0.35
@export var tween_window_enter_duration: float = 0.35

@export_subgroup("On Enter/Style Box Offsets", "tween_offset_enter_")
@export var tween_offset_enter_transition: Tween.TransitionType = Tween.TRANS_SINE
@export var tween_offset_enter_easing: Tween.EaseType = Tween.EASE_OUT
@export var tween_offset_enter_delay: float = 0.0
@export var tween_offset_enter_duration: float = 0.1

@export_subgroup("On Enter", "tween_enter_")
@export var tween_enter_anchor: Vector2 = Vector2(1.0, 1.0)

@export_subgroup("On Change/Window Size", "tween_window_change_")
@export var tween_window_change_transition: Tween.TransitionType = Tween.TRANS_CUBIC
@export var tween_window_change_easing: Tween.EaseType = Tween.EASE_IN
@export var tween_window_change_delay: float = 0.0
@export var tween_window_change_duration: float = 0.3

@export_subgroup("On Change/Style Box Offsets", "tween_offset_change_")
@export var tween_offset_change_transition: Tween.TransitionType = Tween.TRANS_SINE
@export var tween_offset_change_easing: Tween.EaseType = Tween.EASE_OUT
@export var tween_offset_change_delay: float = 0.0
@export var tween_offset_change_duration: float = 0.15

@export_subgroup("On Change", "tween_change_")
@export var tween_change_anchor: Vector2 = Vector2(0.5, 0.5)

@export_subgroup("On Exit/Window Size", "tween_window_exit_")
@export var tween_window_exit_transition: Tween.TransitionType = Tween.TRANS_CUBIC
@export var tween_window_exit_easing: Tween.EaseType = Tween.EASE_OUT
@export var tween_window_exit_delay: float = 0.0
@export var tween_window_exit_duration: float = 0.3

@export_subgroup("On Exit/Style Box Offsets", "tween_offset_exit_")
@export var tween_offset_exit_transition: Tween.TransitionType = Tween.TRANS_SINE
@export var tween_offset_exit_easing: Tween.EaseType = Tween.EASE_IN
@export var tween_offset_exit_delay: float = 0.0
@export var tween_offset_exit_duration: float = 0.15

@export_subgroup("On Exit", "tween_exit_")
@export var tween_exit_anchor: Vector2 = Vector2(0.0, 0.0)

@export_group("", "")

#endregion

#region Private Variables

var _enter_on_ready: bool = false

var _content_container_stylebox: StyleBox
var _content_container_rect: Rect2
var _content_container_offset: Vector2

var _shadow_stylebox: StyleBox
var _shadow_rect: Rect2
var _shadow_offset: Vector2

var _tween: Tween

# TODO: Recalculate with setters
var _tween_window_enter_info: TweenInfoOld = TweenInfoOld.new(
	tween_window_enter_transition,
	tween_window_enter_easing,
	tween_window_enter_delay,
	tween_window_enter_duration
)
var _tween_offset_enter_info: TweenInfoOld = TweenInfoOld.new(
	tween_offset_enter_transition,
	tween_offset_enter_easing,
	tween_offset_enter_delay,
	tween_offset_enter_duration
)
var _tween_window_change_info: TweenInfoOld = TweenInfoOld.new(
	tween_window_change_transition,
	tween_window_change_easing,
	tween_window_change_delay,
	tween_window_change_duration
)
var _tween_offset_change_info: TweenInfoOld = TweenInfoOld.new(
	tween_offset_change_transition,
	tween_offset_change_easing,
	tween_offset_change_delay,
	tween_offset_change_duration
)
var _tween_window_exit_info: TweenInfoOld = TweenInfoOld.new(
	tween_window_exit_transition,
	tween_window_exit_easing,
	tween_window_exit_delay,
	tween_window_exit_duration
)
var _tween_offset_exit_info: TweenInfoOld = TweenInfoOld.new(
	tween_offset_exit_transition,
	tween_offset_exit_easing,
	tween_offset_exit_delay,
	tween_offset_exit_duration
)

var _clipping_control: Control

var _child_pos_offset: Vector2
var _child_size_offset: Vector2

#endregion

#region Initialization

# If enter_on_ready is false, the enter function must be called later
# If enter_on_ready is true, must provide new_rect
func _init(enter_on_ready: bool = false, new_rect: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)) -> void:
	_enter_on_ready = enter_on_ready
	self.position = new_rect.position
	self.size = new_rect.size

func _ready() -> void:
	_load_theme()
	_on_resized()

	if not Engine.is_editor_hint():
		_on_child_order_changed()
		if _enter_on_ready: _do_tween_enter(func(): pass)

#endregion

#region Callbacks

func _on_theme_changed() -> void: _load_theme()

# Better not to resize when using as a class, use change function
func _on_resized() -> void:
	if Engine.is_editor_hint():
		_content_container_rect.size = size
		_shadow_rect.size = size
		
		_on_child_order_changed()

func _on_child_order_changed() -> void:
	for child in get_children():
		if child is Control:
			child.position = _child_pos_offset
			child.size = size - _child_pos_offset + _child_size_offset
			
			if _clipping_control:
				child.reparent(_clipping_control, false)

#endregion

#region Drawing

func _draw() -> void:
	# TODO: Is there a way to draw the styleboxes with continuous animations while not touching the rect?
	# TODO: For example if you wanted the shadow to spin slowly
	#_shadow_stylebox.draw(get_canvas_item(), _shadow_rect)
	#_content_container_stylebox.draw(get_canvas_item(), _content_container_rect)
	
	draw_style_box(_shadow_stylebox, _shadow_rect)
	draw_style_box(_content_container_stylebox, _content_container_rect)

func _load_theme() -> void:
	_content_container_stylebox = get_theme_stylebox("content_container")
	_content_container_offset = Vector2(
		float(get_theme_constant("content_container_offset_x")),
		float(get_theme_constant("content_container_offset_y"))
	)
	_content_container_rect.position = _content_container_offset
	_content_container_rect.size = size
	
	_shadow_stylebox = get_theme_stylebox("shadow")
	_shadow_offset = Vector2(
		float(get_theme_constant("shadow_offset_x")),
		float(get_theme_constant("shadow_offset_y"))
	)
	_shadow_rect.position = _shadow_offset
	_shadow_rect.size = size
	
	# Update margins
	_child_pos_offset = Vector2(
		_content_container_stylebox.content_margin_left,
		_content_container_stylebox.content_margin_top
	)
	_child_size_offset = Vector2(
		-_content_container_stylebox.content_margin_right,
		-_content_container_stylebox.content_margin_bottom
	)

# Assumes _clipping_control is already initialized
func _start_clipping() -> void:
	add_child(_clipping_control, false, Node.INTERNAL_MODE_FRONT)
	
	for child in get_children():
		child.reparent(_clipping_control, false)

func _stop_clipping() -> void:
	var control = _clipping_control
	_clipping_control = null
	
	for child in control.get_children():
		child.reparent(self, false)
	
	control.queue_free()

# Moves the window control to the new rect while adjusting other rects by offset so they stay in place
func _move_control_preserve_rect_global(new_rect: Rect2, pos_diff: Vector2) -> void:
	# Apply difference to children
	for child in get_children():
		if child is Control: child.position -= pos_diff
	
	self.position = new_rect.position
	self.size = new_rect.size

# Ensure you can resize however you want
func _get_minimum_size() -> Vector2: return Vector2(0.0, 0.0)

func _tween_method_content_container(val: Rect2) -> void:
	_content_container_rect = val
	queue_redraw() # Ran only once a frame, therefore it's fine to call multiple times during tween

func _tween_method_shadow(val: Rect2) -> void:
	_shadow_rect = val
	queue_redraw()

# Tweens content with offsets, useful for clipping and resizing with only the window size rects
func _tween_method_control(
	val: Rect2,
	item: Control,
	pos_offset: Vector2 = Vector2.ZERO,
	size_offset: Vector2 = Vector2.ZERO
) -> void:
	val.position += pos_offset
	val.size += -pos_offset + size_offset
	
	# Do not grow unless there is space for it
	if val.size.x < 0: val.size.x = 0
	if val.size.y < 0: val.size.y = 0
	
	item.position = val.position
	item.size = val.size

#endregion

#region Tween Functions

# Base function for tweening rects managed by this window
# Signals can be null, but if present they must have the following arguments:
# signal_changed(cur_rect: Rect2, final_rect: Rect2, trans: Tween.TransitionType, _ease: Tween.EaseType, duration: float)
# 	Signal is emitted when this function is called
# signal_start(cur_rect: Rect2, final_rect: Rect2, trans: Tween.TransitionType, _ease: Tween.EaseType, duration: float)
#	Signal is emitted when the tween begins
# signal_end(final_rect: Rect2)
#	Signal is emitted when the tween ends
func _do_tween_rect(
	method_func: Callable,
	rect_state: RectStateOld,
	tween_info: TweenInfoOld,
	signal_changed: Signal,
	signal_start: Signal,
	signal_end: Signal
) -> void:
	if not _tween: _tween = create_tween().set_parallel(true)
	_tween.set_trans(tween_info.trans_type).set_ease(tween_info.ease_type)
	
	_tween.tween_method(
		method_func,
		rect_state.current,
		rect_state.final,
		tween_info.duration
	).set_delay(tween_info.delay)
	
	_tween.tween_callback(func(): signal_start.emit(self, rect_state, tween_info)).set_delay(tween_info.delay)
	_tween.tween_callback(func(): signal_end.emit(self, rect_state, tween_info)).set_delay(tween_info.delay + tween_info.duration)
	signal_changed.emit(self, rect_state, tween_info)

# Tweens controls, similar to _do_tween_rect but with offset handling and signals that give references to controls
func _do_tween_control(
	control: Control,
	pos_offset: Vector2,
	size_offset: Vector2,
	rect_state: RectStateOld,
	tween_info: TweenInfoOld,
	signal_changed: Signal,
	signal_start: Signal,
	signal_end: Signal
) -> void:
	if not _tween: _tween = create_tween().set_parallel(true)
	_tween.set_trans(tween_info.trans_type).set_ease(tween_info.ease_type)
	
	_tween.tween_method(
		_tween_method_control.bind(control, pos_offset, size_offset),
		rect_state.current,
		rect_state.final,
		tween_info.duration
	).set_delay(tween_info.delay)
	
	_tween.tween_callback(func(): signal_start.emit(control, rect_state, tween_info)).set_delay(tween_info.delay)
	_tween.tween_callback(func(): signal_end.emit(control, rect_state, tween_info)).set_delay(tween_info.delay + tween_info.duration)
	signal_changed.emit(control, rect_state, tween_info)

# Tween the container's location to a given rect with the appropriate offsets
func _do_tween_content_container(rect_state: RectStateOld, tween_info: TweenInfoOld) -> void:
	_do_tween_rect(
		_tween_method_content_container,
		rect_state,
		tween_info,
		tween_content_container_changed,
		tween_content_container_changed_start,
		tween_content_container_changed_end
	)

func _do_tween_shadow(rect_state: RectStateOld, tween_info: TweenInfoOld) -> void:
	_do_tween_rect(
		_tween_method_shadow,
		rect_state,
		tween_info,
		tween_shadow_changed,
		tween_shadow_changed_start,
		tween_shadow_changed_end
	)

# Generic function for tweening both rects
func _do_tween_rects(
	content_container_rect_state: RectStateOld,
	shadow_rect_state: RectStateOld,
	tween_info: TweenInfoOld,
	
	signal_call: Signal, # Emitted when this function is called
	signal_start: Signal,
	signal_end: Signal
) -> void:
	_do_tween_content_container(content_container_rect_state, tween_info)
	_do_tween_shadow(shadow_rect_state, tween_info)
	
	_tween.tween_callback(
		func(): signal_start.emit(self, content_container_rect_state, shadow_rect_state, tween_info)
	).set_delay(tween_info.delay)
	_tween.tween_callback(
		func(): signal_end.emit(self, content_container_rect_state, shadow_rect_state, tween_info)
	).set_delay(tween_info.delay + tween_info.duration)

	signal_call.emit(self, content_container_rect_state, shadow_rect_state, tween_info)

# Calls chain at the end
func _do_tween_offsets(
	tween_offset_motion: TweenOffsetMotion,
	content_container_from: Rect2,
	shadow_from: Rect2,
	tween_info: TweenInfoOld
) -> void:
	var offset_content_container_rect_state: RectStateOld = RectStateOld.new(
		content_container_from,
		content_container_from
	)
	var offset_shadow_rect_state: RectStateOld = RectStateOld.new(
		shadow_from,
		shadow_from
	)
	
	if tween_offset_motion == TweenOffsetMotion.APART:
		offset_content_container_rect_state.final.position += _content_container_offset
		offset_shadow_rect_state.final.position += _shadow_offset
	elif tween_offset_motion == TweenOffsetMotion.TOGETHER:
		offset_content_container_rect_state.final.position -= _content_container_offset
		offset_shadow_rect_state.final.position -= _shadow_offset
	
	_do_tween_rects(
		offset_content_container_rect_state,
		offset_shadow_rect_state,
		tween_info,
		
		tween_offset_changed,
		tween_offset_changed_start,
		tween_offset_changed_end
	)

# Starts clipping, clipping must be stopped manually afterwards
func _do_tween_clipping_control(
	content_container_rect_state: RectStateOld,
	tween_info: TweenInfoOld,
	clip_mode: TweenClipMode
) -> void:
	if not _clipping_control:
		_clipping_control = Control.new()
		_clipping_control.clip_contents = true
	
	_do_tween_control(
		_clipping_control,
		_child_pos_offset,
		_child_size_offset,
		content_container_rect_state,
		tween_info,
		tween_clipping_control_changed,
		tween_clipping_control_changed_start,
		tween_clipping_control_changed_end
	)
	
	_tween.tween_callback(_start_clipping)
	
	var child_size: Vector2 = _child_size_offset - _child_pos_offset
	
	if clip_mode == TweenClipMode.CLIP_CURRENT_SIZE:
		child_size += content_container_rect_state.current.size
	elif clip_mode == TweenClipMode.CLIP_FINAL_SIZE:
		child_size += content_container_rect_state.final.size
	
	# Since children are passed as references, this can be ran before reparenting
	for child in get_children():
		if child is Control:
			_do_tween_control(
				# Since it's a child of the clipping rect, it is already offset
				child,
				Vector2.ZERO,
				Vector2.ZERO,
				RectStateOld.new(
					Rect2(
						-content_container_rect_state.current.position, # Keep it relative to FilmWindow
						child_size
					),
					Rect2(
						-content_container_rect_state.final.position,
						child_size
					)
				),
				tween_info,
				tween_content_control_changed,
				tween_content_control_changed_start,
				tween_content_control_changed_end
			)

func _do_tween_window_size(
	content_container_rect_state: RectStateOld,
	shadow_rect_state: RectStateOld,
	clip_mode: TweenClipMode,
	tween_info: TweenInfoOld
) -> void:
	_do_tween_rects(
		content_container_rect_state,
		shadow_rect_state,
		tween_info,
		
		tween_window_changed,
		tween_window_changed_start,
		tween_window_changed_end
	)
	
	if clip_mode == TweenClipMode.STRETCH:
		for child in get_children():
			if child is Control:
				_do_tween_control(
					child,
					_child_pos_offset,
					_child_size_offset,
					content_container_rect_state,
					tween_info,
					tween_content_control_changed,
					tween_content_control_changed_start,
					tween_content_control_changed_end
				)
	else:
		_do_tween_clipping_control(
			content_container_rect_state,
			tween_info,
			clip_mode
		)

# Resize/move the window to the new rect
# TODO: Add buffering or don't run if an animation is happening
# TODO: Return rect state of window
# TODO: Move chain commands here instead of other tween funcs
func _do_tween_change(
	new_rect: Rect2,
	tween_window_info: TweenInfoOld,
	tween_offset_info: TweenInfoOld,
	tween_offset_mode: TweenOffsetMode,
	callback: Callable,
	clip_mode: TweenClipMode = TweenClipMode.STRETCH,
	tween_signal: Signal = tween_changed
) -> void:
	if _tween: # TODO: ??
		if _tween.is_running(): return
		_tween.kill()
		_tween = null
	
	_tween = create_tween().set_parallel(true)
	
	var window_control_rect_pos_diff: Vector2 = new_rect.position - self.position
	
	# Update positions when tweening begins, so the update is drawn at the same time as the rects
	_tween.tween_callback(_move_control_preserve_rect_global.bind(new_rect, window_control_rect_pos_diff))
	
	# Update rects so tweening calculations are from the correct place
	_content_container_rect.position -= window_control_rect_pos_diff
	_shadow_rect.position -= window_control_rect_pos_diff
	
	var window_content_container_rect_state: RectStateOld = RectStateOld.new(
		_content_container_rect,
		Rect2(Vector2.ZERO, new_rect.size)
	)
	var window_shadow_rect_state: RectStateOld = RectStateOld.new(
		_shadow_rect,
		Rect2(Vector2.ZERO, new_rect.size)
	)
	
	if tween_offset_mode == TweenOffsetMode.NONE:
		window_content_container_rect_state.final.position = _content_container_offset
		window_shadow_rect_state.final.position = _shadow_offset
	else:
		window_content_container_rect_state.current.position -= _content_container_offset
		window_shadow_rect_state.current.position -= _shadow_offset
	
	if tween_offset_mode == TweenOffsetMode.BOTH or tween_offset_mode == TweenOffsetMode.BEFORE:
		_do_tween_offsets(
			TweenOffsetMotion.TOGETHER,
			_content_container_rect,
			_shadow_rect,
			tween_offset_info
		)
		
		# End of offset tween
		_tween.chain()

	_do_tween_window_size(
		window_content_container_rect_state,
		window_shadow_rect_state,
		clip_mode,
		tween_window_info
	)
	
	# End of window size tween
	_tween.chain()
	
	# Tween clipping must be de-initialized manually
	if clip_mode == TweenClipMode.CLIP_CURRENT_SIZE or clip_mode == TweenClipMode.CLIP_FINAL_SIZE:
		_tween.tween_callback(_stop_clipping)
	
	var offset_content_container_rect_state: RectStateOld = RectStateOld.new(
		_content_container_rect,
		window_content_container_rect_state.final
	)
	var offset_shadow_rect_state: RectStateOld = RectStateOld.new(
		_shadow_rect,
		window_shadow_rect_state.final
	)
	
	if tween_offset_mode == TweenOffsetMode.BOTH or tween_offset_mode == TweenOffsetMode.AFTER:
		_do_tween_offsets(
			TweenOffsetMotion.APART,
			window_content_container_rect_state.final,
			window_shadow_rect_state.final,
			tween_offset_info
		)
		
		# End of offset tween
		_tween.chain()
		
		offset_content_container_rect_state.final.position += _content_container_offset
		offset_shadow_rect_state.final.position += _shadow_offset
	
	_tween.tween_callback(callback)
	
	# This marks the end of the change animation tween
	_tween.chain()
	
	var total_delay: float
	if tween_offset_mode == TweenOffsetMode.BOTH or tween_offset_mode == TweenOffsetMode.BEFORE:
		total_delay = tween_offset_info.delay
	else: total_delay = tween_window_info.delay
	
	var total_duration: float = tween_window_info.delay + tween_window_info.duration
	var offset_duration: float = (tween_offset_info.delay + tween_offset_info.duration)
	if tween_offset_mode == TweenOffsetMode.BOTH: total_duration += offset_duration * 2.0
	if tween_offset_mode == TweenOffsetMode.BEFORE or tween_offset_mode == TweenOffsetMode.AFTER:
		total_duration += offset_duration
	
	tween_signal.emit(
		self,
		
		window_content_container_rect_state,
		window_shadow_rect_state,
		tween_window_info,
		
		offset_content_container_rect_state,
		offset_shadow_rect_state,
		tween_offset_info,
		
		total_delay,
		total_duration
	)

func _do_tween_enter(callback: Callable) -> void:
	var window_rect_state: RectStateOld = RectStateOld.new(
		Rect2(position + (tween_enter_anchor * size), Vector2.ZERO),
		get_rect()
	)
	
	# Make sure the content is hidden at first
	for child in get_children():
		if child is Control:
			child.size = Vector2.ZERO
	
	# Initial window rect
	self.position = window_rect_state.current.position
	self.size = window_rect_state.current.size
	
	# Enter hidden
	_content_container_rect = Rect2(_content_container_offset, Vector2.ZERO)
	_shadow_rect = Rect2(_shadow_offset, Vector2.ZERO)
	
	var tween_offset_mode: TweenOffsetMode
	if do_tween_offset_enter: tween_offset_mode = TweenOffsetMode.AFTER
	else: tween_offset_mode = TweenOffsetMode.NONE
	
	_do_tween_change(
		window_rect_state.final,
		_tween_window_enter_info,
		_tween_offset_enter_info,
		tween_offset_mode,
		callback,
		TweenClipMode.CLIP_FINAL_SIZE,
		tween_entered
	)

func _do_tween_exit(callback: Callable) -> void:
	var window_rect_state: RectStateOld = RectStateOld.new(
		get_rect(),
		Rect2(position + (tween_exit_anchor * size), Vector2.ZERO)
	)
	
	var tween_offset_mode: TweenOffsetMode
	if do_tween_offset_exit: tween_offset_mode = TweenOffsetMode.BEFORE
	else: tween_offset_mode = TweenOffsetMode.NONE
	
	_do_tween_change(
		window_rect_state.final,
		_tween_window_exit_info,
		_tween_offset_exit_info,
		tween_offset_mode,
		callback,
		TweenClipMode.CLIP_CURRENT_SIZE,
		tween_exited
	)

#endregion

#region Public Transformation Functions

# Animates in the window to the control's size, given by new_rect
func enter(new_rect: Rect2) -> void:
	self.position = new_rect.position
	self.size = new_rect.size
	
	_do_tween_enter(func(): pass)

# TODO: Do not allow using these tween functions if there is already a tween
# TODO: 	Queue? Don't allow? Option for both?

# Change window position/size with animations
func set_rect(new_rect: Rect2) -> void:
	_do_tween_change(
		new_rect,
		_tween_window_change_info,
		_tween_offset_change_info,
		TweenOffsetMode.BOTH,
		func(): pass
	)
 
# Change window position/size with animations, using a relative value
func set_rect_relative(relative_rect: Rect2) -> void:
	var new_rect: Rect2 = get_rect()
	new_rect.position += relative_rect.position
	new_rect.size += relative_rect.size
	
	set_rect(new_rect)

func set_rect_pos(new_pos: Vector2) -> void:
	var new_rect: Rect2 = get_rect()
	new_rect.position = new_pos
	
	set_rect(new_rect)

func set_rect_size(new_size: Vector2) -> void:
	var new_rect: Rect2 = get_rect()
	new_rect.size = new_size
	
	set_rect(new_rect)

# Run close animation while keeping the window in the scene tree
func minimize() -> void: _do_tween_exit(func(): visible = false)

# Shrink window and close
func close() -> void: _do_tween_exit(queue_free)

#endregion
