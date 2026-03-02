extends Area3D

@export var move_speed: float = 5.0 # m/s
@export var rot_speed: float = 4.5

var _rot_progress: float = 1.0
var _move_progress: float = 1.0

@onready var _next_basis: Basis = basis
var _prev_basis: Basis

@onready var _next_pos: Vector3 = position
var _prev_pos: Vector3

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	_input_move("move_forward", Vector3.FORWARD)
	
	if Input.is_action_pressed("move_modifier"):
		_input_move("turn_left", Vector3.LEFT)
		_input_move("turn_right", Vector3.RIGHT)
		_input_move("turn_back", Vector3.BACK)
	else:
		_input_rotate("turn_left", PI / 2)
		_input_rotate("turn_right", -PI / 2)
		_input_rotate("turn_back", PI)
	
	_do_move(delta)
	_do_rotate(delta)

# Allows buffering inputs by rotating _next_basis again and allows holding key
func _input_rotate(action: String, angle: float) -> void:
	if Input.is_action_just_pressed(action) \
	or Input.is_action_pressed(action) && _rot_progress >= 1.0:
		_rot_progress = 0.0
		_next_basis = _next_basis.rotated(Vector3.UP, angle)
		_prev_basis = basis
		#print("Rotation: " + action)

func _do_rotate(delta: float) -> void:
	if _rot_progress < 1.0: # If statement prevents unnecessary calculations
		_rot_progress = min(_rot_progress + (delta * rot_speed), 1.0)
		
		var cos_pos = Math.get_cos_progress(_rot_progress)
		basis = _prev_basis.slerp(_next_basis, cos_pos)

func _input_move(action: String, offset: Vector3) -> void:
	if _move_progress >= 1.0: # Makes sure movement is on a grid
		if Input.is_action_just_pressed(action) \
		or Input.is_action_pressed(action):
			_move_progress = 0.0
			_next_pos = _next_pos + offset.rotated(Vector3.UP, _next_basis.get_euler().y)
			_prev_pos = position
			#print("Move: " + action)

func _do_move(delta: float) -> void:
	if _move_progress < 1.0:
		_move_progress = min(_move_progress + (delta * move_speed), 1.0)
		
		var cos_pos = Math.get_cos_progress(_move_progress)
		position = _prev_pos.lerp(_next_pos, cos_pos)


func _on_body_entered(body: Node3D) -> void:
	print("Head bumpy, owies!!")
	
	var temp_pos = _prev_pos
	_prev_pos = _next_pos
	_next_pos = temp_pos
	
	_move_progress = 1.0 - _move_progress
