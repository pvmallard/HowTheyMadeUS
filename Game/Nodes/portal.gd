extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("Swirl")


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		# either get random room, or for every 3-5 rooms get an empty altar room
		print_debug("enter portal")
