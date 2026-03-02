class_name EntityBase

# TODO: Skills with const classes with info

var _max_hp: int
func get_max_hp() -> int: return _max_hp
func set_max_hp(val: int) -> void: _max_hp = val

var _cur_hp: int
func get_cur_hp() -> int: return _cur_hp
func set_cur_hp(val: int) -> void: _cur_hp = val

var _max_mp: int
func get_max_mp() -> int: return _max_mp
func set_max_mp(val: int) -> void: _max_mp = val

var _cur_mp: int
func get_cur_mp() -> int: return _cur_mp
func set_cur_mp(val: int) -> void: _cur_mp = val
