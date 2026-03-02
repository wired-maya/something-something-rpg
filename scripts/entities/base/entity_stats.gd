class_name EntityStats

# Entity stats holds the state of each stat, as well as handling damage calculations
# It does not store current HP/MP, buffs, skills, or anything variable

# TODO: Is there a way to make this a struct for better memory usage? Can I use 8 bit integers?
# TODO: Can I use Rust to create more optimized types? Explore for more complex games

#region Constants

# Enum for selecting which stat to obtain for display
# All calculations are handled in EntityStats so these are the only exposed stats
enum Stat {
	LEVEL,
	HP,
	MP,
	
	VITALITY,
	RESISTANCE,
	STRENGTH,
	INTELLIGENCE,
	MAGIC,
	SPEED,
	LUCK
}

const _stat_num: int = 7

const _level_damage_coefficient: float = 3.0
const _affinity_offset_coefficient: float = 0.05

const _phys_dmg_bonus_base_min: float = 0.85
const _phys_dmg_bonus_base_max: float = 1.15
const _phys_dmg_bonus_coefficient: float = 0.015 # Luck is multiplied by this

const _phys_str_coefficient: float = 7.0
const _phys_spd_coefficient: float = 4.5

const _mag_dmg_bonus_base_min: float = 0.9
const _mag_dmg_bonus_base_max: float = 1.1
const _mag_dmg_bonus_coefficient: float = 0.01 # Luck is multiplied by this

const _mag_mag_coefficient: float = 7.3
const _mag_int_coefficient: float = 4.65

#endregion

#region All Stats

# By default calculated based on stats
var _level: int
var _hp: int
var _mp: int

# [0.0, 1.0], 1.0 - res used as coefficient
# Calculated by default
const _res_cap: float = 0.65
var _phys_res: float
var _mag_res: float

# Do not calculate respective stat if it is overriden
var _level_overriden: bool = false
var _hp_overriden: bool = false
var _mp_overriden: bool = false
var _phys_res_overriden: bool = false
var _mag_res_overriden: bool = false

# These are added to calculated stats
var _base_level: int
var _base_hp: int
var _base_mp: int
var _base_phys_res: float
var _base_mag_res: float

# All skill types are assumed as normal resistance unless in this dictionary
var _type_res: Dictionary[Skill.Type, Skill.Resistance]

# All type affinities are assumed 0 unless here, they should have the range [-5, 5]
# Affinity affects skill MP cost by reducing affinity * 10 percent, e.g. affinity 2 has 80% MP cost
# Affinity affects random damage bonus max by affinity * 0.05, e.g. affinity 2 has max bonus 1.2x
var _type_affinity: Dictionary[Skill.Type, int]

# In the form of damage taken away from damage taken
var _phys_armour: int
var _mag_armour: int

# Entity's stats that everything is calculated from
var _vitality: int # Improves HP and physical damage resistance
var _resistance: int # Improves physical and magical damage resistance
var _strength: int # Improves physical damage
var _intelligence: int # Improves magic damage and magic resistance
var _magic: int # Improves magic damage and MP
var _speed: int # Improves hit/miss chance for attacks and physical damage
var _luck: int # Improves hit/miss chance for status effects as well as the random damage added to attacks

#endregion

func _init(
	# Stats that the other stats are calculated based off of, unless overriden
	# Must be > 0, otherwise set to 1
	vitality: int = 1,
	resistance: int = 1,
	strength: int = 1,
	intelligence: int = 1,
	magic: int = 1,
	speed: int = 1,
	luck: int = 1,
	
	type_resistances: Dictionary[Skill.Type, Skill.Resistance] = { },
	type_affinities: Dictionary[Skill.Type, int] = { },
	
	# Added to respective stats after calculation
	base_level: int = 0,
	base_hp: int = 0,
	base_mp: int = 0,
	base_phys_res: float = 0.0,
	base_mag_res: float = 0.0,
	
	# Armour is not calculated and must be set manually
	phys_armour: int = 0,
	mag_armour: int = 0,
	
	# Override if > -1, overriden stats are no longer calculated
	level: int = -1,
	hp: int = -1,
	mp: int = -1,
	phys_res: float = -1.0,
	mag_res: float = -1.0
) -> void:	
	_type_res = type_resistances
	_type_affinity = type_affinities
	
	_base_level = base_level
	_base_hp = base_hp
	_base_mp = base_mp
	_base_phys_res = base_phys_res
	_base_mag_res = base_mag_res
	
	_phys_armour = phys_armour
	_mag_armour = mag_armour
	
	if level > -1:
		_level = level
		_level_overriden = true
	
	if hp > -1:
		_hp = hp
		_hp_overriden = true
		
	if mp > -1:
		_mp = mp
		_mp_overriden = true
	
	if phys_res > -1:
		_phys_res = phys_res
		_phys_res_overriden = true
	
	if mag_res > -1:
		_mag_res = mag_res
		_mag_res_overriden = true
	
	set_stats(
		vitality,
		resistance,
		strength,
		intelligence,
		magic,
		speed,
		luck
	)

