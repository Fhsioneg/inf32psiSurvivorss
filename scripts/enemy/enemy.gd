extends CharacterBody2D
class_name EnemyBase

signal enemy_died(position: Vector2)

@export var max_health: float = 30.0
@export var move_speed: float = 80.0
@export var damage: float = 5.0
@export var xp_reward: int = 1

var current_health: float
var player: Node2D = null
var avoid_side: float = 1.0
var smooth_dir: Vector2 = Vector2.ZERO

@onready var raycast: RayCast2D = $RayCast2D

func _ready() -> void:
	current_health = max_health
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")

func take_damage(amount: float) -> void:
	current_health -= amount
	if current_health <= 0.0:
		_die()

func _die() -> void:
	enemy_died.emit(global_position)
	queue_free()

func _is_path_blocked(dir: Vector2, length: float, half_width: float) -> bool:
	var side := dir.orthogonal() * half_width
	for offset in [Vector2.ZERO, side, -side]:
		raycast.position = offset
		raycast.target_position = dir * length
		raycast.force_raycast_update()
		if raycast.is_colliding():
			return true
	return false

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		return

	var to_player := global_position.direction_to(player.global_position)
	if smooth_dir == Vector2.ZERO:
		smooth_dir = to_player

	var ray_length := 120.0
	var body_half_width := 70.0 # Połowa kolizji 128x128 (64 px) + 6 px zapasu

	if _is_path_blocked(to_player, ray_length, body_half_width):
		var chosen_dir := to_player
		var angles: Array[float] = []

		for step in range(1, 11):
			angles.append(step * (PI / 12.0) * avoid_side)
		for step in range(1, 11):
			angles.append(step * (PI / 12.0) * -avoid_side)

		for angle in angles:
			var test_dir := to_player.rotated(angle)
			if not _is_path_blocked(test_dir, ray_length, body_half_width):
				avoid_side = sign(angle)
				chosen_dir = test_dir
				break

		if is_on_wall():
			smooth_dir = chosen_dir
		else:
			smooth_dir = smooth_dir.lerp(chosen_dir, 14.0 * delta).normalized()
	else:
		var next_dir := smooth_dir.lerp(to_player, 6.0 * delta).normalized()
		if not _is_path_blocked(next_dir, ray_length * 0.8, body_half_width):
			smooth_dir = next_dir

	raycast.position = Vector2.ZERO
	raycast.target_position = smooth_dir * ray_length

	velocity = smooth_dir * move_speed
	move_and_slide()
