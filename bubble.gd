extends Node2D

var move_left_key: String
var move_right_key: String
var spawn_region: Rect2

func _ready():
	randomize_position()

func _process(delta: float) -> void:
	if Input.is_action_pressed(move_left_key):
		position.x -= 100 * delta
	elif Input.is_action_pressed(move_right_key):
		position.x += 100 * delta

func randomize_position():
	var x = randf_range(spawn_region.position.x, spawn_region.position.x + spawn_region.size.x)
	var y = randf_range(spawn_region.position.y, spawn_region.position.y + spawn_region.size.y)
	position = Vector2(x, y)
