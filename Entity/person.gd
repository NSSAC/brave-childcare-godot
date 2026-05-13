class_name Person
extends CharacterBody2D

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var label: Label = $Label
@onready var halo: AnimatedSprite2D = $Halo

const LABEL_VERTICAL_OFFSET: float = 0.0

var pid: String = ""
var role: String = ""
var disease_state: String = "S"  # SEIR state: S=Susceptible, E=Exposed, I=Infected, R=Recovered
var current_obj: SmartObject
var current_aid: String
var current_activity_name: String = ""

var activity_aid: Array[String] = []
var activity_oid: Array[String] = []
var activity_name: Array[String] = []
var activity_time: Array[float] = []
var activity_idx: int = 0

var logged_start_for_activity: bool = false

const OBJECT_TYPE_TO_MICROACTIVITY: Dictionary = {
	"play_structure": "play",
	"play_toys": "play",
	"cafeteria_table": "sit_in_small_circle",
	"carpet": "sit_in_big_circle"
}

const ROLE_OBJECT_TO_MICROACTIVITY: Dictionary = {
	"providers": {
		"cubicle": "caregiver_rounds",
		"nap_pads": "caregiver_rounds",
		"carpet": "small_wander"
	},
	"floaters": {
		"cubicle": "caregiver_rounds",
		"nap_pads": "caregiver_rounds",
		"carpet": "small_wander"
	},
}

const BED_OBJECT_TYPES: Dictionary = {
	"cubicle": true,
	"nap_pads": true,
}

const CAREGIVER_ROLES: Dictionary = {
	"providers": true,
	"floaters": true,
}

@export var microactivity_random_wander: Dictionary = {
	"radius_px": 140.0,
	"min_step_px": 12.0,
	"interval_s": 75.0,
	"jitter_s": 15.0
}

@export var microactivity_small_wander: Dictionary = {
	"radius_px": 10.0,
	"min_step_px": 8.0,
	"interval_s": 120.0,
	"jitter_s": 20.0
}

@export var microactivity_play: Dictionary = {
	"radius_px": 220.0,
	"min_step_px": 24.0,
	"interval_s": 55.0,
	"jitter_s": 20.0
}

@export var microactivity_sit_in_small_circle: Dictionary = {
	"radius_px": 90.0,
	"min_separation_px": 22.0,
	"sample_attempts": 14
}

@export var microactivity_sit_in_big_circle: Dictionary = {
	"radius_px": 180.0,
	"min_separation_px": 22.0,
	"sample_attempts": 14
}

@export var microactivity_caregiver_rounds: Dictionary = {
	"max_search_radius_px": 900.0,
	"arrival_distance_px": 22.0,
	"linger_min_s": 90.0,
	"linger_max_s": 150.0,
	"handoff_pause_s": 8.0,
	"retry_interval_s": 20.0,
}



var current_microactivity: String = ""
var microactivity_anchor: Vector2 = Vector2.ZERO
var microactivity_next_time_s: float = 0.0
var sit_target_position: Vector2 = Vector2.ZERO
var caregiver_target_person: Person = null
var caregiver_linger_until_s: float = -1.0
var caregiver_visited_pids: Dictionary = {}
var rng := RandomNumberGenerator.new()

var output_event: Array[String] = []
var output_aid: Array[String] = []
var output_time: Array[float] = []
var output_pos_x: Array[float] = []
var output_pos_y: Array[float] = []

var poison: float = 0.0
var absorbed_poison: float = 0.0

var output_absorption_time: Array[float] = []
var output_poison: Array[float] = []
var output_absorbed_poison: Array[float] = []

var cumulative_viral_exposure: float = 0.0
var exposure_sample_count: int = 0
var last_exposure_sample_time: float = 0.0
var current_room: Area2D = null

