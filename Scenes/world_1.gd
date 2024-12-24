extends Node2D
var enemy = preload("res://Scenes/enemy.tscn")
var elite = preload("res://Scenes/elite_enemy.tscn")
var boss = preload("res://Scenes/boss.tscn")
var score = 0
@onready var start_button = $CanvasLayer/CenterContainer/Start
@onready var game_over = $CanvasLayer/CenterContainer/GameOver
var total_enemy = 0
var wave = 0
var player = null
@onready var screensize  = get_viewport_rect().size


func _ready():
	#spawn_enemies()
	player = $Player
	game_over.hide() 
	start_button.show()
	$"BGM Into The Spaceship".play()
	
func _input(event):
	if event.is_action_pressed("shoot") && player.isDead():
		new_game()

func spawn_enemies(wave_num):
	if wave_num == 1:
		spawn_boss()
		return
	elif wave_num == 2:
		win_game()
		return
	for x in range(9):
		for y in range(3):
			var e = null
			var pos = Vector2(x * (16 + 8) + 24, 16 * 4 + y * 16)
			if y == 0 && x % 2 ==0:
				e = elite.instantiate()
				add_child(e)
				e.died.connect(_on_elite_enemy_died)
			else:
				e = enemy.instantiate()
				add_child(e)
				e.died.connect(_on_enemy_died)
			e.start(pos, player)
			total_enemy += 1
	wave += 1

func spawn_boss():
	var b = boss.instantiate()
	add_child(b)
	b.died.connect(_on_boss_died)
	b.start(Vector2(screensize.x/2, 90), player)
	

func _on_enemy_died(value):
	score += value
	total_enemy -= 1
	$CanvasLayer/UI.update_score(score)
	if total_enemy <= 0:
		total_enemy = 0
		spawn_enemies(wave)
		
func _on_elite_enemy_died(value):
	score += value
	total_enemy -= 1
	$CanvasLayer/UI.update_score(score)
	if total_enemy <= 0:
		total_enemy = 0
		spawn_enemies(wave)
		
func _on_boss_died(value):
	score += value
	total_enemy -= 1
	$CanvasLayer/UI.update_score(score)
	win_game()

func new_game():
	start_button.hide()
	game_over.hide()
	score = 0
	$"BGM Into The Spaceship".stop()
	$"BGM Goodbye Sweet Alien".stop()
	$"BGM Satellite Interruption".play()
	$CanvasLayer/UI.update_score(score)
	player.start()
	wave = 0
	spawn_enemies(wave)
	
func _on_start_pressed():
	start_button.hide()
	new_game()

func win_game():
	player.win_change(true)
	$"BGM Into The Spaceship".stop()
	$"BGM Satellite Interruption".stop()
	await get_tree().create_timer(2).timeout
	$"Finish Sound".play()
	game_over.show()
	await get_tree().create_timer(2).timeout
	$"BGM Goodbye Sweet Alien".play()
	game_over.hide()
	player.win_change(false)
	player.dead_change(true)
	start_button.show()

func _on_player_died():
	get_tree().call_group("enemies", "queue_free")
	get_tree().call_group("bullets", "queue_free")
	$"BGM Into The Spaceship".stop()
	$"BGM Satellite Interruption".stop()
	$"BGM Goodbye Sweet Alien".play()
	game_over.show()
	await get_tree().create_timer(2).timeout
	game_over.hide()
	start_button.show()
	if not player.isDead():
		start_button.hide()


func _on_bgm_satellite_interruption_finished():
	$"BGM Satellite Interruption".play(1)


func _on_bgm_into_the_spaceship_finished():
	$"BGM Into The Spaceship".play()


func _on_bgm_goodbye_sweet_alien_finished():
	$"BGM Goodbye Sweet Alien".play()
