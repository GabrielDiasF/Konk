extends Area3D

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	# Ignora se o laser tocar no próprio inimigo (já que a bala é filha dele)
	if body == get_parent() or body.is_in_group("Inimigo"):
		return
		
	print("DEBUG do Laser: Encostou em -> ", body.name)
	
	# Se tocar no Player, usa a mesma lógica da bala normal
	if body.name == "Player" or body.is_in_group("Player"):
		print("DEBUG do Laser: Laser do inimigo acertou o Player!")
		
		# Procura a cena principal tal como na bala normal
		var main_node = get_tree().current_scene
		
		if main_node:
			if main_node.has_method("perde_vidas"):
				main_node.perde_vidas()
				print("DEBUG do Laser: perde_vidas() chamado com sucesso no main_node!")
			else:
				print("ERRO: O main_node não tem a função 'perde_vidas'!")
