extends Node

var checkpoint_scene := ""
var checkpoint_position := Vector2.ZERO
var has_checkpoint := false
var arrive_portal_id := ""

func set_checkpoint(scene_path: String, pos: Vector2) -> void:
	checkpoint_scene = scene_path
	checkpoint_position = pos
	has_checkpoint = true
