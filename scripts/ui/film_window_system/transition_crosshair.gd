extends Control

class_name TransitionCrosshair

# TODO: Signals

# TODO: Use draw calls instead

@export var colour_horizontal: Color = Color.hex(0xCD23B9_FF)
@export var colour_vertical: Color = Color.hex(0xCD23B9_FF)

# TODO: Can this be in theme?
@export var rect_width_horizontal: float = 3.0
@export var rect_width_vertical: float = 3.0

@export var centre_pos: Vector2 = Vector2(0.0, 0.0)
@export var centre_anchor: Vector2 = Vector2(0.5, 0.5) # Default makes centre the centre of the rects
# @export var centre_anchor_offset: Vector2 = Vector2(0.0, 0.0)

@export var exit_after_window_enter_complete: bool = true

var _tween: Tween

var _rect_horizontal: ColorRect
var _rect_vertical: ColorRect
var _connected_film_window: FilmWindowBase

# TODO: Is this needed?
#func _init(
	#width_h: float,
	#width_v: float,
	#initial_centre_pos: Vector2,
	#_centre_anchor: Vector2
#) -> void:
	#rect_width_horizontal = width_h
	#rect_width_vertical = width_v
	#centre_pos = initial_centre_pos
	#centre_anchor = _centre_anchor

func _init_rects() -> void:
	if not _rect_horizontal:
		_rect_horizontal = ColorRect.new()
		add_child(_rect_horizontal)
	if not _rect_vertical:
		_rect_vertical = ColorRect.new()
		add_child(_rect_vertical)
	
	# Set to the positions corresponding to centre_pos
	var x: float = centre_pos.x - (centre_anchor.x * rect_width_horizontal)
	var y: float = centre_pos.y - (centre_anchor.y * rect_width_vertical)
	
	_rect_horizontal.position = Vector2(0.0, y) # TODO: Anchors and offsets for rect initial positions
	_rect_horizontal.size = Vector2(0.0, rect_width_horizontal)
	_rect_horizontal.color = colour_horizontal
	
	_rect_vertical.position = Vector2(x, 0.0)
	_rect_vertical.size = Vector2(rect_width_vertical, 0.0)
	_rect_vertical.color = colour_vertical

func _ready() -> void:
	_init_rects() # TODO: Should this be here?

func _do_tween_enter(
	centre_pos_initial: Vector2,
	_centre_anchor: Vector2,
	# TODO: Different for hoz and ver
	trans: Tween.TransitionType,
	_ease: Tween.EaseType,
	duration: float,
	delay: float
) -> void:
	centre_pos = centre_pos_initial
	centre_anchor = _centre_anchor
	_init_rects()
	
	if not _tween: _tween = create_tween().set_parallel(true)
	_tween.set_trans(trans).set_ease(_ease)
	
	var screen_size: Vector2 = get_viewport_rect().size
	
	# TODO: Definitely width
	
	_tween.tween_property(
		_rect_horizontal,
		"size",
		Vector2(screen_size.x, rect_width_horizontal),
		duration
	).set_delay(delay)
	_tween.tween_property(
		_rect_vertical,
		"size",
		Vector2(rect_width_vertical, screen_size.y),
		duration
	).set_delay(delay)

func _do_tween_move(
	centre_pos_final: Vector2,
	_centre_anchor: Vector2,
	trans: Tween.TransitionType,
	_ease: Tween.EaseType,
	duration: float,
	delay: float
	# TODO: Widths
) -> void:
	if not _tween: _tween = create_tween().set_parallel(true)
	_tween.set_trans(trans).set_ease(_ease)
	
	centre_pos = centre_pos_final # TODO: Tween instead of setting final?
	
	var x: float = centre_pos_final.x - (_centre_anchor.x * rect_width_horizontal)
	var y: float = centre_pos_final.y - (_centre_anchor.y * rect_width_vertical)
	
	_tween.tween_property(
		_rect_horizontal,
		"position",
		Vector2(0.0, y),
		duration
	).set_delay(delay)
	_tween.tween_property(
		_rect_vertical,
		"position",
		Vector2(x, 0.0),
		duration
	).set_delay(delay)

# TODO: Add separate stuff for both rects, same as enter
# TODO: Offsets, etc
func _do_tween_exit(
	centre_pos_final: Vector2,
	_centre_anchor: Vector2,
	shrink_anchor: Vector2,
	trans: Tween.TransitionType,
	_ease: Tween.EaseType,
	duration: float,
	delay: float
) -> void:
	if not _tween: _tween = create_tween().set_parallel(true)
	_tween.set_trans(trans).set_ease(_ease)
	
	var screen_size: Vector2 = get_viewport_rect().size
	
	# TODO: Anchor for this shrink as a class prop
	var x: float = centre_pos_final.x - (_centre_anchor.x * rect_width_horizontal)
	var y: float = centre_pos_final.y - (_centre_anchor.y * rect_width_vertical)
	var final_pos_horizontal: Vector2 = Vector2(screen_size.x, y)
	var final_pos_vertical: Vector2 = Vector2(x, screen_size.y)
	
	_tween.tween_property(
		_rect_horizontal,
		"size",
		Vector2(0.0, rect_width_horizontal),
		duration
	).set_delay(delay)
	_tween.tween_property(
		_rect_vertical,
		"size",
		Vector2(rect_width_vertical, 0.0),
		duration
	).set_delay(delay)
	
	_tween.tween_property(
		_rect_horizontal,
		"position",
		final_pos_horizontal,
		duration
	).set_delay(delay)
	_tween.tween_property(
		_rect_vertical,
		"position",
		final_pos_vertical,
		duration
	).set_delay(delay)

func connect_to_window(window: FilmWindowBase) -> void:
	_connected_film_window = window
	
	window.tween_entered.connect(_on_window_tween_entered)

# TODO: Allow different tween easing and transitions than window
# TODO: Make all these abstract so you need to implement the animations
func _on_window_tween_entered(
	cur_pos: Vector2,
	final_pos: Vector2,
	cur_size: Vector2,
	final_size: Vector2,
	cur_shadow_margins: Vector4i,
	final_shadow_margins: Vector4i,
	size_trans: Tween.TransitionType,
	size_ease: Tween.EaseType,
	shadow_trans: Tween.TransitionType,
	shadow_ease: Tween.EaseType,
	size_duration: float,
	size_delay: float,
	shadow_duration: float,
	shadow_delay: float,
	duration: float,
	delay: float
) -> void:
	# TODO: Chain these?
	_do_tween_enter(
		cur_pos,
		centre_anchor,
		size_trans,
		size_ease,
		size_delay,
		0.0
	)
	
	_do_tween_move(
		final_pos,
		centre_anchor,
		size_trans,
		size_ease,
		size_duration,
		size_delay
	)
	
	_do_tween_exit(
		final_pos,
		centre_anchor,
		Vector2(1.0, 1.0),
		size_trans,
		size_ease,
		size_delay,
		size_delay + size_duration
	)

# TODO: Free once the window is freed

# TODO: Move tween function
# TODO: Ability to tween widths as well

# TODO: Public tween enter and exit functions
# TODO: Change width functions
# TODO: Starting point offsets?
# TODO: Some kind of rotation tweening definitely???