#region Getters and Setters

# Returns all stats as a dictionary with the Stat enum as keys
func get_stats() -> Dictionary[Stat, int]:
	return {
		Stat.LEVEL: _level,
		Stat.HP: _hp,
		Stat.MP: _mp,
		Stat.VITALITY: _vitality,
		Stat.RESISTANCE: _resistance,
		Stat.STRENGTH: _strength,
		Stat.INTELLIGENCE: _intelligence,
		Stat.MAGIC: _magic,
		Stat.SPEED: _speed,
		Stat.LUCK: _luck
	}

# Fetch a single stat using an enum without having to allocate a dictionary for one stat
func get_stat(stat: Stat) -> int:
	match stat:
		Stat.LEVEL: return _level
		Stat.HP: return _hp
		Stat.MP: return _mp
		Stat.VITALITY: return _vitality
		Stat.RESISTANCE: return _resistance
		Stat.STRENGTH: return _strength
		Stat.INTELLIGENCE: return _intelligence
		Stat.MAGIC: return _magic
		Stat.SPEED: return _speed
		Stat.LUCK: return _luck
		_: return -1

# Set all calculable stats
func set_stats(
	# Stats that the other stats are calculated based off of, unless overriden
	# Must be > 0, otherwise set to 1
	vitality: int = 1,
	resistance: int = 1,
	strength: int = 1,
	intelligence: int = 1,
	magic: int = 1,
	speed: int = 1,
	luck: int = 1,
) -> void:
	_vitality = max(vitality, 0)
	_resistance = max(resistance, 0)
	_strength = max(strength, 0)
	_intelligence = max(intelligence, 0)
	_magic = max(magic, 0)
	_speed = max(speed, 0)
	_luck = max(luck, 0)
	
	calc_stats()

# Set individual stats, if you set LEVEL, HP, or MP then they will be overriden and no longer calculated
func set_stat(stat: Stat, val: int) -> void:
	match stat:
		Stat.LEVEL:
			_level = val
			_level_overriden = true
		Stat.HP:
			_hp = val
			_hp_overriden = true
		Stat.MP:
			_mp = val
			_mp_overriden = true
		
		Stat.VITALITY: _vitality = val
		Stat.RESISTANCE: _resistance = val
		Stat.STRENGTH: _strength = val
		Stat.INTELLIGENCE: _intelligence = val
		Stat.MAGIC: _magic = val
		Stat.SPEED: _speed = val
		Stat.LUCK: _luck = val
	
	calc_stats()

# Adds 1 to given stat, same rules as set_stat apply
func bump_stat(stat: Stat) -> void:
	set_stat(stat, get_stat(stat) + 1)

# Check resistances without exposing dictionary
# Defaults to NORMAL if not present
func get_resistance(type: Skill.Type) -> Skill.Resistance:
	return _type_res.get(type, Skill.Resistance.NORMAL)

# Don't expose the dictionary itself
func set_resistance(type: Skill.Type, res: Skill.Resistance) -> void:
	_type_res.set(type, res)

# TODO: Affinity

func get_affinity(type: Skill.Type) -> int:
	return _type_affinity.get(type, 0)

func set_affinity(type: Skill.Type, val: int) -> void:
	_type_affinity.set(type, val)

#endregion

#region Calculations

# Sum of each non-calculated stat + base level - number of stat types + 1
func _calc_level() -> void:
	_level = _vitality + \
		_resistance + \
		_strength + \
		_intelligence + \
		_magic + \
		_speed + \
		_luck + \
		_base_level - \
		_stat_num + \
		1

# (lvl * 10) + (vit * (vit / 2)) + vit + bhp
func _calc_hp() -> void:
	var level_hp: int = _level * 10
	var vitality_hp: int = (_vitality * (_vitality / 2)) + _vitality
	_hp = level_hp + vitality_hp + _base_hp

# (lvl * 3) + (mag * 7) + bmp
func _calc_mp() -> void:
	var level_mp: int = _level * 3
	var magic_mp: int = _magic * 7
	_mp = level_mp + magic_mp + _base_mp 

# min((vit * 0.003) + (res * 0.008), rcap)
func _calc_phys_res() -> void:
	var vitality_res: float = _vitality * 0.003
	var resistance_res: float = _resistance * 0.008
	_phys_res = min(_res_cap, vitality_res + resistance_res)

# min((vit * 0.0035) + (res * 0.0075), rcap)
func _calc_mag_res() -> void:
	var intelligence_res: float = _intelligence * 0.0035
	var resistance_res: float = _resistance * 0.0075
	_mag_res = min(_res_cap, intelligence_res + resistance_res)

# Calculate all stats that are not overriden
func calc_stats() -> void:
	if not _level_overriden: _calc_level()
	if not _hp_overriden: _calc_hp()
	if not _mp_overriden: _calc_mp()
	if not _phys_res_overriden: _calc_phys_res()
	if not _mag_res_overriden: _calc_mag_res()

