class_name SmartObject extends Area2D

var object_id: String = ""
var poison: float = 0.0
var absorbed_poison: float = 0.0

@export var type: String = ""
@export var group: String = ""
@onready var halo: AnimatedSprite2D = $Halo
@onready var label: Label = $Label

var output_oid_poison_start: Array[float] = []
var output_oid_absorbed_poison_start: Array[float] = []
var output_pid_poison_start: Array[float] = []
var output_oid_poison_end: Array[float] = []
var output_oid_absorbed_poison_end: Array[float] = []
var output_pid_poison_end: Array[float] = []
var output_time: Array[float] = []
var output_pid: Array[String] = []

func save_events():
	var n = len(output_oid_poison_start)
	
	for i in range(n):
		var obj = {
			"event": "poison_exchange",
			"oid": object_id,
			"pid": output_pid[i],
			"time": output_time[i],
			"oid_poison_start": output_oid_poison_start[i],
			"oid_absorbed_poison_start": output_oid_absorbed_poison_start[i],
			"oid_poison_end": output_oid_poison_end[i],
			"oid_absorbed_poison_end": output_oid_absorbed_poison_end[i],
			"pid_poison_start": output_pid_poison_start[i],
			"pid_poison_end": output_pid_poison_end[i],
		}
		var obj_str = JSON.stringify(obj)
		Global.poison_save_file.store_line(obj_str)
	
	output_pid.clear()
	output_time.clear()
	output_oid_poison_start.clear()
	output_oid_poison_end.clear()
	output_oid_absorbed_poison_start.clear()
	output_oid_absorbed_poison_end.clear()
	output_pid_poison_start.clear()
	output_pid_poison_end.clear()
	
func _ready() -> void:
	# People dont react to collisions
	# Objects react when people collide with them
	collision_layer = 0b10 # is on layer two 
	collision_mask = 0b01
	halo.hide()
	label.text = ""
	label.hide()
	
	body_entered.connect(_on_body_entered)
	
func _process(_delta: float) -> void:
	pass
	
func _on_body_entered(body: Node2D):
	if body is Person:
		var person: Person = body
		output_pid.append(person.pid)
		output_time.append(Global.current_time_s())
		
		output_oid_poison_start.append(poison)
		output_oid_absorbed_poison_start.append(absorbed_poison)
		output_pid_poison_start.append(person.poison)
		
		Global.exchange_poison(person, self)
		
		output_oid_poison_end.append(poison)
		output_oid_absorbed_poison_end.append(absorbed_poison)
		output_pid_poison_end.append(person.poison)
