extends Node2D

const SPEED = 60

var direction = 1

@onready var ray_cast_right = $RayCastRight   # проверка стены справа
@onready var ray_cast_left = $RayCastLeft     # проверка стены слева
@onready var ray_cast_down_right = $RayCastDownRight # проверка пола справа
@onready var ray_cast_down_left = $RayCastDownLeft   # проверка пола слева
@onready var animated_sprite = $AnimatedSprite2D

func _process(delta: float) -> void:
	# Проверка стены
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	elif ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false

	# Проверка края платформы
	elif direction == 1 and not ray_cast_down_right.is_colliding():
		# Идём вправо, но впереди нет земли → разворот
		direction = -1
		animated_sprite.flip_h = true
	elif direction == -1 and not ray_cast_down_left.is_colliding():
		# Идём влево, но впереди нет земли → разворот
		direction = 1
		animated_sprite.flip_h = false

	# Двигаем врага
	position.x += direction * SPEED * delta
