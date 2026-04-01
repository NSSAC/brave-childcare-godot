class_name Person extends CharacterBody2D

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

@export var wander_profiles: Array = [
	{
		"role": "infants",
		"activity_names": ["tummy time"],
		"object_groups": [],
		"object_types": [],
		"radius_px": 48.0,
		"min_step_px": 10.0,
		"interval_s": 180.0,
		"jitter_s": 30.0
	},
	{
		"role": "preschoolers",
		"activity_names": [],
		"object_groups": ["play_structure"],
		"object_types": [],
		"radius_px": 220.0,
		"min_step_px": 32.0,
		"interval_s": 90.0,
		"jitter_s": 20.0
	}
]
var wander_anchor: Vector2 = Vector2.ZERO
var wander_next_time_s: float = 0.0
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

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var halo: AnimatedSprite2D = $Halo
@onready var label: Label = $Label
const LABEL_VERTICAL_OFFSET: float = -8.0

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
			wander_anchor = current_obj.global_position
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

func _value_in_normalized_list(value: Variant, candidates: Array) -> bool:
	if candidates.is_empty():
		return true

	var target := _normalize_string(value)
	for candidate in candidates:
		if target == _normalize_string(candidate):
			return true
	return false

func _wander_profile_matches(profile: Dictionary) -> bool:
	var role_rule := _normalize_string(profile.get("role", ""))
	if role_rule != "" and _normalize_string(role) != role_rule:
		return false

	var activity_names: Array = profile.get("activity_names", [])
	if not _value_in_normalized_list(current_activity_name, activity_names):
		return false

	var activity_aids: Array = profile.get("activity_aids", profile.get("activity_ids", []))
	if not _value_in_normalized_list(current_aid, activity_aids):
		return false

	if current_obj == null:
		return false

	var object_groups: Array = profile.get("object_groups", [])
	if not _value_in_normalized_list(current_obj.group, object_groups):
		return false

	var object_types: Array = profile.get("object_types", [])
	if not _value_in_normalized_list(current_obj.type, object_types):
		return false

	return true

func _active_wander_profile() -> Dictionary:
	for profile in wander_profiles:
		if not profile is Dictionary:
			continue
		if _wander_profile_matches(profile):
			return profile
	return {}

func _update_independent_behavior(current_time_s: float) -> void:
	if not visible:
		return

	if current_obj == null:
		return

	var profile: Dictionary = _active_wander_profile()
	if profile.is_empty():
		return

	# Only pick a new target once we've reached the prior one.
	if not navigation_agent_2d.is_navigation_finished():
		return

	if current_time_s < wander_next_time_s:
		return

	var min_step: float = float(profile.get("min_step_px", 8.0))
	var radius: float = float(profile.get("radius_px", max(8.0, min_step)))
	if radius <= 0.0:
		return
	min_step = clamp(min_step, 0.0, radius)

	var angle := rng.randf_range(0.0, TAU)
	var distance: float = rng.randf_range(min_step, radius)
	var offset: Vector2 = Vector2.RIGHT.rotated(angle) * distance
	var anchor: Vector2 = wander_anchor if wander_anchor != Vector2.ZERO else current_obj.global_position
	navigation_agent_2d.target_position = anchor + offset

	var interval: float = max(0.1, float(profile.get("interval_s", 60.0)))
	var jitter: float = max(0.0, float(profile.get("jitter_s", 0.0)))
	wander_next_time_s = current_time_s + interval + rng.randf_range(0.0, jitter)

func do_absorption():
	if poison > 0.0:
		Global.absorb_poison_person(self)

		output_absorption_time.append(Global.current_time_s())
		output_poison.append(poison)
		output_absorbed_poison.append(absorbed_poison)
