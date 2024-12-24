extends CharacterBody2D
var start_pos = Vector2.ZERO
var speed = 0
var score = 15
var health = 15
signal died
var drop = 10
var shield_up = preload("res://Scenes/shield_power_up.tscn")
var target = null
var explosion = preload("res://Scenes/explosion_area.tscn")
var player_position = Vector2.ZERO
var target_position = Vector2.ZERO

@onready var screensize  = get_viewport_rect().size

func start(pos,player):
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
	$ExplodeTimer.wait_time = randf_range(3,6)
	
	
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
	call_deferred("spawn_explosion")
	speed = 0
	$NormalArea.set_deferred("monitoring", false) 
	$NormalArea.set_collision_layer_value(1,false)
	$NormalArea.set_collision_mask_value(1,false)
	$AnimationPlayer.call_deferred("play", "explode")
	#The set_deferred() call makes sure to turn off monitoring on the enemy. 
	#This is so that while the enemy is exploding, another bullet can’t hit it again.
	died.emit(score)
	queue_free()
	
func _on_move_timer_timeout():
	speed = 100
	$ExplodeTimer.start()
	

func _process(delta):
	#position.y += speed * delta
	player_position = target.position
	target_position = (player_position - position).normalized()
	
	if position.distance_to(player_position) > 3:
		move_and_collide(target_position * speed * delta)
		look_at(player_position)
	#if position.y > screensize.y + 32:
	#	start(start_pos)

func spawn_explosion():
	var ex = explosion.instantiate()
	get_tree().root.add_child(ex)
	ex.start(position,5)
	

func _on_explode_timer_timeout():
	call_deferred("explode")

func _on_normal_area_area_entered(area):
	if area.is_in_group("bombs"):
		damaged(area.get_damage())
		
