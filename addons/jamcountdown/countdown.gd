tool
extends PanelContainer

export var jam_title:= "GameJam"
export var year:= 2021
export var month:= 11
export var day:= 14
export var hour:= 16
export var minute:= 50
export var show_time_units := true

onready var title_label = get_node("HBoxContainer/TitleLabel")
onready var countdown_label = get_node("HBoxContainer/CountdownLabel")

var jam_end_date: Dictionary
var jam_date_unix: int
var time_left_unix: int
var timer: Timer


func _ready() -> void:
	title_label.text = jam_title
	countdown_label.visible = true
	
	jam_end_date = {
		"year": year,
		"month": month,
		"day": day,
		"hour": hour,
		"minute": minute,
		"second": 0
	}
	
	initialize_countdown()
	create_timer()


func create_timer() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", self, "_on_Timer_timeout")
	timer.set_wait_time(1.0)
	timer.set_one_shot(false)
	timer.start()


func _on_Timer_timeout() -> void:
	update_countdown()


func initialize_countdown() -> void:
	var jam_date_unix = OS.get_unix_time_from_datetime(jam_end_date)
	var current_time_unix = OS.get_unix_time_from_datetime(OS.get_datetime())
	time_left_unix = jam_date_unix - current_time_unix
	if time_left_unix > 0:
		update_countdown_label_text()


func update_countdown() -> void:
	var current_time_unix = OS.get_unix_time_from_datetime(OS.get_datetime())
	time_left_unix = jam_date_unix - current_time_unix
	
	if time_left_unix <= 0:
		countdown_label.visible = false
		if timer: timer.queue_free()
		return
	
	update_countdown_label_text()


func update_countdown_label_text() -> void:
	var time_left = get_datetime_from_unix(time_left_unix)
	
	# time units
	var d_time_u = "d" if show_time_units else ""
	var h_time_u = "h" if show_time_units else ""
	var m_time_u = "m" if show_time_units else ""
	var s_time_u = "s" if show_time_units else ""
	
	var str_days    = str(time_left.days)    + d_time_u+":" if time_left.days    > 0 or not show_time_units else ""
	var str_hours   = str(time_left.hours)   + h_time_u+":" if time_left.hours   > 0 or not show_time_units  else ""
	var str_minutes = str(time_left.minutes) + m_time_u+":" if time_left.minutes > 0 or not show_time_units  else ""
	var str_seconds = str(time_left.seconds) + s_time_u     if time_left.seconds > 0 or not show_time_units  else ""
	
	countdown_label.text = str_days + str_hours + str_minutes + str_seconds


func get_datetime_from_unix(unix) -> Dictionary:
	var seconds = floor(unix%60)
	var minutes = floor((unix/60)%60)
	var hours   = floor((unix/3600)%24)
	var days    = floor(unix/86400)
	
	var time = {
		"days": days,
		"hours": hours,
		"minutes": minutes,
		"seconds": seconds
	}
	return time
