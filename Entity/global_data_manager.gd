class_name GlobalDataManager extends Node

# Scale the simulation speed
# 1.0 is maximum safe speed
var sim_speed_scale: float = 1.0

const WALKING_DISTANCE_PER_TICK_BASE: float = 16.0
const SECONDS_PER_PHYSICS_TICK_BASE: float = 1.0 / 4.5

# In our sim: 16 pixels = 1 feet
# We are using 16px x 16px tiles
# So the next point to travel is 16px (horizontal / vertical) or 22.6px (diagonal) away
# We want walking distance per tick to be less than these
var walking_distance_per_tick: float = WALKING_DISTANCE_PER_TICK_BASE * sim_speed_scale # pixels

# typical human walking speed (according to wikipedia)
# between 3.6 ft/s and 5.4 ft/s ~ 4.5 ft/s
var seconds_per_physics_tick: float = SECONDS_PER_PHYSICS_TICK_BASE * sim_speed_scale

# Simulation ends this many seconds after the final activity start time.
var max_activity_duration: float = 3600.0

# Simulated real time:
var sim_clock_s: float = 0.0
var runtime_start_s: float = 0.0 # Time when the simulation starts, e.g. 8 * 3600 = 8am
var runtime_end_s: float = 0.0 # Time when the simulation ends, e.g. 17 * 3600 = 5pm
var prev_abs_event_s: float = 0.0 # Time since last absorption event
var is_simulation_active: bool = false
var is_simulation_paused: bool = false

func current_time_s() -> float:
	return sim_clock_s

func can_advance_simulation() -> bool:
	return is_simulation_active and not is_simulation_paused

##  Poison Exchange
var prob_poison_xfer: float = 0.33
var person_to_obj_coeff: float = 0.3
var obj_to_person_coeff: float = 0.7
var max_person_gain: float = 100.0

## Poison Absorption
var abs_tick_duration_s: float = 10 * 60 # 10 m
var abs_fast_poison_threshold: float = 5
var abs_fast_rate_per_s = 6 * 60 # units / hour
var abs_slow_frac_rate_per_s: float = 0.3 * 60
var abs_obj_absorption_frac: float = 0.5

var rng = RandomNumberGenerator.new()

func exchange_poison(person: Person, object: SmartObject):
	if rng.randf() < prob_poison_xfer:
		var person_gain: float = obj_to_person_coeff
		person_gain *= 1.0 + rng.randfn() * 0.1
		person_gain = clamp(person_gain, 0.0, 1.0)
		person_gain = object.poison * person_gain
		person_gain = min(person_gain, max_person_gain)

		var object_gain: float = person.poison * person_to_obj_coeff

		var person_change: float = person_gain - object_gain
		person.poison += person_change

		var obj_absorption: float = 0.0
		if object_gain > 0.0:
			obj_absorption = object_gain * abs_obj_absorption_frac

		var object_change: float = object_gain - obj_absorption - person_gain
		object.poison += object_change
		object.absorbed_poison += obj_absorption

func absorb_poison_person(person: Person):
	var poison_absorbed: float = 0.0
	if person.poison > abs_fast_poison_threshold:
		poison_absorbed = abs_fast_rate_per_s * abs_tick_duration_s
	else:
		poison_absorbed = person.poison * abs_slow_frac_rate_per_s * abs_tick_duration_s

	## to ensure a person doesn't absorb more than they have
	poison_absorbed = min(poison_absorbed, person.poison)

	person.poison -= poison_absorbed
	person.absorbed_poison += poison_absorbed

# Only for objects in the poisoned object group
var initial_poison: float = 500.0

var all_objects: Dictionary[String, SmartObject] = {}
var all_persons: Dictionary[String, Person] = {}
var all_rooms: Dictionary[String, Room] = {}

var room_ach_budget_start: float = 100.0
var room_ach_budget_remaining: float = 100.0
var room_ach_cost_per_ach_hour: float = 5.0

var save_every_s: int = 5
var person_save_file: FileAccess
var person_output_file_path: String
var poison_save_file: FileAccess
var poison_output_file_path: String
var room_save_file: FileAccess
var room_output_file_path: String

func apply_sim_speed_scale(scale: float) -> void:
	sim_speed_scale = scale
	walking_distance_per_tick = WALKING_DISTANCE_PER_TICK_BASE * sim_speed_scale
	seconds_per_physics_tick = SECONDS_PER_PHYSICS_TICK_BASE * sim_speed_scale