# Intermediate values are calculated as floats, then rounded to an integer before returning
func calc_outgoing_damage_phys(type: Skill.Type, tier: Skill.Tier) -> int:
	var level_dmg: float = float(_level) * _level_damage_coefficient # TODO: Remove?
	
	var strength_dmg: float = float(_strength) * _phys_str_coefficient
	var speed_dmg: float = float(_speed) * _phys_spd_coefficient
	
	# Affinity affects random damage bonus max by affinity * 0.05, e.g. affinity 2 has max bonus of base plus 0.1
	# If negative the minimum bonus is decreased
	var affinity_offset: float = float(get_affinity(type)) * _affinity_offset_coefficient
	var rand_range_top: float = _phys_dmg_bonus_base_max
	var rand_range_bottom: float = _phys_dmg_bonus_base_min
	
	if affinity_offset > 0.0: rand_range_top += affinity_offset
	elif affinity_offset < 0.0: rand_range_bottom += affinity_offset
	
	var luck_dmg_bonus: float = float(_luck) * _phys_dmg_bonus_coefficient
	rand_range_bottom = min(rand_range_bottom + luck_dmg_bonus, rand_range_top)
	
	var dmg_bonus_coefficient: float = randf_range(rand_range_bottom, rand_range_top)
	
	# Converts tier value from int percentage to float coefficient, with the value stored in the enum
	var tier_coefficient: float = float(tier) / 100.0
	
	var base_damage: float = (level_dmg + strength_dmg + speed_dmg) * tier_coefficient
	var final_damage: float = roundf(base_damage * dmg_bonus_coefficient)
	
	return int(final_damage)

# Intermediate values are calculated as floats, then rounded to an integer before returning
func calc_outgoing_damage_mag(type: Skill.Type, tier: Skill.Tier) -> int:
	var level_dmg: float = float(_level) * _level_damage_coefficient # TODO: Remove?
	
	var magic_dmg: float = float(_magic) * _mag_mag_coefficient
	var int_dmg: float = float(_intelligence) * _mag_int_coefficient
	
	# Affinity affects random damage bonus max by affinity * 0.05, e.g. affinity 2 has max bonus of base plus 0.1
	# If negative the minimum bonus is decreased
	var affinity_offset: float = float(get_affinity(type)) * _affinity_offset_coefficient
	var rand_range_top: float = _mag_dmg_bonus_base_max
	var rand_range_bottom: float = _mag_dmg_bonus_base_min
	
	if affinity_offset > 0.0: rand_range_top += affinity_offset
	elif affinity_offset < 0.0: rand_range_bottom += affinity_offset
	
	var luck_dmg_bonus: float = float(_luck) * _mag_dmg_bonus_coefficient
	rand_range_bottom = min(rand_range_bottom + luck_dmg_bonus, rand_range_top)
	
	var dmg_bonus_coefficient: float = randf_range(rand_range_bottom, rand_range_top)
	
	# Converts tier value from int percentage to float coefficient, with the value stored in the enum
	var tier_coefficient: float = float(tier) / 100.0
	
	var base_damage: float = (level_dmg + magic_dmg + int_dmg) * tier_coefficient
	var final_damage: float = roundf(base_damage * dmg_bonus_coefficient)
	
	return int(final_damage)

func calc_outgoing_damage(type: Skill.Type, tier: Skill.Tier) -> int:
	if Skill.TypeBaseType[type] == Skill.BaseType.PHYSICAL: return calc_outgoing_damage_phys(type, tier)
	elif Skill.TypeBaseType[type] == Skill.BaseType.MAGIC: return calc_outgoing_damage_mag(type, tier)
	else: return 0 # Forgot to add type to TypeBaseType dictionary!

# Apply resistances and armour to incoming damage
func calc_incoming_damage_phys(type: Skill.Type, damage: int) -> int:
	var type_res_coefficient: float = float(get_resistance(type)) / 100.0
	var res_coefficient: float = 1.0 - _phys_res
	
	var base_damage: float = float(damage) * type_res_coefficient
	var final_damage: float = roundf(base_damage * res_coefficient) - float(_phys_armour)
	
	return int(final_damage)

func calc_incoming_damage_mag(type: Skill.Type, damage: int) -> int:
	var type_res_coefficient: float = float(get_resistance(type)) / 100.0
	var res_coefficient: float = 1.0 - _mag_res
	
	var base_damage: float = float(damage) * type_res_coefficient
	var final_damage: float = roundf(base_damage * res_coefficient) - float(_mag_armour)
	
	return int(final_damage)

func calc_incoming_damage(type: Skill.Type, damage: int) -> int:
	if Skill.TypeBaseType[type] == Skill.BaseType.PHYSICAL: return calc_incoming_damage_phys(type, damage)
	elif Skill.TypeBaseType[type] == Skill.BaseType.MAGIC: return calc_incoming_damage_mag(type, damage)
	else: return 0 # Forgot to add type to TypeBaseType dictionary!

# TODO: Calculate if misses based on speed and possibly affinities/resistances
# TODO: Calculate with stat buff offsets

#endregion
