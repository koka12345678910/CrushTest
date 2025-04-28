extends CharacterBody2D
class_name Skeleton

@export var speed: float = 50
@export var health = 100 # Здоровье врага
@export var attack_damage: int = 30  # Урон врага
@export var attack_cooldown: float = 1.5 # Задержка между атаками
@export var player: Node

var is_chasing: bool = false  # Флаг, преследует ли враг игрока
var is_damaged: bool = false
var is_dead: bool = false
var can_attack: bool = true  # Можно ли атаковать

@onready var anim = $AnimatedSprite2D
@onready var animSkelet = $AnimationSkelet
@onready var attack_area = $damage_box/HurtBox # Ссылка на зону атаки
@onready var attack_timer = $Timer# Таймер для атаки

func _ready():
	add_to_group("enemies")
	attack_timer.connect("timeout", Callable(self, "_on_attack_timer_timeout"))

func _process(_delta):
	if not can_attack:
		return
	
	if is_dead:
		return
	
	if is_chasing and player:
		# Движение врага к игроку
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		animSkelet.play("walk")

		# Устанавливаем направление анимации
		if direction.x < 0:
			anim.flip_h = true
		else:
			anim.flip_h = false

	else:
		velocity = Vector2.ZERO
		animSkelet.play("idle")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		is_chasing = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_chasing = false

func _on_stop_or_move_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		is_chasing = false

func _on_stop_or_move_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_chasing = true

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body is Player and can_attack:
		player = body
		attack_area.monitoring = true
		attack()
		await get_tree().create_timer(1.1).timeout
		is_chasing = true
		can_attack = true

func attack():
	if player and attack_area.get_overlapping_bodies().has(player):
		can_attack = false
		animSkelet.play("attack")  # Проигрываем анимацию атаки
		await get_tree().create_timer(animSkelet.current_animation_length).timeout
		
		# Проверяем, всё ли ещё игрок в зоне атаки
		if player and attack_area.get_overlapping_bodies().has(player):
			print("Враг ударил игрока!")
			player.take_damage(25)
			attack_timer.start()  # Перезапускаем таймер для повторного удара
		else:
			print("Игрок покинул зону, атака прекращается.")
			attack_timer.stop()

# Если игрок остается в зоне атаки, наносим урон через интервалы
func _on_attack_timer_timeout():
	if player and attack_area.get_overlapping_bodies().has(player):
		attack()
	else:
		attack_timer.stop()  # Останавливаем таймер, если игрок ушел

func _on_hurt_box_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null

func take_damage(amount: int):
	if is_damaged or is_dead:
		return  # Урон уже нанесён
	is_damaged = true
	health -= amount
	print("Здоровье врага:", health)
	if health <= 0:
		die()
	else:
		await get_tree().create_timer(1).timeout  # Небольшая задержка перед восстановлением
		is_damaged = false

func die():
	if is_dead:
		return
	
	is_dead = true
	velocity = Vector2.ZERO
	animSkelet.stop()
	animSkelet.play("death")
	
	attack_area.monitoring = false
	$CollisionShape2D.disabled = true
	
	GameStats.increment_kills()  # Увеличиваем счётчик убийств
	var player = get_tree().get_root().get_node("Level/Player")  # Укажите правильный путь к игроку
	if player:
		player.update_kill_counter()
	else:
		print("Ошибка: Игрок не найден!")
	
	await get_tree().create_timer(animSkelet.current_animation_length).timeout
	queue_free()  # Удаляем врага
