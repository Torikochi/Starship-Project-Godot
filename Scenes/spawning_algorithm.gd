extends Node2D
@onready var screensize  = get_viewport_rect().size
var enemy = preload("res://Scenes/enemy.tscn")
var elite = preload("res://Scenes/elite_enemy.tscn")
var boss = preload("res://Scenes/boss.tscn")
var list1 = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
var wave = 0
var total_enemy = 0
var score = 0
var player = null
func spawn_enemy(list,row,column,formation):
	var midx = screensize.x/2 
	for x in range(row):
		var side = cos((x%2)*PI)
		var alignment = 2*row%2
		print(x * alignment + 12 + midx)
		for y in range(column):
			var pos = Vector2.ZERO
			if list[x+x*y] == 1:
				pos = Vector2((x/2) * 12 * side + midx, 16 * 4 + y * 16)
			var e = null	
			e = enemy.instantiate()
			add_child(e)
			e.died.connect(_on_enemy_died)
			e.start(pos, player)
			total_enemy += 1
	
	'''
	for x in range(row):
		for y in range(column):
			var e = null
			var alignment = cos((x%2)*PI)
			var pos = Vector2(x * (16 + 8) * alignment + 24 + midx, 16 * 4 + y * 16)
			if y == 0 && x % 2 ==1:
				e = elite.instantiate()
				add_child(e)
				e.died.connect(_on_elite_enemy_died)
			else:
				e = enemy.instantiate()
				add_child(e)
				e.died.connect(_on_enemy_died)
			e.start(pos, player)
			total_enemy += 1
'''
func _ready():
	player = $"Temporary player"
	#spawn_enemy(list1,4,4)

func spawn_enemies(wave_num):
	if wave_num >= 4:
		spawn_boss()
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
	wave_num += 1

func _on_enemy_died(value):
	score += value
	total_enemy -= 1
	#get_parent().up_score(score)
	if total_enemy <= 0:
		total_enemy = 0
		spawn_enemies(wave)
		
func _on_elite_enemy_died(value):
	score += value
	total_enemy -= 1
	#get_parent().up_score(score)
	if total_enemy <= 0:
		total_enemy = 0
		spawn_enemies(wave)
		
func _on_boss_died(value):
	score += value
	total_enemy -= 1
	#get_parent().up_score(score)
	
func spawn_boss():
	var b = boss.instantiate()
	add_child(b)
	b.died.connect(_on_boss_died)
	b.start(Vector2(screensize.x/2, 90), player)
