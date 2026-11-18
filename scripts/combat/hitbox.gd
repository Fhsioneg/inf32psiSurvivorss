extends Area2D
class_name Hitbox

@export var damage: float = 10.0
var owner_node: Node = null

func _ready() -> void:
	if owner_node == null:
		owner_node = get_parent()
	area_entered.connect(_on_area_entered)
	collision_layer = 8   # Hitbox
	collision_mask = 16   # Hurtbox

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		area.take_damage(damage, owner_node)
