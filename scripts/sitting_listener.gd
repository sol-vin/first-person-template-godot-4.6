extends Node

class_name SittingListener

func _process(delta: float) -> void:
	if Player.sitting and Input.is_action_just_released("interact"):
		Player.stand()
		free()