class_name Skill

# For quickly determining which calculation function to use
const TypeBaseType: Dictionary[Type, BaseType] = {
	Type.STAB: BaseType.PHYSICAL,
	Type.SLICE: BaseType.PHYSICAL,
	Type.BASH: BaseType.PHYSICAL,
	
	Type.ELEC: BaseType.MAGIC,
	Type.FIRE: BaseType.MAGIC,
	Type.FORCE: BaseType.MAGIC
}

enum Type {
	# Phys
	STAB,
	SLICE,
	BASH,
	
	# Mag
	ELEC,
	FIRE,
	FORCE
}

enum BaseType {
	PHYSICAL,
	MAGIC
}

# Values are in percentage, (Tier / 100) used as a coefficient in damage calculations
enum Tier {
	WEAK = 80,
	MEDIUM = 100,
	STRONG = 120,
	EXTREME = 150
}

# Values are in percentage, (Resistance / 100) used as a coefficient in damage calculations
enum Resistance {
	WEAK = 130,
	NORMAL = 100,
	RESIST = 70,
	NULL = 0,
	ABSORB = -100
}
