extends Area3D

@export var interactableName: String = ""
@export var lines: Array[String] = []
@export var speech_sound: AudioStream

var can_interact =  false
var is_interacting = false

signal area_left()

func _unhandled_input(event):
	if event.is_action_pressed("Interact"):
		print_debug("interact clicked")
		if (can_interact && not is_interacting):
			#hide any labels
			is_interacting = true
			var current2D = Vector2(global_position.x, global_position.y)
			DialogueManager.start_dialog(self, lines, speech_sound)
			#animate?


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print_debug("entered")
		can_interact = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		can_interact = false
		is_interacting = false
		area_left.emit()
