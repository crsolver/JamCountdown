@tool
extends EditorPlugin

var countdown_scene = preload("res://addons/jamcountdown/jam_countdown.tscn")
var countdown
var container = 0

const POMO_5 := "Pomodoro 5 Minutes"
const POMO_25 := "Pomodoro 25 Minutes"
const POMO_45 := "Pomodoro 45 Minutes"
const POMO_60 := "Pomodoro 60 Minutes"
const POMO_120 := "Pomodoro 120 Minutes"

var UNIX_TIME_CALC_CORRECTION := 0

func _enter_tree():
	# get offset from UTC for local time calculations:
	var time_zone := Time.get_time_zone_from_system() # <--- this does have an edge case checked windows machines during daylight savings time, not sure how to solve
	# time_zone:bias is how many minutes offset local time is from UTC, convert to seconds for unix epoch offset
	UNIX_TIME_CALC_CORRECTION = time_zone["bias"] * 60
	
	countdown = countdown_scene.instantiate()
	countdown.name = "addon_countdown"
	add_control_to_container(container, countdown)
	add_tool_menu_item(POMO_5, func():_tool_pomodoro(5))
	add_tool_menu_item(POMO_25, func():_tool_pomodoro(25))
	add_tool_menu_item(POMO_45, func():_tool_pomodoro(45))
	add_tool_menu_item(POMO_60, func():_tool_pomodoro(60))
	add_tool_menu_item(POMO_120, func():_tool_pomodoro(120))

func _exit_tree():
	remove_control_from_container(container, countdown)
	countdown.queue_free()
	remove_tool_menu_item(POMO_5)
	remove_tool_menu_item(POMO_25)
	remove_tool_menu_item(POMO_45)
	remove_tool_menu_item(POMO_60)
	remove_tool_menu_item(POMO_120)

func _tool_pomodoro(minutes : int) -> void:
	
	remove_control_from_container(container, countdown)
	countdown.queue_free()
	countdown = countdown_scene.instantiate()
	add_control_to_container(container, countdown)
	var offset :int = UNIX_TIME_CALC_CORRECTION + (minutes*60)
	var time = Time.get_datetime_dict_from_unix_time(Time.get_unix_time_from_system() + offset)
	countdown.start_countdown(time)









