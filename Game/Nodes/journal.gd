extends Control

var is_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/MarginContainer.visible = false

func open():
	is_open = true
	$AnimationPlayer.play("open")

func close():
	is_open = false
	$AnimationPlayer.play_backwards("open")
