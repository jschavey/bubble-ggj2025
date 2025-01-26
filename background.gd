extends Node2D

@export var textures: Array[Texture2D]
@export var tile_size: Vector2 = Vector2(128, 128)  # Adjust the tile size to make them bigger
@export var speed: float = 100.0

var tiles = []

func _ready():
	randomize()
	setup_tiles()

func _process(delta: float):
	scroll_background(delta)

func setup_tiles():
	var screen_size = get_viewport_rect().size
	var rows = ceil(screen_size.y / tile_size.y) + 1  # Add extra row for smooth scrolling
	var cols = ceil(screen_size.x / tile_size.x)

	for row in range(rows):
		var tile_row = []
		for col in range(cols):
			var tile = Sprite2D.new()
			tile.texture = textures[randi() % textures.size()]
			tile.position = Vector2(col * tile_size.x, row * tile_size.y)
			tile.scale = tile_size / tile.texture.get_size()  # Scale the texture to the desired tile size
			tile.rotation_degrees = randi() % 4 * 90  # Apply random rotation (0, 90, 180, or 270 degrees)
			add_child(tile)
			tile_row.append(tile)
		tiles.append(tile_row)

func scroll_background(delta: float):
	for row in tiles:
		for tile in row:
			tile.position.y += speed * delta
			if tile.position.y >= get_viewport_rect().size.y + tile_size.y:
				tile.position.y -= tile_size.y * len(tiles)
