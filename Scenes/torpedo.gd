extends CharacterBody2D
var start_pos = Vector2.ZERO
var speed = 100
var score = 0
var health = 2 
var target = null
var explosion = preload("res://Scenes/explosion_area.tscn")
@export var explode_time = 3
@onready var screensize  = get_viewport_rect().size
var player_position = Vector2.ZERO
var target_position = Vector2.ZERO

func start(pos,player):
	target = player
	position = Vector2(pos.x, pos.y)
	$ExplodeTimer.wait_time = explode_time
	$ExplodeTimer.start()
	
func damaged(dam):
	health -= dam
	if health <= 0:
		call_deferred("explode")
		
func explode():
	call_deferred("spawn_explosion")
	speed = 0
	$Area2D.set_deferred("monitoring", false) 
	$Area2D.set_collision_layer_value(1,false)
	$Area2D.set_collision_mask_value(1,false)
	#The set_deferred() call makes sure to turn off monitoring on the enemy. 
	#This is so that while the enemy is exploding, another bullet can’t hit it again.
	queue_free()
	

	
func _process(delta):
	player_position = target.position
	target_position = (player_position - position).normalized()
	
	if position.distance_to(player_position) > 3:
		move_and_collide(target_position * speed * delta)
		look_at(player_position)
	#position.y += speed * delta
	#look_at(target.global_position)
	#self.position = lerp(self.position,target.global_position,speed)
	#if position.y > screensize.y + 32:
	#	start(start_pos)

func spawn_explosion():
	var ex = explosion.instantiate()
	get_tree().root.add_child(ex)
	ex.start(position,2)
	

func _on_explode_timer_timeout():
	call_deferred("explode")


func _on_area_2d_area_entered(area):
	if area.is_in_group("bombs"):
		damaged(area.get_damage())
