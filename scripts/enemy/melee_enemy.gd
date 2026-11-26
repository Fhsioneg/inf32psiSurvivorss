extends EnemyBase

@export var attack_cooldown: float = 0.5  # jak często gryzie, gdy siedzi na graczu

@onready var hitbox: Hitbox = $Hitbox
var _attack_timer: float = 0.0

func _ready() -> void:
	super._ready() # uruchamia _ready() z EnemyBase (HP, grupa, NavigationAgent2D)
	hitbox.damage = damage
	hitbox.owner_node = self

func _physics_process(delta: float) -> void:
	super._physics_process(delta) # uruchamia ruch po labiryncie z EnemyBase
	
	# Obsługa ciągłego kontaktu (gdy wróg cały czas stoi w graczu)
	if _attack_timer > 0.0:
		_attack_timer -= delta
	else:
		for area in hitbox.get_overlapping_areas():
			if area is Hurtbox and area.owner_node and area.owner_node.is_in_group("player"):
				area.take_damage(damage, self)
				_attack_timer = attack_cooldown
				break
