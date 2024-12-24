extends Area2D
@export var speed = 150
var target = null
var direction = Vector2.ZERO

func start(pos,player):
	target = player
	position = pos
	direction = (target.global_position - global_position).normalized() 
	look_at(target.global_position)
	 

func _process(delta):
	position += direction * speed * delta




func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_area_entered(area):
	if area.get_parent().name == "Player":
		queue_free()
		area.get_parent().reduce_shield(1)
