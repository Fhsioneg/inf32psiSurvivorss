extends CharacterBody2D

signal health_changed(current: float, max_health: float)
signal died
signal level_up(new_level: int)
signal xp_gained(amount: int)

@export var max_health: float = 100.0
@export var move_speed: float = 150.0
@export var pickup_range: float = 50.0

var current_health: float
var xp: int = 0
var level: int = 1
var xp_to_next_level: int = 10

# system ulepszeń (na później)
var owned_upgrades: Dictionary = {}
var weapons: Dictionary = {}

func _ready() -> void:
	current_health = max_health
	add_to_group("player")
	health_changed.emit(current_health, max_health)

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * move_speed
	move_and_slide()

func take_damage(amount: float) -> void:
	current_health = max(current_health - amount, 0.0)
	health_changed.emit(current_health, max_health)
	if current_health <= 0.0:
		died.emit()

func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

func add_xp(amount: int) -> void:
	xp += amount
	xp_gained.emit(amount)
	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		level += 1
		xp_to_next_level = int(xp_to_next_level * 1.4)
		level_up.emit(level)
