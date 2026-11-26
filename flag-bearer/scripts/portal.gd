extends Area2D

const COOLDOWN := 5

@export_file("*.tscn") var target_scene: String
@export var portal_id: String
@export var target_portal_id: String

var can_travel := false

func _ready() -> void:
	add_to_group("portal")
	body_entered.connect(_on_body_enterred)
	await get_tree().create_timer(COOLDOWN).timeout
	can_travel = true
	
func _on_body_enterred(body: Node2D) -> void:
	if not can_travel or target_scene == "":
		return
	
	if body.is_in_group("player"):
		Global.arrive_portal_id = target_portal_id
		get_tree().change_scene_to_file.call_deferred(target_scene)