const EXPOSURE_SAMPLE_INTERVAL_S: float = 60.0
func save_events():
	var n = len(output_event)
	for i in range(n):
		var obj = {
			"pid": pid,
			"event": output_event[i],
			"aid": output_aid[i],
			"time": output_time[i],
			"pos_x": output_pos_x[i],
			"pos_y": output_pos_y[i],
		}
		var obj_str = JSON.stringify(obj)
		Global.person_save_file.store_line(obj_str)

	output_event.clear()
	output_aid.clear()
	output_time.clear()
	output_pos_x.clear()
	output_pos_y.clear()

	n = len(output_absorption_time)
	for i in range(n):
		var obj = {
			"pid": pid,
			"event": "person_absorption",
			"time": output_absorption_time[i],
			"poison": output_poison[i],
			"absorbed_poison": output_absorbed_poison[i],
		}
		var obj_str = JSON.stringify(obj)
		Global.poison_save_file.store_line(obj_str)

	output_absorption_time.clear()
	output_poison.clear()
	output_absorbed_poison.clear()

func _ready() -> void:
	rng.randomize()
	label.position.y += LABEL_VERTICAL_OFFSET

	# People dont react to collisions
	# Objects react when people collide with them
	collision_layer = 0b01 # is on layer two
	collision_mask = 0

	navigation_agent_2d.navigation_finished.connect(_on_navigation_agent_2d_navigation_finished)

	# Make sure to not await during _ready.
	do_first_behavior.call_deferred()

func _process(_delta: float) -> void:
	if Global.is_simulation_paused:
		return

	label.text = disease_state.strip_edges().to_upper()
	_apply_disease_halo()

	do_behavior()
	_update_independent_behavior(Global.current_time_s())

func _apply_disease_halo() -> void:
	var disease := disease_state.strip_edges().to_upper()

	match disease:
		"S":
			halo.play("clear")
			halo.modulate = Color(1.0, 1.0, 1.0, 1.0)
		"E":
			# Use yellow halo texture and tint to orange.
			halo.play("yellow")
			halo.modulate = Color(1.0, 0.60, 0.20, 1.0)
		"I":
			halo.play("red")
			halo.modulate = Color(1.0, 1.0, 1.0, 1.0)
		"R":
			# Use yellow halo texture and tint to gray.
			halo.play("yellow")
			halo.modulate = Color(0.55, 0.55, 0.55, 1.0)
		_:
			halo.play("clear")
			halo.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _physics_process(_delta: float) -> void:
	if Global.is_simulation_paused:
		return

	sample_viral_exposure()

	# If navigation has finished continue
	if navigation_agent_2d.is_navigation_finished():
		return

	var current_position: Vector2 = global_position
	var next_position: Vector2 = navigation_agent_2d.get_next_path_position()

	if current_position.distance_to(next_position) > 128:
		# We are using a link; teleport
		global_position = next_position
	elif Global.walking_distance_per_tick > current_position.distance_to(next_position):
		global_position = next_position
	else:
		var diff: Vector2 = current_position.direction_to(next_position) * Global.walking_distance_per_tick
		global_position += diff

func _on_navigation_agent_2d_navigation_finished() -> void:
	if navigation_agent_2d.is_navigation_finished() and not logged_start_for_activity:
		output_event.append("start")
		output_aid.append(current_aid)
		output_time.append(Global.current_time_s())
		output_pos_x.append(global_position[0])
		output_pos_y.append(global_position[1])
		logged_start_for_activity = true

func do_first_behavior():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	do_behavior()

