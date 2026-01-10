extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func show_message_temp(text,time):
	$Message.text = text
	$Message.show()
	await get_tree().create_timer(time).timeout
	
func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = "Dodge the Creeps!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	
func update_score(score):
	$ScoreLabel.text = str(score)
	
func on_start_button_pressed():
	print("Debug: Start Button pressed")
	$StartButton.hide()
	$Message.hide()
	start_game.emit()

func on_message_timer_timeout():
	$Message.hide()
	
func updateStatusBar(healthPercent, staminaPercent):
	$Health.scale.x = healthPercent
	$Stamina.scale.x = staminaPercent
