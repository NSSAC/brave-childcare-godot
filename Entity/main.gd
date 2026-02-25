extends Node

@onready var object_file_dialog: FileDialog = %ObjectFileDialog
@onready var config_file_dialog: FileDialog = %ConfigFileDialog

@onready var save_object_button: Button = %SaveObjectButton
@onready var start_simulation_button: Button = %StartSimulationButton

@onready var title_screen: CanvasLayer = %TitleScreen
@onready var map: Node2D = %Map
@onready var camera_2d: Camera2D = %Camera2D
@onready var current_time_label: Label = %CurrentTimeLabel

@export var generic_person_scene: PackedScene
@onready var save_timer: Timer = %SaveTimer

func save_objects(file: String):
	print("Saving objects to file: ", file)
	var object_file = FileAccess.open(file, FileAccess.WRITE)
	var object_data = []
	for oid in Global.all_objects:
		var object = Global.all_objects[oid]
		object_data.append({
		"oid": object.get_path(),
		"type": object.type,
		"group": object.group,
		"pos_x": object.global_position[0],
		"pos_y": object.global_position[1]
	})
	var object_json = JSON.stringify(object_data)
	object_file.store_line(object_json)
	object_file.close()
	print("Saving objects complete.")

func create_persons(file: String):
	print("Creating persons from file: ", file)
	var person_file = FileAccess.open(file, FileAccess.READ)
	var person_data = JSON.parse_string(person_file.get_as_text())
	for pd in person_data:
		if pd["type"] == "generic":
			var person: Person = generic_person_scene.instantiate()
			person.pid = pd["pid"]
			person.poison = pd["start_poison"]

			add_child(person)
			person.hide()
			Global.all_persons[person.pid] = person

			#print("Added person: ", pd["pid"])
		else:
			print("Unknon person type: ", JSON.stringify(pd))
	print(len(Global.all_persons), " persons created")

func load_schedule(file: String):
	print("Loading schedules from file: ", file)
	var schedule_file = FileAccess.open(file, FileAccess.READ)
	var schedule_data = JSON.parse_string(schedule_file.get_as_text())

	var min_start_time: float = -1
	var max_start_time: float = -1

	for sd in schedule_data:
		var pid: String = sd["pid"]
		var aid: String = sd["aid"]
		var oid: String = sd["oid"]
		var time: float = sd["start_time"]
		var person: Person = Global.all_persons[pid]
		person.activity_aid.append(aid)
		person.activity_oid.append(oid)
		person.activity_time.append(time)

		if min_start_time == -1:
			min_start_time = time
		else:
			min_start_time = min(min_start_time, time)

		if max_start_time == -1:
			max_start_time = time
		else:
			max_start_time = max(max_start_time, time)

	Global.runtime_start_s = min_start_time
	Global.runtime_end_s = max_start_time + Global.max_activity_duration

	print("Loading schedules complete")
	print("Runtime start: ", Global.runtime_start_s)
	print("Runtime end: ", Global.runtime_end_s)

func load_config(file: String):
	print("Loading config from file: ", file)

	var config_file = FileAccess.open(file, FileAccess.READ)
	var config_data = JSON.parse_string(config_file.get_as_text())

	var person_file: String = config_data["person_file"]
	var schedule_file: String = config_data["schedule_file"]
	var output_file: String = config_data["output_file"]

	if not person_file.is_absolute_path():
		person_file = file.get_base_dir().path_join(person_file)
	if not schedule_file.is_absolute_path():
		schedule_file = file.get_base_dir().path_join(schedule_file)
	if not output_file.is_absolute_path():
		output_file = file.get_base_dir().path_join(output_file)

	create_persons(person_file)
	load_schedule(schedule_file)
	Global.output_file_path = output_file

	Global.sim_speed_scale = config_data["sim_speed_scale"]
	Global.save_every_s = config_data["save_every_s"]

	Global.prob_poison_xfer = config_data["prob_poison_xfer"]
	Global.person_to_obj_coeff = config_data["person_to_obj_coeff"]
	Global.obj_to_person_coeff = config_data["obj_to_person_coeff"]
	Global.max_person_gain = config_data["max_person_gain"]
	Global.initial_poison = config_data["initial_poison"]

	Global.abs_tick_duration_s = config_data["abs_tick_duration_m"] * 60.0
	Global.abs_fast_poison_threshold = config_data["abs_fast_poison_threshold"]
	Global.abs_fast_rate_per_s = config_data["abs_fast_rate_per_h"] / 3600.0
	Global.abs_slow_frac_rate_per_s = config_data["abs_slow_frac_rate_per_h"] / 3600.0
	Global.abs_obj_absorption_frac = config_data["abs_obj_absorption_frac"]

