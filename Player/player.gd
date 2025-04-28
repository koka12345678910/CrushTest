extends CharacterBody2D
class_name Player

@export var speed: float = 50
@export var health = 100

 # Здоровье врага

var maxspeed = 220  # Максимальная скорость персонажа
var sprint_speed = 270  # Скорость при спринте
var is_sprinting = false  # Флаг для отслеживания спринта
var can_attack = true  # Можно ли атаковать
var attack_cooldown = 0.5  # Время между атаками
var is_damaged: bool = false  # Флаг для предотвращения повторного урона
var is_dead: bool = false

var time_alive: float = 0.0  # Время жизни игрока
@onready var timer_label = $CanvasLayer2/TimerLabel # Отображение секундомера

@onready var anim = $AnimatedSprite2D  # Подключаем анимацию
@onready var animPlayer = $AnimationPlayer
@onready var attack_area = $damage_box/HurtBox  # Подключаем зону атаки (Area2D)
@onready var attack_area2 = $damage_box/HurtBox2
@onready var health_bar = $CanvasLayer/TextureProgressBar
@onready var death_panel = $Death_panel
@onready var kill_counter_label = $CanvasLayer3/KillLabel

func _ready():
	death_panel.hide()
	update_health_bar()
	reset_timer()
	attack_area.monitoring = false  # Зона атаки выключена по умолчанию
	attack_area2.monitoring = false

func _process(delta: float):
	if not can_attack:  # Если атака выполняется, блокируем другие действия
		return
	if is_dead:
		return
	if not is_dead:
		update_timer(delta)
	var movement = movement_vector()
	is_sprinting = Input.is_action_pressed("sprint")
	var direction = movement.normalized()
	var current_speed = maxspeed
	if is_sprinting:
		current_speed = sprint_speed
	velocity = current_speed * direction
	move_and_slide()

	# Анимации движения
	if movement.length() > 0:
		animPlayer.play("Run")
	else:
		animPlayer.play("Idle")
	if movement.x < 0:
		anim.flip_h = true
	elif movement.x > 0:
		anim.flip_h = false

	# Обработка атаки
	if Input.is_action_just_pressed("attack") and can_attack:
		perform_attack()
	elif Input.is_action_just_pressed("attack2") and can_attack:
		perform_attack2()

func movement_vector():
	var movement_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var movement_y = Input.get_action_strength("down") - Input.get_action_strength("up")
	return Vector2(movement_x, movement_y)

func heal(amount: int):
	health += amount
	health = min(health, 100)  # Ограничиваем здоровье 200 HP
	update_health_bar()

func update_health_bar():
	health_bar.value = health  # Устанавливаем текущее здоровье
	health_bar.max_value = 100  # Устанавливаем максимальное значение
	$CanvasLayer/TextureProgressBar/Label.text = str(health)
	if health < 30:
		health_bar.modulate = Color(1, 0, 0)  # Красный
	elif health > 30:
		health_bar.modulate = Color(1, 1, 1)

func perform_attack():
	if can_attack:
		can_attack = false
		attack_area.monitoring = true  # Включаем зону атаки
		animPlayer.play("Attack")
		$AudioStreamPlayer2D2.playing = true
		await get_tree().create_timer(animPlayer.current_animation_length).timeout

		check_attack_collisions()  # Проверяем столкновения
		attack_area.monitoring = false  # Выключаем зону атаки

		await get_tree().create_timer(0.2).timeout
		can_attack = true

func perform_attack2():
	if can_attack:
		can_attack = false
		attack_area2.monitoring = true  # Включаем зону атаки
		animPlayer.play("Attack2")
		$AudioStreamPlayer2D.playing = true
		await get_tree().create_timer(animPlayer.current_animation_length).timeout

		check_attack_collisions_2()  # Проверяем столкновения
		attack_area2.monitoring = false  # Выключаем зону атаки

		await get_tree().create_timer(0.2).timeout
		can_attack = true

func check_attack_collisions():
	for body in attack_area.get_overlapping_bodies():
		if body is Skeleton:
			body.take_damage(100)

func check_attack_collisions_2():
	for body in attack_area2.get_overlapping_bodies():
		if body is Skeleton:
			body.take_damage(100)

func take_damage(amount: int):
	if is_damaged or is_dead:
		return  # Урон уже нанесён
	is_damaged = true
	health -= amount
	health = clamp(health, 0, 100)  # Убедитесь, что здоровье не выходит за пределы
	update_health_bar()  # Обновите интерфейс
	
	if health <= 0:
		die()
	else:
		await get_tree().create_timer(1).timeout  # Задержка перед восстановлением
		is_damaged = false

func update_kill_counter():
	if kill_counter_label:
		kill_counter_label.text = "Kills: %d" % GameStats.kill_count

func die():
	if is_dead:
		return
	
	is_dead = true
	velocity = Vector2.ZERO
	anim.stop()
	animPlayer.play("Death")
	Sdk.show_ad()
	death_panel.show()
	
	GameTimer.update_best_time(time_alive)
	GameStats.save_best_kill_count()
	
	# Передаем статистику в Death_panel
	death_panel.set_best_time(
		GameTimer.get_best_time(), 
		time_alive, 
		GameStats.kill_count, 
		GameStats.best_kill_count
	)
	
	$CollisionShape2D.disabled = true
	
	await get_tree().create_timer(animPlayer.current_animation_length).timeout

func reset_timer():
	time_alive = 0.0
	timer_label.text = "0.00s"

func update_timer(delta: float):
	time_alive += delta
	timer_label.text = "%.3f s" % time_alive 
