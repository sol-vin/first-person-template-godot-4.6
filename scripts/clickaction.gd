class_name ClickAction extends Node

signal on_left_click(item)

func left_click(item):
	on_left_click.emit(item)
	
signal on_right_click(item)

func right_click(item):
	on_right_click.emit(item)
