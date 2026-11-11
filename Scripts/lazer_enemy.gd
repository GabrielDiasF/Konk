extends Area3D

@export var health: int = 10
@export var tempo_ligado: float = 2.0    # O laser fica 2 segundos estático na tela
@export var tempo_intervalo: float = 3.0  # Tempo de espera entre os disparos

var bullet_scene: PackedScene = preload("res://Scenes/lazer.tscn") # Ajuste o caminho se necessário
@onready var ponto_de_disparo: Marker3D = $PontoDeDisparo

func _ready() -> void:
	# Aguarda a cena estabilizar antes de começar o ciclo de tiro
	await get_tree().process_frame
	ciclo_de_tiro()

func ciclo_de_tiro() -> void:
	while true:
		# 1. Instancia o laser estático
		var bala_atual = atirar()
		
		# Segurança: se o inimigo foi destruído, interrompe o loop
		if not is_inside_tree():
			break
		
		# 2. Espera 2 segundos com ele parado na tela
		await get_tree().create_timer(tempo_ligado).timeout
		
		# 3. Remove o laser da tela após os 2 segundos
		if is_instance_valid(bala_atual):
			bala_atual.queue_free()
		
		# Segurança novamente antes da próxima espera
		if not is_inside_tree():
			break
			
		# 4. Espera o intervalo antes de criar outro
		await get_tree().create_timer(tempo_intervalo).timeout

func atirar() -> Node:
	if bullet_scene:
		var nova_bala = bullet_scene.instantiate()
		
		# ADICIONA A BALA DIRETAMENTE COMO FILHA DO PRÓPRIO INIMIGO
		add_child(nova_bala)
		
		# Posiciona e orienta exatamente onde está o Marker3D
		if ponto_de_disparo:
			nova_bala.global_transform = ponto_de_disparo.global_transform
		else:
			nova_bala.position = Vector3.ZERO
			
		return nova_bala
	return null

func take_damage(amount: int) -> void:
	health -= amount
	var main_node = get_tree().current_scene
	if main_node and main_node.has_method("perde_integridade"):
		main_node.perde_integridade()
	if health <= 0:
		die()

func die() -> void:
	queue_free()

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()
