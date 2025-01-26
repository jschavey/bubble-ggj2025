extends Node

@export var bubble_scene = preload("res://Bubble.tscn")

func initialize_bubbles(parent, num_bubbles, bubble_keys, left_key_textures, right_key_textures):
	var screen_size = parent.get_viewport().size
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
		var area2d_instance = bubble_instance.get_child(0)  # Assuming the first child is the Area2D node
		area2d_instance.move_left_key = bubble_keys[i]["move_left_key"]
		area2d_instance.move_right_key = bubble_keys[i]["move_right_key"]
		area2d_instance.left_key_texture = left_key_textures[i]
		area2d_instance.right_key_texture = right_key_textures[i]
		area2d_instance.spawn_region = regions[i]
		parent.add_child(bubble_instance)
		parent.bubbles.append(area2d_instance)
		area2d_instance.connect("bubble_popped", Callable(parent, "_on_bubble_popped"))  # Connect to bubble_popped signal

func update_bubbles_score(bubbles):
	var total_score = 0
	for bubble in bubbles:
		if is_instance_valid(bubble) and bubble.alive:
			total_score += bubble.get_score()
	return total_score

func handle_bubble_popped(bubbles, bubble_instance):
	print("Bubble popped: ", bubble_instance)
	bubbles.erase(bubble_instance)  # Remove the bubble from the array
