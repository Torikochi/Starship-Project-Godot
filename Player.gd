extends CharacterBody2D
@export var cooldown = 0.25
@export var buff_time = 4
@export var bullet_scene : PackedScene
@export var speed = 150
@onready var screensize = get_viewport_rect().size
var buff_cooldown = cooldown/2
var can_shoot = true
var dead = false
var in_time = 1
var invincible = false
var win = false
signal died
signal shield_changed

@export var max_shield = 10
var shield = max_shield:
	set = set_shield

func isDead():
	return dead

func _ready():
	hide()
	dead = true

func start():
	position = Vector2(screensize.x / 2, screensize.y / 2)
	can_shoot = true
	dead = false
	$"Gun Cooldown".wait_time = cooldown
	$Buff.wait_time = buff_time
	$Invincibility_Timer.wait_time = in_time
	set_shield(max_shield)
	show()

func shoot():
	if not can_shoot or dead or win:
		return
	can_shoot = false
	$"Gun Cooldown".start()
	$ShootingSound.play()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start(position + Vector2(0, -8))
	


func _process(delta):
	if dead:
		return
	if win:
		go_up(delta)
		play_animation(Vector2.ZERO)
		return
	var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	play_animation(input)
	position += input * speed * delta
	position = position.clamp(Vector2(8, 8), screensize - Vector2(8, 8))

func play_animation(vector):
	if vector.x > 0:
		$Ship.frame = 2
		$Ship/Booster.animation = "right"
	elif vector.x < 0:
		$Ship.frame = 0
		$Ship/Booster.animation = "left"
	else:
		$Ship.frame = 1
		$Ship/Booster.animation = "forward"
	if Input.is_action_pressed("shoot"):
		shoot()


func _on_gun_cooldown_timeout():
	can_shoot = true
	
func set_shield(value):
	shield = min(max_shield, value)
	shield_changed.emit(max_shield, shield)
	if shield <= 0:
		hide()
		dead = true
		died.emit()
		
func reduce_shield(value):
	if invincible:
		return
	$Damaged.play()
	set_shield(shield - value)
	iframe()

func increase_shield(value):
	if shield == max_shield:
		$"Gun Cooldown".wait_time = buff_cooldown
		$Buff.start()
		return
	set_shield(shield + value)
	

func _on_area_2d_area_entered(area):
	if dead or win:
		return
	if area.is_in_group("lazer"):
		reduce_shield(3)
	if area.is_in_group("enemies") and area.is_in_group("boss"):
		reduce_shield(3) 
	elif area.is_in_group("enemies"):
		if not invincible:
			area.get_parent().explode()
		reduce_shield(3) 
		
		
	

func _on_area_2d_area_exited(area):
	if invincible:
		return
	if area.is_in_group("bombs"):
		reduce_shield(area.get_damage()) 

func iframe():
	invincible = true
	$Invincibility_Timer.start()
	blinking()
	
func go_up(delta):
	position.y += 1 * (-speed * delta)

func win_change(value):
	win = value

func dead_change(value):
	dead = value

func blinking():
	for x in range(2):
		var tween = get_tree().create_tween()
		tween.tween_property(self,"modulate", Color(1,1,1,0.5),0.25)
		await tween.finished
		var tween2 = get_tree().create_tween()
		tween2.tween_property(self,"modulate", Color(1,1,1,1),0.25)
		await tween2.finished

func _on_invincibility_timer_timeout():
	invincible = false

func play_power_up_sound():
	$PowerUp.play()


func _on_buff_timeout():
	$"Gun Cooldown".wait_time = cooldown
