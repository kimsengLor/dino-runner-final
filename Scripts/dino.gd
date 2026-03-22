extends CharacterBody2D

const GRAVITY : float = 4200.0
const JUMP_SPEED : float = -1800.0
const FAST_FALL_MULTIPLIER : float = 3.0

func _physics_process(delta):
	# Apply gravity
	velocity.y += GRAVITY * delta

	if is_on_floor():
		if get_parent().game_running:
			$Runcol.disabled = false

			# Jump
			if Input.is_action_just_pressed("ui_accept"):
				velocity.y = JUMP_SPEED
				$JumpSound.pitch_scale = randf_range(0.95, 1.05)
				$JumpSound.play()

			# Duck
			elif Input.is_action_pressed("ui_down"):
				$AnimatedSprite2D.play("duck")
				$Runcol.disabled = true

			# Run
			else:
				$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("jump")

		# Fast fall mechanic
		if Input.is_action_pressed("ui_down"):
			velocity.y += (GRAVITY * FAST_FALL_MULTIPLIER) * delta

	move_and_slide()