func start_simulation(file: String):
	load_config(file)

	title_screen.hide()
	map.show()

	for object in get_tree().get_nodes_in_group("poisoned_object"):
		var obj: SmartObject = object
		obj.poison = Global.initial_poison

	Global.sim_clock_s = Global.runtime_start_s
	Global.prev_abs_event_s = Global.runtime_start_s
	Global.save_file = FileAccess.open(Global.output_file_path, FileAccess.WRITE)
	save_timer.start()

func _on_save_object_button_pressed():
	object_file_dialog.show()

func _on_object_file_selected(file: String):
	object_file_dialog.hide()
	save_objects(file)

func _on_start_simulation_button_pressed():
	config_file_dialog.show()

func _on_config_file_selected(file: String):
	config_file_dialog.hide()
	start_simulation(file)

func _on_save_timer_timeout():
	print("Saving pending output")
	for pid in Global.all_persons:
		Global.all_persons[pid].save_events()
	for oid in Global.all_objects:
		Global.all_objects[oid].save_events()
	Global.save_file.flush()
	print("Saving pending output complete.")

func _ready() -> void:
	object_file_dialog.file_selected.connect(_on_object_file_selected)
	config_file_dialog.file_selected.connect(_on_config_file_selected)

	save_object_button.pressed.connect(_on_save_object_button_pressed)
	start_simulation_button.pressed.connect(_on_start_simulation_button_pressed)

	var home_dir = OS.get_environment("HOME")
	object_file_dialog.root_subfolder = home_dir
	config_file_dialog.root_subfolder = home_dir

	save_timer.timeout.connect(_on_save_timer_timeout)
	save_timer.wait_time = Global.save_every_s

	for object in get_tree().get_nodes_in_group("smart_object"):
		var oid: String = object.get_path()
		object.object_id = oid
		Global.all_objects[oid] = object

	var entrances = Array()
	for entrance in get_tree().get_nodes_in_group("entrance"):
		entrances.append(entrance)
	var num_entrances = len(entrances)
	for i in range(num_entrances):
		for j in range(i+1, num_entrances):
			var link_rid = NavigationServer2D.link_create()
			NavigationServer2D.link_set_owner_id(link_rid, get_instance_id())
			NavigationServer2D.link_set_enter_cost(link_rid, 0.0)
			NavigationServer2D.link_set_travel_cost(link_rid, 1e-6)
			NavigationServer2D.link_set_navigation_layers(link_rid, 1)
			NavigationServer2D.link_set_bidirectional(link_rid, true)

			# Enable the link and set it to the default navigation map.
			NavigationServer2D.link_set_enabled(link_rid, true)
			NavigationServer2D.link_set_map(link_rid, get_viewport().world_2d.get_navigation_map())

			# Move the 2 link positions to their intended global positions.
			NavigationServer2D.link_set_start_position(link_rid, entrances[i].global_position)
			NavigationServer2D.link_set_end_position(link_rid, entrances[j].global_position)

	var user_args = OS.get_cmdline_user_args()
	if len(user_args) == 2 and user_args[0] == "--config":
		start_simulation(user_args[1])


func _process(_delta: float) -> void:
	if Input.is_action_pressed("camera_right"):
		camera_2d.offset.x += 32
	if Input.is_action_pressed("camera_left"):
		camera_2d.offset.x -= 32
	if Input.is_action_pressed("camera_down"):
		camera_2d.offset.y += 32
	if Input.is_action_pressed("camera_up"):
		camera_2d.offset.y -= 32
	if Input.is_action_pressed("zoom_in"):
		camera_2d.zoom.x *= 1.05
		camera_2d.zoom.y *= 1.05
	if Input.is_action_pressed("zoom_out"):
		camera_2d.zoom.x *= 0.95
		camera_2d.zoom.y *= 0.95
	#if Input.is_action_pressed("pause"):
		#get_tree().paused = true
	#if Input.is_action_pressed("unpause"):
		#get_tree().paused = false

	var c_time = Global.current_time_s()
	var c_time_h = int(c_time / 3600)
	var c_time_m = int((c_time - c_time_h * 3600) / 60)
	var fps = Engine.get_frames_per_second()

	current_time_label.text = "Time: %02.0f:%02.0f   FPS: %d    " % [c_time_h, c_time_m, fps]

	if Global.current_time_s() > Global.runtime_end_s:
		save_timer.stop()
		_on_save_timer_timeout()
		Global.save_file.close()
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		get_tree().quit()

func _physics_process(_delta: float) -> void:
	if Global.sim_clock_s > 0.0:
		Global.sim_clock_s += Global.seconds_per_physics_tick

		if Global.sim_clock_s - Global.prev_abs_event_s > Global.abs_tick_duration_s:
			for pid in Global.all_persons:
				Global.all_persons[pid].do_absorption()
			Global.prev_abs_event_s = Global.sim_clock_s