func do_behavior():
	# Check if I have any activities left
	if activity_idx < activity_aid.size():

		# Check if I should start the activity
		var a_time: float = activity_time[activity_idx]
		var c_time: float = Global.current_time_s()
		if c_time >= a_time:
			# Start walking towards the relevant object
			current_aid = activity_aid[activity_idx]
			current_activity_name = activity_name[activity_idx] if activity_idx < activity_name.size() else ""
			var a_oid: String = activity_oid[activity_idx]
			if not Global.all_objects.has(a_oid):
				print("Skipping activity due to missing object OID: ", a_oid, " pid=", pid, " aid=", current_aid)
				activity_idx += 1
				return

			var a_obj: SmartObject = Global.all_objects[a_oid]
			current_obj = a_obj
			microactivity_anchor = current_obj.global_position
			_start_microactivity_for_current_object(c_time)
			logged_start_for_activity = false

			# First time we arrive
			# Make ourselves visible
			# Start at the object
			if not visible:
				global_position = current_obj.global_position
				show()
			navigation_agent_2d.target_position = current_obj.global_position

			output_event.append("walking_start")
			output_aid.append(current_aid)
			output_time.append(c_time)
			output_pos_x.append(global_position[0])
			output_pos_y.append(global_position[1])

			activity_idx += 1

func _normalize_string(value: Variant) -> String:
	return str(value).strip_edges().to_lower()

func _resolve_microactivity_for_current_object() -> String:
	if current_obj == null:
		return ""

	var role_key := _normalize_string(role)
	var object_type := _normalize_string(current_obj.type)

	if ROLE_OBJECT_TO_MICROACTIVITY.has(role_key):
		var role_map: Dictionary = ROLE_OBJECT_TO_MICROACTIVITY[role_key]
		if role_map.has(object_type):
			return str(role_map[object_type])

	if OBJECT_TYPE_TO_MICROACTIVITY.has(object_type):
		return str(OBJECT_TYPE_TO_MICROACTIVITY[object_type])

	return ""

func _start_microactivity_for_current_object(current_time_s: float) -> void:
	current_microactivity = _resolve_microactivity_for_current_object()
	microactivity_next_time_s = current_time_s
	sit_target_position = Vector2.ZERO
	caregiver_target_person = null
	caregiver_linger_until_s = -1.0
	caregiver_visited_pids.clear()

func _update_independent_behavior(current_time_s: float) -> void:
	if not Global.enable_microactivities:
		return

	if not visible:
		return

	if current_obj == null:
		return

	if current_microactivity == "":
		return

	match current_microactivity:
		"random_wander":
			_update_wander_like_behavior(current_time_s, microactivity_random_wander)
		"small_wander":
			_update_wander_like_behavior(current_time_s, microactivity_small_wander)
		"play":
			_update_wander_like_behavior(current_time_s, microactivity_play)
		"sit_in_circle":
			_update_sit_in_circle_behavior(current_time_s, microactivity_sit_in_big_circle)
		"sit_in_small_circle":
			_update_sit_in_circle_behavior(current_time_s, microactivity_sit_in_small_circle)
		"sit_in_big_circle":
			_update_sit_in_circle_behavior(current_time_s, microactivity_sit_in_big_circle)
		"caregiver_rounds":
			_update_caregiver_rounds_behavior(current_time_s, microactivity_caregiver_rounds)
		_:
			pass

func _is_caregiver_role(role_name: String) -> bool:
	return CAREGIVER_ROLES.has(_normalize_string(role_name))

func _is_child_role(role_name: String) -> bool:
	return not _is_caregiver_role(role_name)

func _is_bed_object_type(object_type_name: String) -> bool:
	return BED_OBJECT_TYPES.has(_normalize_string(object_type_name))

func _find_nearest_child_for_caregiver(max_search_radius: float, exclude_visited: bool) -> Person:
	var nearest: Person = null
	var nearest_dist := INF

	for other in Global.all_persons.values():
		if other == self:
			continue
		if not other is Person:
			continue

		var child: Person = other
		if not child.visible:
			continue
		if not _is_child_role(child.role):
			continue
		if child.current_obj == null:
			continue
		if not _is_bed_object_type(str(child.current_obj.type)):
			continue
		if exclude_visited and caregiver_visited_pids.has(str(child.pid)):
			continue

		var dist := global_position.distance_to(child.global_position)
		if dist > max_search_radius:
			continue
		if dist < nearest_dist:
			nearest = child
			nearest_dist = dist

	return nearest

