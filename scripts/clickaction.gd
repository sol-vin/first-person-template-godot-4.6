class_name ClickAction extends Node


signal on_left_click_pressed(item)
signal on_left_click_released(item)

func left_click(item):
	if Input.is_action_just_pressed("interact"):
		on_left_click_pressed.emit(item)
	if !Input.is_action_just_released("interact"):
		on_left_click_released.emit(item)
	
signal on_right_click_pressed(item)
signal on_right_click_released(item)

func right_click(item):
	if Input.is_action_just_pressed("interact2"):
		on_right_click_pressed.emit(item)
	if !Input.is_action_just_released("interact2"):
		on_right_click_released.emit(item)
