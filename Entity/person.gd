class_name Person extends CharacterBody2D

var pid: String = ""
var current_obj: SmartObject
var current_aid: String

var activity_aid: Array[String] = []
var activity_oid: Array[String] = []
var activity_time: Array[float] = []
var activity_idx: int = 0

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
		Global.save_file.store_line(obj_str)

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
		Global.save_file.store_line(obj_str)

	output_absorption_time.clear()
	output_poison.clear()
	output_absorbed_poison.clear()

func _ready() -> void:
	# People dont react to collisions
	# Objects react when people collide with them
	collision_layer = 0b01 # is on layer two
	collision_mask = 0

	navigation_agent_2d.navigation_finished.connect(_on_navigation_agent_2d_navigation_finished)

	# Make sure to not await during _ready.
	do_first_behavior.call_deferred()

func _process(_delta: float) -> void:
	label.text = "☣ %0.1f" % [poison]

	if poison < 1.0:
		halo.play("clear")
	elif poison < 5.0:
		halo.play("blue")
	elif poison < 15.0:
		halo.play("yellow")
	elif poison < 30.0:
		halo.play("red")
	else:
		halo.play("pink")

	do_behavior()


func _physics_process(_delta: float) -> void:
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
	if navigation_agent_2d.is_navigation_finished():
		output_event.append("start")
		output_aid.append(current_aid)
		output_time.append(Global.current_time_s())
		output_pos_x.append(global_position[0])
		output_pos_y.append(global_position[1])

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
			var a_oid: String = activity_oid[activity_idx]
			var a_obj: SmartObject = Global.all_objects[a_oid]
			current_obj = a_obj

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

func do_absorption():
	if poison > 0.0:
		Global.absorb_poison_person(self)

		output_absorption_time.append(Global.current_time_s())
		output_poison.append(poison)
		output_absorbed_poison.append(absorbed_poison)