func _update_caregiver_rounds_behavior(current_time_s: float, profile: Dictionary) -> void:
	if not _is_caregiver_role(role):
		return

	if not navigation_agent_2d.is_navigation_finished():
		return

	var handoff_pause_s: float = max(0.0, float(profile.get("handoff_pause_s", 8.0)))
	var retry_interval_s: float = max(0.1, float(profile.get("retry_interval_s", 20.0)))
	var max_search_radius: float = max(32.0, float(profile.get("max_search_radius_px", 900.0)))

	if caregiver_target_person != null:
		if caregiver_linger_until_s < 0.0:
			var linger_min_s: float = max(0.0, float(profile.get("linger_min_s", 90.0)))
			var linger_max_s: float = max(linger_min_s, float(profile.get("linger_max_s", 150.0)))
			caregiver_linger_until_s = current_time_s + rng.randf_range(linger_min_s, linger_max_s)

		if current_time_s < caregiver_linger_until_s:
			return

		caregiver_visited_pids[str(caregiver_target_person.pid)] = true
		caregiver_target_person = null
		caregiver_linger_until_s = -1.0
		microactivity_next_time_s = current_time_s + handoff_pause_s
		return

	if current_time_s < microactivity_next_time_s:
		return

	var next_child := _find_nearest_child_for_caregiver(max_search_radius, true)
	if next_child == null:
		caregiver_visited_pids.clear()
		next_child = _find_nearest_child_for_caregiver(max_search_radius, false)

	if next_child == null:
		microactivity_next_time_s = current_time_s + retry_interval_s
		return

	caregiver_target_person = next_child
	navigation_agent_2d.target_position = next_child.global_position

func _update_wander_like_behavior(current_time_s: float, profile: Dictionary) -> void:
	# Only pick a new target once we've reached the prior one.
	if not navigation_agent_2d.is_navigation_finished():
		return

	if current_time_s < microactivity_next_time_s:
		return

	var min_step: float = float(profile.get("min_step_px", 8.0))
	var radius: float = float(profile.get("radius_px", max(8.0, min_step)))
	if radius <= 0.0:
		return
	min_step = clamp(min_step, 0.0, radius)

	var angle := rng.randf_range(0.0, TAU)
	var distance: float = rng.randf_range(min_step, radius)
	var offset: Vector2 = Vector2.RIGHT.rotated(angle) * distance
	var anchor: Vector2 = microactivity_anchor if microactivity_anchor != Vector2.ZERO else current_obj.global_position
	navigation_agent_2d.target_position = anchor + offset

	var interval: float = max(0.1, float(profile.get("interval_s", 60.0)))
	var jitter: float = max(0.0, float(profile.get("jitter_s", 0.0)))
	microactivity_next_time_s = current_time_s + interval + rng.randf_range(0.0, jitter)

func _update_sit_in_circle_behavior(_current_time_s: float, profile: Dictionary) -> void:
	# Let arrival complete before picking an in-circle seat target.
	if not navigation_agent_2d.is_navigation_finished():
		return

	if sit_target_position != Vector2.ZERO:
		return

	var radius: float = max(0.0, float(profile.get("radius_px", 90.0)))
	var min_separation: float = max(0.0, float(profile.get("min_separation_px", 22.0)))
	var attempts: int = maxi(1, int(profile.get("sample_attempts", 12)))
	var anchor: Vector2 = microactivity_anchor if microactivity_anchor != Vector2.ZERO else current_obj.global_position
	sit_target_position = _pick_seat_target(anchor, radius, min_separation, attempts)
	navigation_agent_2d.target_position = sit_target_position

