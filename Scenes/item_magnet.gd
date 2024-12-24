extends Area2D


func _on_body_exited(body):
	if body.is_in_group("items"):
		body.set_linear_velocity(Vector2.ZERO)
		body.set_collision_layer_value(3,true)
		body.set_collision_mask_value(3,true)
		#body.set_collision_layer_value(2,false)
		#body.set_collision_mask_value(2,false)

func _on_body_entered(body):
	if body.is_in_group("items"):
		body.set_attracted(true)
