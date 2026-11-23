extends AnimatableBody3D

@export var health: int = 10
@export var efeito_quebra_scene: PackedScene

var _quebrada: bool = false

func take_damage(amount: int) -> void:
	if _quebrada:
		return

	health -= amount
	if health <= 0:
		quebrar()

func quebrar() -> void:
	if _quebrada:
		return
	_quebrada = true

	if efeito_quebra_scene:
		var efeito = efeito_quebra_scene.instantiate()
		get_tree().current_scene.add_child(efeito)
		if "global_position" in efeito:
			efeito.global_position = global_position

	queue_free()