func _preferred_circle_angle(anchor: Vector2, radius: float) -> Variant:
	var angles: Array = []
	var include_radius: float = max(radius * 1.6, 32.0)

	for other in Global.all_persons.values():
		if other == self:
			continue
		if not other is Person:
			continue

		var other_person: Person = other
		if not other_person.visible:
			continue
		if other_person.current_obj != current_obj:
			continue

		var other_pos: Vector2 = other_person.global_position
		if other_person.sit_target_position != Vector2.ZERO:
			other_pos = other_person.sit_target_position

		var delta: Vector2 = other_pos - anchor
		var dist: float = delta.length()
		if dist < 4.0 or dist > include_radius:
			continue

		angles.append(delta.angle())

	if angles.is_empty():
		return null

	angles.sort()

	# One seated peer -> opposite side to quickly establish a circle.
	if angles.size() == 1:
		return wrapf(float(angles[0]) + PI, 0.0, TAU)

	# More peers -> choose midpoint of the largest angular gap.
	var best_start: float = float(angles[0])
	var best_gap: float = -1.0
	for idx in range(angles.size()):
		var a0: float = float(angles[idx])
		var a1: float = float(angles[(idx + 1) % angles.size()])
		if idx == angles.size() - 1:
			a1 += TAU
		var gap: float = a1 - a0
		if gap > best_gap:
			best_gap = gap
			best_start = a0

	return wrapf(best_start + best_gap * 0.5, 0.0, TAU)

func _pick_seat_target(anchor: Vector2, radius: float, min_separation: float, attempts: int) -> Vector2:
	var best_candidate := anchor
	var best_clearance := -1.0

	var preferred_angle_variant: Variant = _preferred_circle_angle(anchor, radius)
	if preferred_angle_variant != null:
		var preferred_angle: float = float(preferred_angle_variant)
		var focused_attempts: int = mini(attempts, 4)
		for _idx in range(focused_attempts):
			var angle_jitter: float = rng.randf_range(-0.25, 0.25)
			var distance: float = rng.randf_range(radius * 0.72, radius)
			var candidate := anchor + (Vector2.RIGHT.rotated(preferred_angle + angle_jitter) * distance)
			var clearance := _seat_clearance(candidate)
			if clearance >= min_separation:
				return candidate
			if clearance > best_clearance:
				best_clearance = clearance
				best_candidate = candidate

	for _idx in range(attempts):
		var angle := rng.randf_range(0.0, TAU)
		var distance := rng.randf_range(0.0, radius)
		var candidate := anchor + (Vector2.RIGHT.rotated(angle) * distance)
		var clearance := _seat_clearance(candidate)
		if clearance >= min_separation:
			return candidate
		if clearance > best_clearance:
			best_clearance = clearance
			best_candidate = candidate

	return best_candidate

func _seat_clearance(candidate: Vector2) -> float:
	var nearest := INF
	for other in Global.all_persons.values():
		if other == self:
			continue
		if not other is Person:
			continue
		var other_person: Person = other
		if not other_person.visible:
			continue
		if other_person.current_obj != current_obj:
			continue
		nearest = min(nearest, candidate.distance_to(other_person.global_position))

	if nearest == INF:
		return 1000000.0
	return nearest

func do_absorption():
	if poison > 0.0:
		Global.absorb_poison_person(self)

		output_absorption_time.append(Global.current_time_s())
		output_poison.append(poison)
		output_absorbed_poison.append(absorbed_poison)

func enter_room(room: Area2D) -> void:
	current_room = room
	last_exposure_sample_time = Global.current_time_s()

func exit_room(room: Area2D) -> void:
	if current_room == room:
		current_room = null

func sample_viral_exposure() -> void:
	if current_room == null or not is_instance_valid(current_room):
		return

	var now_s: float = Global.current_time_s()
	var time_since_last_sample: float = now_s - last_exposure_sample_time
	if time_since_last_sample < EXPOSURE_SAMPLE_INTERVAL_S:
		return

	# Count one exposure sample per completed interval and sum raw sample values.
	var samples_due: int = int(floor(time_since_last_sample / EXPOSURE_SAMPLE_INTERVAL_S))
	if samples_due <= 0:
		return

	var room_vl: float = current_room.viral_load
	cumulative_viral_exposure += room_vl * float(samples_due)
	exposure_sample_count += samples_due
	last_exposure_sample_time += EXPOSURE_SAMPLE_INTERVAL_S * float(samples_due)
