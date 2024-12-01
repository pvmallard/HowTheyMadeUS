extends CharacterBody3D

# reference to tool animation
@onready var ray_cast_3d: RayCast3D = $RayCast3D

@onready var tool_use: AudioStreamPlayer = $ToolUse
@onready var gunshot: AudioStreamPlayer = $Gunshot
@onready var reload: AudioStreamPlayer = $Reload
@onready var camera: Camera3D = $Camera3D

@onready var journal: Control = $Journal



const SPEED = 5.0
const MOUSE_SENS = 0.5

var bob_freq = 2.5
var bob_amp = 0.01
var t_bob = 0.0

var can_tool = true
var j_dead = false
var y_dead = false

var j_health = 15
var y_health = 15

var j_is_current = true;

# both - walk/sneak, run, crouch, use tool, investigate
# jackie - hack
# yusuf - shoot

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$CanvasLayer/Tool/Axe.visible = true
	$CanvasLayer/Tool/Gun.visible = false
	$CanvasLayer/Tool/Gun.play("Idle")
	$CanvasLayer/Tool/Axe.play("Idle")
	# connect animation_finished.connect(tool_anim_finished)
	
func _input(event):
	if event is InputEventMouseMotion and not journal.is_open:
		rotation_degrees.y -= event.relative.x * MOUSE_SENS

	
func _process(delta):
	if Input.is_action_just_pressed("Exit"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("Swap"):
		swap()
	
	if Input.is_action_just_pressed("Tool") and not journal.is_open:
		useTool()
		
	if Input.is_action_just_pressed("Journal"):
		journalOnOff()
			

func _physics_process(delta: float) -> void:
	if j_dead and y_dead:
		return

	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		t_bob += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin += _headbob(t_bob)
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func restart():
	pass
	
func useTool():
	if !can_tool:
		return
	can_tool = false
	
	if j_is_current: 
		$CanvasLayer/Tool/Axe.play("Use")
		tool_use.play()
	else: 
		$CanvasLayer/Tool/Gun.play("Use")
		gunshot.play()
		await gunshot.finished
		reload.play()
	
	if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method("takeDamage"):
		var dmg = 2
		if j_is_current: dmg = 1
		ray_cast_3d.get_collider().takeDamage(dmg)
		
	if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method("uncover"):
		ray_cast_3d.get_collider().uncover()
		
func tool_anim_finished():
	can_tool = true
	
func takeDamage(amount):
	if j_is_current:
		j_health -= amount
		print_debug("jackie has" + str(j_health) )
		if j_health <= 0:
			kill_current()
	else:
		y_health -= amount
		print_debug("yusuf has" + str(y_health) )
		if y_health <= 0:
			kill_current()
	
	
func mend(char):
	#random health amount? only 3 times per run?
	if char == "j":
		j_health += 5
	else: 
		y_health += 5	

func kill_current():
	if j_is_current:
		print_debug("jackie has died")
		j_dead = true
		j_health = 0
		# open time reset screen, take back to start
		# pause scene save for menu
		get_tree().reload_current_scene()
	else:
		print_debug("yusuf has died")
		y_dead = true
		y_health = 0
		# his death cutscene
		# reset to j stats
		j_is_current = true
		
func swap():
	if j_is_current:
		j_is_current = false
		$CanvasLayer/Tool/Gun.visible = true
		$CanvasLayer/Tool/Axe.visible = false
	else:
		j_is_current = true
		$CanvasLayer/Tool/Gun.visible = false
		$CanvasLayer/Tool/Axe.visible = true
		
func journalOnOff():
	if not j_is_current:
		return
	
	if journal.is_open:
		journal.close()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if j_is_current:
			$CanvasLayer/Tool/Gun.visible = false
			$CanvasLayer/Tool/Axe.visible = true
		else:
			$CanvasLayer/Tool/Gun.visible = true
			$CanvasLayer/Tool/Axe.visible = false
	else:
		journal.open()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		$CanvasLayer/Tool/Gun.visible = false
		$CanvasLayer/Tool/Axe.visible = false
		


func _on_gun_animation_finished() -> void:
	$CanvasLayer/Tool/Gun.play("Idle")
	can_tool = true


func _on_axe_animation_finished() -> void:
	$CanvasLayer/Tool/Axe.play("Idle")
	can_tool = true

	
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq / 2) * bob_amp
	return pos
	
