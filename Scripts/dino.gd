extends CharacterBody2D

const GRAVITY : int = 4200
const JUMP_SPEED : int = -1800

var was_in_air := false

func _physics_process(delta):
	# Apply gravity
	velocity.y += GRAVITY * delta

	var on_floor_now = is_on_floor()

	if on_floor_now:
		if not get_parent().game_running:
			pass
		else:
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
			velocity.y += (GRAVITY * 3) * delta

	move_and_slide()
