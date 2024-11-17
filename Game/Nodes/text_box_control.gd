extends Control

@onready var label = $text_box/MarginContainer/Label
@onready var timer = $LetterDispTimer
@onready var audio_player = $text_box/AudioStreamPlayer
@onready var text_box = $text_box

const MAX_WIDTH = 256

var text = ""
var letter_index = 0

var letter_time = 0.03
var space_time = 0.06
var punctuation_time = 0.2

signal finished_displaying()

func _ready():
	text_box.scale = Vector2.ZERO

func display_text(text_to_display: String, speech_sfx: AudioStream):
	text = text_to_display
	label.text = text_to_display
	audio_player.stream = speech_sfx

	await text_box.resized
	text_box.custom_minimum_size.x = min(text_box.size.x, MAX_WIDTH)
	print_debug("display text: text_box.gd")
	
	if text_box.size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await text_box.resized
		await text_box.resized
		text_box.custom_minimum_size.y = size.y
		
#	global_position.x -= size.x / 2
#	global_position.y -= size.y - 24
	
	label.text = ""
	
	text_box.pivot_offset = Vector2(size.x/2, size.y)
	var tween = get_tree().create_tween()
	tween.tween_property(
		text_box, "scale", Vector2(1,1), 0.15
	).set_trans(Tween.TRANS_BACK)
	
	_display_letter()
	
func _display_letter():
#	print_debug(letter_index)
	label.text += text[letter_index]
#	print_debug(label.text)
	
	letter_index += 1
	if letter_index >= text.length():
#		print_debug("done with line")
		finished_displaying.emit()
#		label.text += " >"
		return
		
	match text[letter_index]:
		"!", ".", ",", "?":
			timer.start(punctuation_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(letter_time)
			
			var new_audio_player = audio_player.duplicate()
			new_audio_player.pitch_scale += randf_range(-0.1, 0.1)
			if text[letter_index] in ["a", "e", "i", "o", "u"]:
				new_audio_player.pitch_scale += 0.2
			get_tree().root.add_child(new_audio_player)
			new_audio_player.play()
			await new_audio_player.finished
			new_audio_player.queue_free()
		


func _on_letter_disp_timer_timeout() -> void:
#	print_debug("display")
	_display_letter()
