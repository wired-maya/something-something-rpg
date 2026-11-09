extends Node2D

var window

var is_pos_1: bool = true
var pos_1: Rect2 = Rect2(
	Vector2(30.0, 30.0),
	Vector2(400.0, 400.0)
)
var pos_2: Rect2 = Rect2(
	Vector2(50.0, 50.0),
	Vector2(200.0, 600.0)
)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass
	if not window:
		is_pos_1 = true
		window = FilmWindow.new()
		window.set_position(Vector2(30.0, 30.0))
		window.set_size(Vector2(400.0, 400.0))
		
		#cross = TransitionCrosshair.new()
		#cross.connect_to_window(window)
		
		#add_child(cross)
		add_child(window)
		move_child(window, 0)

func _unhandled_input(event: InputEvent) -> void:
	#pass
	if event.is_action_pressed("ui_accept"):
		if not window:
			is_pos_1 = true
			window = FilmWindow.new()
			window.set_position(Vector2(30.0, 30.0))
			window.set_size(Vector2(400.0, 400.0))
			
			#cross = TransitionCrosshair.new()
			#cross.connect_to_window(window)
			
			#add_child(cross)
			add_child(window)
			move_child(window, 0)
		elif is_pos_1:
			window.set_rect(pos_2, func(): pass)
			
			is_pos_1 = false
		else:
			window.set_rect(pos_1, func(): pass)
			
			is_pos_1 = true
	elif event.is_action_pressed("ui_cancel"):
		if window:
			window.close()
