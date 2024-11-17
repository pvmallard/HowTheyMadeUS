extends Node


@onready var text_box_scene = preload("res://Nodes/text_box_control.tscn")

var dialog_lines: Array[String] = []
var current_line_index = 0

var text_box
#var text_box_position: Vector2
var sfx: AudioStream

var is_dialog_active = false
var can_advance_line = false

func start_dialog(interactable: Node3D, lines: Array[String], speech_sfx: AudioStream):
	if is_dialog_active:
		return
		
	dialog_lines = lines
#	text_box_position = position
	sfx = speech_sfx
	_show_text_box()
	
	interactable.area_left.connect(_end_dialogue)
	
	is_dialog_active = true
	
func _show_text_box():
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished)
	get_tree().root.add_child(text_box)
	print_debug("show text box: dialoguemanager.gd")
#	text_box.global_position = text_box_position
	text_box.display_text(dialog_lines[current_line_index], sfx)
	can_advance_line = false
	
func _on_text_box_finished():
#	print_debug("we hear you")
	can_advance_line = true
	
func _end_dialogue():
	is_dialog_active = false
	can_advance_line = false
	current_line_index = 0
	if is_instance_valid(text_box):
		text_box.queue_free()
	
func _unhandled_input(event):
	if (
		event.is_action_pressed("interact") &&
		is_dialog_active &&
		can_advance_line
	):
		if is_instance_valid(text_box):
			text_box.queue_free()
		
		current_line_index += 1
		if current_line_index >= dialog_lines.size():
			is_dialog_active = false
			current_line_index = 0
			return
		
		_show_text_box()
