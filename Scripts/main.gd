extends Node

#preload obstacles
var box_scenes = preload("res://scenes/box.tscn")
var ridges_scenes = preload("res://scenes/ridges.tscn")
var stone_scenes = preload("res://scenes/stone.tscn")
var bird_scenes = preload("res://scenes/bird.tscn")
var obstacle_types := [box_scenes, ridges_scenes, stone_scenes, bird_scenes]
var obstacles : Array
var bird_heights := [200, 390]

#game variables
const DINO_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
var difficulty
const MAX_DIFFICULTY : int = 2
var score : float # Changed to float for smooth delta math
const SCORE_MODIFIER : int = 10
var high_score : float # Changed to float
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER : int = 5000
var screen_size : Vector2i
var ground_height : int 
var game_running : bool
var last_obs


@onready var bgm: AudioStreamPlayer = $BGM



#called wehen the node enters the sence tree for the first time.
func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	score = 0 
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0 
	
	#delete all obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	
	$Dino.position = DINO_START_POS
	$Dino.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	
	#reset hud
	$HUD.get_node("StartLabel").show()
	$GameOver.hide()

#called every frame
func _process(delta):
	if game_running:
		#speed up and adjust difficulty using float to prevent jolting
		speed = START_SPEED + score / float(SPEED_MODIFIER)
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		
		#generate obstacles
		generate_obs()
		
		# Calculate frame-independent speed
		var frame_speed = speed * (delta * 60.0)
		
		#move dino and camera using the new frame_speed
		$Dino.position.x += frame_speed   
		$Camera2D.position.x += frame_speed
		$Camera2D.position = $Camera2D.position.round()
		
		score += frame_speed
		show_score()
		
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
			
		# Loop backwards to safely remove items from the array
		for i in range(obstacles.size() - 1, -1, -1):
			var obs = obstacles[i]
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("StartLabel").hide()
			if !bgm.playing:
					bgm.play()
				
			
func generate_obs():
	#generate ground and flying obstacles
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		
		# Check if the generated obstacle is a bird
		if obs_type == bird_scenes:
			obs = obs_type.instantiate()
			var obs_x : int = screen_size.x + score + 100
			var obs_y : int = bird_heights[randi() % bird_heights.size()]
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
			
		# Handle regular ground obstacles (boxes, ridges, stones)
		else:
			for i in range(randi() % max_obs + 1):
				obs = obs_type.instantiate()
				var sprite = obs.get_node("Sprite2D")
				var obs_height = sprite.texture.get_height()
				var obs_scale = sprite.scale
				var obs_x : int = screen_size.x + score + 100 + (i * 100)
				var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
				last_obs = obs
				add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)
	
func hit_obs(body):
	if body.name == "Dino":
		game_over()
	
func show_score():
	# Wrap score in int() for display
	$HUD.get_node("ScoreLabel").text = "SCORE:" + str(int(score) / SCORE_MODIFIER)
	
func check_high_score():
	if score > high_score:
		high_score = score
		# Wrap high_score in int() for display
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(int(high_score) / SCORE_MODIFIER)

func adjust_difficulty():
	# Wrap score in int() for integer division
	difficulty = int(score) / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over():
	check_high_score()
	get_tree().paused = true
	game_running = false
	$GameOver.show()
