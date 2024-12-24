extends CharacterBody2D
var start_pos = Vector2.ZERO
var speed = 0
var score = 5
var health = 5
signal died
var drop = 5
var bullet_scene = preload("res://Scenes/enemy_bullet.tscn")
var shield_up = preload("res://Scenes/shield_power_up.tscn")
var target = null

@onready var screensize  = get_viewport_rect().size

func start(pos, player):
	target = player
	speed = 0
	position = Vector2(pos.x, -pos.y)
	start_pos = pos
	await get_tree().create_timer(randf_range(0.25, 0.55)).timeout
	var tween = create_tween().set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position:y", start_pos.y, 1.4)
	await tween.finished
	$MoveTimer.wait_time = randf_range(5, 20)
	$MoveTimer.start()
	$ShootTimer.wait_time = randf_range(4, 20)
	$ShootTimer.start()
	
func damaged(dam):
	health -= dam
	if health <= 0:
		call_deferred("spawn_drop")
		call_deferred("explode")
		

func spawn_drop():
	var rand = randf_range(0,100)
	if rand <= drop:
		var shield = shield_up.instantiate()
		get_tree().root.add_child(shield)
		shield.start(position)
		
func explode():
	$DeadSound.play()
	speed = 0
	$AnimationPlayer.play("explode")
	$Area2D.set_deferred("monitoring", false) 
	$Area2D.set_collision_layer_value(1,false)
	$Area2D.set_collision_mask_value(1,false)
	#The set_deferred() call makes sure to turn off monitoring on the enemy. 
	#This is so that while the enemy is exploding, another bullet can’t hit it again.
	died.emit(score)
	await $AnimationPlayer.animation_finished
	queue_free()
	
func _on_move_timer_timeout():
	speed = randf_range(75, 100)


func _on_shoot_timer_timeout():
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start(position)
	$ShootTimer.wait_time = randf_range(4, 20)
	$ShootTimer.start()
	$ShootingSound.play()
	
func _process(delta):
	position.y += speed * delta
	if position.y > screensize.y + 32:
		start(start_pos,target)





func _on_area_2d_area_entered(area):
	if area.is_in_group("bombs"):
		damaged(area.get_damage())
