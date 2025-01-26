extends Node

@export var obstacle_scene = preload("res://Obstacle.tscn")

var obstacle_timer = 0.0
var spawn_rate_timer = 0.0
var obstacle_spawn_interval = 1.0
var spawn_rate_adjustment_interval: float = 10.0
var spawn_rate_factor_increase: float = 0.9
var spawn_rate_factor_decrease: float = 1.1
var fish_spawn_start_time: float = 60.0

func initialize(spawn_interval, adjustment_interval, factor_increase, factor_decrease, start_time):
	obstacle_spawn_interval = spawn_interval
	spawn_rate_adjustment_interval = adjustment_interval
	spawn_rate_factor_increase = factor_increase
	spawn_rate_factor_decrease = factor_decrease
	fish_spawn_start_time = start_time

func update_timers(delta):
	obstacle_timer += delta
	spawn_rate_timer += delta

func should_spawn_obstacle():
	if obstacle_timer >= obstacle_spawn_interval:
		obstacle_timer = 0.0
		return true
	return false

func should_adjust_spawn_rate(elapsed_time):
	if spawn_rate_timer >= spawn_rate_adjustment_interval:
		spawn_rate_timer = 0.0
		if elapsed_time <= fish_spawn_start_time:
			obstacle_spawn_interval *= spawn_rate_factor_increase
		else:
			obstacle_spawn_interval *= spawn_rate_factor_decrease
		print("Adjusted obstacle spawn rate, new interval: ", obstacle_spawn_interval)
		return true
	return false

func spawn_obstacle(parent):
	var obstacle_instance = obstacle_scene.instantiate()
	var screen_size = parent.get_viewport().size
	obstacle_instance.position = Vector2(randf_range(0, screen_size.x), 0)
	parent.add_child(obstacle_instance)
	obstacle_instance.name = "Obstacle"  # Explicitly set the name after adding to the scene
