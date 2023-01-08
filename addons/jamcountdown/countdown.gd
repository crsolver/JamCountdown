@tool
extends PanelContainer

@export var jam_title:= "Title"
@export var year:= 2023
@export var month:= 10
@export var day:= 10
@export var hour:= 10
@export var minute:= 10
@export var show_time_units := true
@export var print_pomodoro_start_times := false

@onready var title_label = get_node("HBoxContainer/TitleLabel")
@onready var countdown_label = get_node("HBoxContainer/CountdownLabel")

var jam_end_date: Dictionary
var jam_date_unix
var time_left_unix: int
var timer: Timer

func _ready() -> void:
	jam_end_date = {
		"year": year,
		"month": month,
		"day": day,
		"hour": hour,
		"minute": minute,
		"second": 0
	}
	
	start_countdown(jam_end_date)

func start_countdown(end_date : Dictionary) -> void:
	jam_end_date = end_date
	title_label.text = jam_title
	countdown_label.text = ""
	countdown_label.visible = true
	initialize_countdown()
	if print_pomodoro_start_times:
		print("Countdown started for %s" % str(end_date))

func create_timer() -> void:
	if not is_instance_valid(timer):
		timer = Timer.new()
		add_child(timer)
		timer.connect("timeout",Callable(self,"_on_Timer_timeout"))
	timer.process_mode = 0
	timer.set_one_shot(false)
	
	# Sync with system clock
	var system_time_ms = Time.get_unix_time_from_system() * 1000
	var str_millis = str(system_time_ms)
	var wait_time = (1000-int(str_millis.substr(str_millis.length()-3,str_millis.length()-1)))/1000.0
	if wait_time == 0: wait_time = 1
	
	timer.set_wait_time(wait_time)
	timer.start()


func _on_Timer_timeout() -> void:
	if not is_instance_valid(timer):
		return
	timer.set_wait_time(1)
	update_countdown()


func initialize_countdown() -> void:
	jam_date_unix = Time.get_unix_time_from_datetime_dict(jam_end_date)
	var current_time_unix = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())
	
	time_left_unix = jam_date_unix - current_time_unix
	if time_left_unix < 0:
		countdown_label.text = ""
		return
	update_countdown_label_text()
	create_timer()


func update_countdown() -> void:
	var current_time_unix = Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system())
	time_left_unix = jam_date_unix - current_time_unix
	
	if time_left_unix <= 0:
		countdown_label.visible = false
		if timer: timer.queue_free()
		return
	
	update_countdown_label_text()


func update_countdown_label_text() -> void:
	
	var time_left = get_datetime_from_unix(time_left_unix)
	
	var str_days
	var str_hours
	var str_minutes
	var str_seconds
	
	if show_time_units:
		str_days    = "%02d" % time_left.day + "d "    if time_left.day    > 0 else ""
		str_hours   = "%02d" % time_left.hour + "h "   if time_left.hour   > 0 else ""
		str_minutes = "%02d" % time_left.minute + "m "
		str_seconds = "%02d" % time_left.second + "s"
	else:
		str_days    = "%02d" % time_left.day    +":"
		str_hours   = "%02d" % time_left.hour   +":"
		str_minutes = "%02d" % time_left.minute +":"
		str_seconds = "%02d" % time_left.second
		
	countdown_label.text = str_days + str_hours + str_minutes + str_seconds

func get_datetime_from_unix(unix) -> Dictionary:
	var seconds = floor(unix%60)
	var minutes = floor((unix/60)%60)
	var hours   = floor((unix/3600)%24)
	var days    = floor(unix/86400)
	
	var time = {
		"day": days,
		"hour": hours,
		"minute": minutes,
		"second": seconds
	}
	return time
