extends Node2D

@export var num_bubbles: int = 6

@onready var bubble_scene = preload("res://bubble.tscn")

var bubble_keys = [
	{"move_left_key": "move_left_2", "move_right_key": "move_right_2"},  # Q and E
	{"move_left_key": "ui_left", "move_right_key": "ui_right"},  # A and D
	{"move_left_key": "move_left_3", "move_right_key": "move_right_3"},  # Z and C
	{"move_left_key": "move_left_4", "move_right_key": "move_right_4"},  # I and P
	{"move_left_key": "move_left_5", "move_right_key": "move_right_5"},  # J and L
	{"move_left_key": "move_left_6", "move_right_key": "move_right_6"}   # N and ,
]

func _ready():
	var screen_size = get_viewport().size
	var regions = [
		Rect2(Vector2(0, 0), Vector2(screen_size.x / 2, screen_size.y / 3)),  # Top left (Q and E)
		Rect2(Vector2(0, screen_size.y / 3), Vector2(screen_size.x / 2, screen_size.y / 3)),  # Middle left (A and D)
		Rect2(Vector2(0, 2 * screen_size.y / 3), Vector2(screen_size.x / 2, screen_size.y / 3)),  # Bottom left (Z and C)
		Rect2(Vector2(screen_size.x / 2, 0), Vector2(screen_size.x / 2, screen_size.y / 3)),  # Top right (I and P)
		Rect2(Vector2(screen_size.x / 2, screen_size.y / 3), Vector2(screen_size.x / 2, screen_size.y / 3)),  # Middle right (J and L)
		Rect2(Vector2(screen_size.x / 2, 2 * screen_size.y / 3), Vector2(screen_size.x / 2, screen_size.y / 3))  # Bottom right (N and ,)
	]

	for i in range(min(num_bubbles, 6)):
		var bubble_instance = bubble_scene.instantiate()
		bubble_instance.move_left_key = bubble_keys[i]["move_left_key"]
		bubble_instance.move_right_key = bubble_keys[i]["move_right_key"]
		bubble_instance.spawn_region = regions[i]
		add_child(bubble_instance)
