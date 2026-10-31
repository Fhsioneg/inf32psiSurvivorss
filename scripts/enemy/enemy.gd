extends CharacterBody2D
class_name EnemyBase

signal enemy_died(position: Vector2)

@export var max_health: float = 30.0
@export var move_speed: float = 80.0
@export var damage: float = 5.0
@export var xp_reward: int = 1

var current_health: float
var player: Node2D = null

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

##func _physics_process(delta: float) -> void:
	##if not is_instance_valid(player):
		##player = get_tree().get_first_node_in_group("player")
		##return
	
	##var direction := global_position.direction_to(player.global_position)
	##velocity = direction * move_speed
	##move_and_slide()
