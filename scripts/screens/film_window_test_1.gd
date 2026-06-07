extends Node2D

var window
var cross

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
	pass
	if not window:
			window = preload("res://scenes/ui/film_window_system/film_window.tscn") \
				.instantiate()
			window.set_position(Vector2(30.0, 30.0))
			window.set_size(Vector2(400.0, 400.0))
			
			#cross = TransitionCrosshair.new()
			#cross.connect_to_window(window)
			
			#add_child(cross)
			add_child(window)
			move_child(window, 0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		#if not window:
			#window = preload("res://scenes/ui/film_window_system/film_window.tscn") \
				#.instantiate()
			##window.set_position(Vector2(30.0, 30.0))
			##window.set_size(Vector2(400.0, 400.0))
			#
			##cross = TransitionCrosshair.new()
			##cross.connect_to_window(window)
			#
			##add_child(cross)
			#add_child(window)
			#move_child(window, 0)
			#
			#window.enter(pos_1)
		#else:
			#window.close()
		if is_pos_1:
			window.set_rect(pos_2)
			
			is_pos_1 = false
		else:
			window.set_rect(pos_1)
			
			is_pos_1 = true
