extends Area3D

@export var speed: float = 20.0
@export var damage: int = 1

func _ready() -> void:
	# Conectamos o sinal de CORPO (body)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Mantenha o eixo que funciona para o seu jogo (x ou z)
	global_position.z -= speed * delta

func _on_body_entered(body: Node3D) -> void:
	print("DEBUG: A bala encostou no corpo: ", body.name) 
	
	# Confirma se quem bateu foi o Player
	if body.name == "Player": 
		print("DEBUG: Bala do inimigo acertou o Player!")
		
		# Procura a cena principal
		var main_node = get_tree().current_scene
		
		if main_node:
			# MUDANÇA AQUI: Agora chama a função perde_vidas() que vimos no seu print
			if main_node.has_method("perde_vidas"):
				main_node.perde_vidas()
		
		# A bala destrói-se a si mesma
		queue_free()
