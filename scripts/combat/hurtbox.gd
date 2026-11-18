extends Area2D
class_name Hurtbox

signal damaged(amount: float, source: Node)

@export var owner_path: NodePath
var owner_node: Node


func _ready() -> void:
	if owner_path:
		owner_node = get_node_or_null(owner_path)
	if owner_node == null:
		owner_node = get_parent()   # domyślnie: rodzic = Player albo Enemy
	
	collision_layer = 16  # bit 5 → warstwa 5 (wartość 2^4 = 16)
	collision_mask = 8    # bit 4 → warstwa 4 (wartość 2^3 = 8)

func take_damage(amount: float, source: Node = null) -> void:
	damaged.emit(amount, source)
	if owner_node and owner_node.has_method("take_damage"):
		owner_node.take_damage(amount)
