extends CharacterBody2D

const SPEED = 250
const MAX_HEALTH := 3
const ON_HIT_DELAY := 2.0
var spawn_position: Vector2
var health := 3
var is_hit := false
var last_direction: Vector2 = Vector2.RIGHT

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	process_movement()
	if not is_hit:
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

func _ready() -> void:
	spawn_position = global_position
	add_to_group("player")

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

func respawn() -> void:
	print("player respawn")
	global_position = spawn_position
	velocity = Vector2.ZERO
	health = MAX_HEALTH

func take_damage(amount: int) -> void:
	if is_hit:
		return
	
	health -= amount
	print("player take damage, sisa health: ", health - amount)
	
	if health <= 0:
		respawn()
		$Camera2D.reset_smoothing()
		return
		
	is_hit = true
	animated_sprite_2d.play("on_hit")
	await get_tree().create_timer(ON_HIT_DELAY).timeout
	is_hit = false
	
