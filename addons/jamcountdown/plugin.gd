tool
extends EditorPlugin

var countdown_scene = preload("res://addons/jamcountdown/countdown.tscn")
var countdown
var container = 0

func _enter_tree():	
	countdown = countdown_scene.instance()
	add_control_to_container(container, countdown)


func _exit_tree():
	remove_control_from_container(container, countdown)
	countdown.queue_free()
