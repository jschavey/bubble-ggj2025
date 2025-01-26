extends Area2D

@export var fish_textures: Array[Texture2D]
@export var fish_size: Vector2 = Vector2(512, 512)  # Adjust the obstacle size
@export var large_fish_size: Vector2 = Vector2(1536, 128)  # Size for specific texture
@export var speed: float = 350.0
@export var horizontal_speed: float = 100.0

@onready var sprite = get_parent().get_node('Sprite2D')  # Access the sibling Sprite2D node
@onready var collision_polygon = $CollisionPolygon2D  # Access the CollisionPolygon2D node

var target_bubble: Area2D

func _ready():
	randomize_appearance()
	generate_collision_shape()
	scale_both()
	#apply_rotation()
	set_process(true)  # Ensure _process is enabled

func _process(delta: float):
	move_fish(delta)

func randomize_appearance():
	var texture = fish_textures[randi() % fish_textures.size()]
	sprite.texture = texture

	# Adjust fish size based on specific texture
	if texture == fish_textures[2]:  # Assuming the third texture needs a different size
		fish_size = large_fish_size
	else:
		fish_size = Vector2(512, 512)  # Default size

func move_fish(delta: float):
	if target_bubble and is_instance_valid(target_bubble):
		var target_x = target_bubble.global_position.x
		var direction = sign(target_x - global_position.x)
		global_position.x += direction * horizontal_speed * delta

		# Mirror the fish sprite based on the direction
		if direction != 0:
			sprite.scale.x = -abs(sprite.scale.x) * direction

	global_position.y += speed * delta
	sprite.global_position = global_position  # Ensure the sprite moves with the Area2D
	collision_polygon.global_position = global_position  # Ensure the collision polygon moves with the Area2D

	if global_position.y > get_viewport_rect().size.y:
		queue_free()
		sprite.visible = false

func generate_collision_shape():
	var image = sprite.texture.get_image()
	if image:
		var points = []
		var center_offset = sprite.texture.get_size() / 2  # Center offset

		for y in range(image.get_height()):
			for x in range(image.get_width()):
				if image.get_pixel(x, y).a > 0.5:  # Check alpha value
					points.append(Vector2(x, y) - center_offset)

		# Create a convex polygon from the points
		var convex_points = Geometry2D.convex_hull(points)

		collision_polygon.polygon = convex_points
	else:
		print("Failed to convert texture to image")

func scale_both():
	var original_size = sprite.texture.get_size()
	var scale_factor = fish_size / original_size
	sprite.scale = scale_factor
	collision_polygon.scale = scale_factor

func set_target_bubble(bubble: Area2D):
	target_bubble = bubble
