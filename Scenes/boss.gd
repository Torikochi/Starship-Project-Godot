extends CharacterBody2D
var start_pos = Vector2.ZERO
var health = 1000.0
var max_health = 1000.0
var score = 5000
signal died
var drop = 100
var bullet_scene = preload("res://Scenes/boss_bullet.tscn")
var torpedo_scene = preload("res://Scenes/torpedo.tscn")
var lazer_scene = preload("res://Scenes/lazer_ray.tscn")
var shield_up = preload("res://Scenes/shield_power_up.tscn")
var target = null
var shielded = true
@onready var screensize  = get_viewport_rect().size
@export var bomb_cooldown = 5
@export var lazer_cooldown = 7
@export var shoot_cooldown = 1
var first_run = true
var dead = false
var drop_num = 3

func start(pos,player):
	target = player
	position = Vector2(pos.x, -pos.y)
	start_pos = pos
	var tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", start_pos.y, 1.4)
	await tween.finished
	$ShootTimer.wait_time = shoot_cooldown
	$BombTimer.wait_time = bomb_cooldown
	$LazerTimer.wait_time = lazer_cooldown
	$HealthBar.max_value = health
	$LazerTimer.start()
	$ShootTimer.start()
	$MoveTimer.start()
	$BombTimer.start()
	show_slowly($HealthBar)
	$ShieldAnimation.play("shield")

func make_looped_tween():
	if dead:
		return
	var displacement = 20
	if first_run:
		var tween = create_tween()
		tween.tween_property(self, "position:x", screensize.x - displacement * 2, 1.5)
		await tween.finished
		tween.stop()
		first_run = false
	else:
		var tween = create_tween()
		tween.tween_property(self, "position:x", screensize.x - displacement * 2, 3)
		await tween.finished
		tween.stop()
	var tween1 = create_tween()
	tween1.tween_property(self, "position:x", 0 + displacement * 2, 3)
	await tween1.finished
	tween1.stop()
	make_looped_tween()

func _on_move_timer_timeout():
	make_looped_tween()


func _on_shoot_timer_timeout():
	if dead:
		return
	var bullet_pos1 = Vector2(position.x-20, position.y + 40)
	var bullet_pos2 = Vector2(position.x+20, position.y + 40)
	var b1 = bullet_scene.instantiate()
	get_tree().root.add_child(b1)
	b1.start(bullet_pos1,target)
	var b2 = bullet_scene.instantiate()
	get_tree().root.add_child(b2)
	b2.start(bullet_pos2,target)
	$NormalShot.play()
	
func explode():
	$DeathSound.play()
	$ShipAnimation.play("destruction")
	$Shield.hide()
	$Engine.hide()
	$Area2D.set_deferred("monitoring", false) 
	$Area2D.set_collision_layer_value(1,false)
	$Area2D.set_collision_mask_value(1,false)
	#The set_deferred() call makes sure to turn off monitoring on the enemy. 
	#This is so that while the enemy is exploding, another bullet can’t hit it again.
	died.emit(score)
	await $ShipAnimation.animation_finished
	queue_free()
	
	
func damaged(dam):
	if not shielded:
		dam = dam*2
	health -= dam
	$HealthBar.value = health
	if health <= 0:
		dead = true
		call_deferred("explode")
	if ((health/max_health)/0.25) < drop_num:
		call_deferred("spawn_drop")
		drop_num -= 1
func start_shield():
	$ShieldAnimation.play("start_shield")
	await $ShieldAnimation.animation_finished
	shielded = true
	$ShieldAnimation.play("shield")

func _on_bomb_timer_timeout():
	if dead:
		return
	var tor_pos1 = Vector2(position.x-30, position.y - 0)
	var tor_pos2 = Vector2(position.x+30, position.y - 0)
	$TorpedoShoot.play()
	var tor1 = torpedo_scene.instantiate()
	var tor2 = torpedo_scene.instantiate()
	get_tree().root.add_child(tor1)
	get_tree().root.add_child(tor2)
	tor1.start(tor_pos1,target)
	tor2.start(tor_pos2,target)

func _on_lazer_timer_timeout():
	if dead:
		return
	$ShieldAnimation.play("charge_lazer")
	await $ShieldAnimation.animation_finished
	$LazerFired.play(1)
	shielded = false
	var lazer_pos = Vector2(0, 155)
	var lazer = lazer_scene.instantiate()
	add_child(lazer)
	lazer.start(lazer_pos)

func show_slowly(node):
	var tween = create_tween()
	tween.tween_property(node, "modulate", Color(1,1,1,1), 0.25)
	await tween.finished

func stop_lazer():
	$LazerFired.stop()

func spawn_drop():
	var rand = randf_range(0,100)
	if rand <= drop:
		var shield = shield_up.instantiate()
		get_tree().root.add_child(shield)
		shield.start(position)
