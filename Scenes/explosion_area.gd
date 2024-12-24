extends Area2D
var damage = 5
var size = 0

func start(pos, mod_damage):
	$Sound.play()
	damage = mod_damage
	position = pos
	$AnimationPlayer.play("explode")
	$Timer.start()
	await $AnimationPlayer.animation_finished
	queue_free()

func get_damage():
	return damage

func set_damage(dam):
	damage = dam


func _on_timer_timeout():
	set_deferred("monitoring", false) 
	set_collision_layer_value(1,false)
	set_collision_mask_value(1,false)
