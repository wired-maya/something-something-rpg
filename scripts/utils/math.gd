class_name Math

# Convert a float representing animation progress from linear into cosine for animations
# Input is range is meant to be [0.0, 1.0], however since the cosine function returns a range
# in  [0.0, 1.0], clamping is not necessary
static func get_cos_progress(x: float) -> float:
	return -0.5 * cos(PI * x) + 0.5
