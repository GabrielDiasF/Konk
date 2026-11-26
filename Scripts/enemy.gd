extends Area3D

@export var health: int = 1

var bullet_scene: PackedScene = preload("res://Scenes/EnemyBullet.tscn")

@onready var raycast: RayCast3D = $RayCast3D
@onready var ponto_de_disparo: Marker3D = $PontoDeDisparo

var pode_atirar: bool = true

func _physics_process(delta: float) -> void:
	if raycast and raycast.is_colliding():
		var objeto_atingido = raycast.get_collider()
		if objeto_atingido != null:
			if objeto_atingido.name == "Player" or objeto_atingido.is_in_group("Player"):
				if pode_atirar:
					atirar()

func atirar() -> void:
	pode_atirar = false
	
	if bullet_scene:
		var nova_bala = bullet_scene.instantiate()
		get_tree().current_scene.add_child(nova_bala)
		nova_bala.global_position = ponto_de_disparo.global_position
		print("DEBUG: O tiro foi instanciado com sucesso!")
	else:
		print("ERRO CRÍTICO: O ficheiro EnemyBullet.tscn não foi encontrado pelo script!")
	
	await get_tree().create_timer(1.0).timeout
	
	# Segurança: garante que o inimigo ainda existe antes de liberar o tiro de novo
	if is_inside_tree():
		pode_atirar = true

func take_damage(amount: int) -> void:
	health -= amount
	print("DEBUG: Inimigo levou tiro!")
	
	if not is_inside_tree():
		return
		
	var tree := get_tree()
	var main_node := tree.current_scene if tree else null
	
	if main_node and main_node.has_method("perde_integridade"):
		main_node.perde_integridade()
	
	if health <= 0:
		die()

func die() -> void:
	queue_free()

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()
