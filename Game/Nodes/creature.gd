extends CharacterBody3D


@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var death_sound: AudioStreamPlayer3D = $DeathSound
@onready var attack_delay: Timer = $AttackDelay

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")


@export var move_speed = 2.0
@export var attack_range = 2.0
@export var health = 5

var dead = false
var chase = false
var can_attack = true

# should do path based movement/patrolling with areas to detect player/sound detection

func _ready():
	animated_sprite_3d.play("Idle")
	animated_sprite_3d.animation_finished.connect(anim_handler)

func _physics_process(delta: float) -> void:
	if dead:
		return
	if player == null:
		return
	if !can_attack:
		return
		
	var dir = player.global_position - global_position
	dir.y = 0.0
	dir = dir.normalized()
	
	velocity = dir * move_speed
	
	move_and_slide()
	attack()

func attack():
	var dist_to_player = global_position.distance_to(player.global_position)
	if dist_to_player > attack_range:
		return
		
	if can_attack: 
		animated_sprite_3d.play("Attack")
		can_attack = false

func takeDamage(amount):
	health -= amount
	
	if health <= 0:
		kill()
		
func kill():
	dead = true
	death_sound.play()
	animated_sprite_3d.play("Death")
	$CollisionShape3D.disabled = true
	
func anim_handler():
	if animated_sprite_3d.animation == "Attack":
		var dist_to_player = global_position.distance_to(player.global_position)
		var eye_line = Vector3.UP * 1.5
		# raycast from code, do you have a line of sight
		var query = PhysicsRayQueryParameters3D.create(global_position+eye_line, player.global_position+eye_line, 1)
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		if result.is_empty() and dist_to_player <= attack_range:
			player.takeDamage(5)
				
		animated_sprite_3d.play("Recover")
		
	if animated_sprite_3d.animation == "Death":
		self.queue_free()
		
	if animated_sprite_3d.animation == "Recover":
		animated_sprite_3d.play("Idle")
		can_attack = true
