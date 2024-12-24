extends Area2D
@export var exhaust_time = 2


func start(pos):
	position = pos
	$Timer.wait_time = exhaust_time
	$Timer.start()

func regain_shield():
	get_parent().start_shield()
	

func _on_timer_timeout():
	call_deferred("regain_shield")
	set_deferred("monitoring", false) 
	set_collision_layer_value(1,false)
	set_collision_mask_value(1,false)
	var tween = get_tree().create_tween()
	tween.tween_property(self,"modulate", Color(1,1,0,0),0.25)
	await tween.finished
	get_parent().stop_lazer()
	queue_free()
