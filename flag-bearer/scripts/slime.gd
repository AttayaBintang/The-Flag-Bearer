extends Node2D
const SPEED = 200
#Freeze when hitted
const FREEZE_TIME := 0.2
var frozen := false

var health := 3
var target: Node2D = null


func _process(delta: float) -> void:
	#Back to normal when frozen is false
	if frozen:
		return
	#wait for target collided, and run into the player
	if target:
		var direction = (target.global_position - global_position).normalized()
		global_position += direction * SPEED * delta

func _physics_process(_delta: float) -> void:
	#Damage process when the player is hit
	for body in $Hitted.get_overlapping_bodies():
		#print("slime touching: ", body.name)
		if body.is_in_group("player"):
			body.take_damage(1)

#When Enemy Hitted by a weapon
func take_damage(amount: int) -> void:
	print("enemy take damage, sisa health: ", health - amount)
	health -= amount
	if health <= 0:
		queue_free()
	
	#FREEZE when hitted
	frozen = true
	$AnimatedSprite2D.pause()
	await get_tree().create_timer(FREEZE_TIME).timeout
	frozen = false
	$AnimatedSprite2D.play()

#Checking a player is detected or not within the areas
func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Player Detected")
		target = body
func _on_sight_body_exited(body: Node2D) -> void:
	if body == target:
		target = null

#func _on_hitted_body_entered(body: Node2D) -> void:
	#print("slime touching: ", body.name)
	#if body.is_in_group("player"):
		#body.take_damage(1)
