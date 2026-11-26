extends CharacterBody2D
class_name EnemyBase

signal enemy_died(position: Vector2)

@export var max_health: float = 30.0
@export var move_speed: float = 80.0
@export var damage: float = 5.0
@export var xp_reward: int = 1
@export var retarget_interval: float = 0.25  # jak często odświeżać cel

var current_health: float
var player: Node2D = null
var _retarget_timer: float = 0.0

@onready var agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	current_health = max_health
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")
	
	agent.path_desired_distance = 2.0
	agent.target_desired_distance = 4.0
	# agent.avoidance_enabled = true  # włącz, gdy wielu wrogów

func take_damage(amount: float) -> void:
	current_health -= amount
	if current_health <= 0.0:
		_die()

func _die() -> void:
	enemy_died.emit(global_position)
	queue_free()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		return
	
	_retarget_timer -= delta
	if _retarget_timer <= 0.0:
		_retarget_timer = retarget_interval
		agent.target_position = player.global_position
	
	if agent.is_navigation_finished():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var next_pos := agent.get_next_path_position()
	var direction := global_position.direction_to(next_pos)
	velocity = direction * move_speed
	move_and_slide()
