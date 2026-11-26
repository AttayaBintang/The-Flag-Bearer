extends CharacterBody2D

const SPEED = 250
const MAX_HEALTH := 3
const ON_HIT_DELAY := 2.0
const RESPAWN_DELAY = 3

var spawn_position: Vector2
var health := MAX_HEALTH
var is_hit := false
var last_direction: Vector2 = Vector2.RIGHT

var is_dead := false
var invincible := false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	process_movement()
	if not is_hit and not is_dead:
		process_animation()
	move_and_slide()


#---------------------------
#	MOVEMENT & ANIMATION
#---------------------------
func process_movement() -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right", "up", "down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
	else:
		velocity = Vector2.ZERO
	
	if is_dead:
		velocity = Vector2.ZERO
		return

func _ready() -> void:
	spawn_position = global_position
	add_to_group("player")
	await get_tree().process_frame
	
	var scene_path = get_tree().current_scene.scene_file_path
	
	if Global.arrive_portal_id != "":
		for p in get_tree().get_nodes_in_group("portal"):
			if p.portal_id == Global.arrive_portal_id:
				global_position = p.get_node("SpawnPoint").global_position
				Global.set_checkpoint(scene_path, global_position)
			Global.arrive_portal_id = ""
	elif Global.has_checkpoint and Global.checkpoint_scene == scene_path:
		global_position = Global.checkpoint_position

func process_animation() -> void:
	if velocity != Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)
	
func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0: 
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play(prefix)
	elif dir.y != 0:
		animated_sprite_2d.play(prefix)

func die() -> void:
	is_dead = true
	animated_sprite_2d.play("died")
	print("player is dead, respawn in: ", RESPAWN_DELAY, " sec")
	await get_tree().create_timer(RESPAWN_DELAY).timeout
	respawn()
	
func respawn() -> void:
	print("player respawn")
	
	if Global.has_checkpoint and Global.checkpoint_scene != get_tree().current_scene.scene_file_path:
		get_tree().change_scene_to_file.call_deferred(Global.checkpoint_scene)
		return
	
	global_position = Global.checkpoint_position if Global.has_checkpoint else spawn_position
	velocity = Vector2.ZERO
	health = MAX_HEALTH
	is_hit = false
	is_dead = false
	
	invincible = true
	await get_tree().create_timer(1.0).timeout
	invincible = false

func take_damage(amount: int) -> void:
	if is_hit or is_dead or invincible:
		return
	
	health -= amount
	print("player take damage, sisa health: ", health)
	
	if health <= 0:
		die()
		$Camera2D.reset_smoothing()
		return
		
	is_hit = true
	animated_sprite_2d.play("on_hit")
	await get_tree().create_timer(ON_HIT_DELAY).timeout
	is_hit = false
	
