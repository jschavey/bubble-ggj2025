extends Node

func update_score_label(score_label, total_score):
	score_label.text = "Score: " + str(total_score)  # Update the score label text

func update_high_score_label(high_score_label, high_score):
	high_score_label.text = "High Score: " + str(high_score)  # Update the high score label text

func center_score_label(score_label):
	var screen_width = score_label.get_viewport().size.x
	var label_width = score_label.size.x
	score_label.position.x = (screen_width - label_width) / 2

func display_game_over(score_label):
	score_label.text += "\nGame Over!"  # Display game over message

func setup_reset_button(reset_button, main_script):
	reset_button.connect("pressed", Callable(main_script, "_on_ResetButton_pressed"))  # Connect the reset button
	reset_button.visible = false  # Initially hide the reset button

func show_reset_button(reset_button):
	reset_button.visible = true  # Show the reset button

func hide_reset_button(reset_button):
	reset_button.visible = false  # Hide the reset button
