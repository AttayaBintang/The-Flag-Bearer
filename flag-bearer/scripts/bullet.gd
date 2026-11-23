extends Node2D

const SPEED = 1000
const DAMAGE := 1
const FREEZE_TIME := 0.2

const MAX_RANGE := 400.0
const RANGE_FREEZE_TIME := 0.2

var frozen := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if frozen:
		return
	position += transform.x * SPEED * delta
	
	var player = get_tree().get_first_node_in_group("player")
	if player and global_position.distance_to(player.global_position) > MAX_RANGE:
		stop_at_range()
		
func stop_at_range() -> void:
	frozen = true
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(RANGE_FREEZE_TIME).timeout
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if frozen:
		return
	
	var enemy = area.get_parent()

	if enemy.has_method("take_damage"):
		frozen = true
		$Hitbox/CollisionShape2D.set_deferred("disabled", true)
		enemy.take_damage(DAMAGE)
		await get_tree().create_timer(FREEZE_TIME).timeout
		queue_free()
	
