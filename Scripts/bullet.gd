extends Area3D

@export var speed: float = 30.0
@export var damage: int = 1

func _ready() -> void:
	# Conecta os sinais de colisão por código
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	
	# Conecta automaticamente o Notifier se ele existir como filho
	var notifier = get_node_or_null("VisibleOnScreenNotifier3D")
	if notifier:
		notifier.screen_exited.connect(_on_screen_exited)

func _physics_process(delta: float) -> void:
	# Move a bala para a frente usando o eixo Z da cena
	global_position.z += speed * delta

# Função acionada instantaneamente quando encostar no Inimigo (Area3D)
func _on_area_entered(other_area: Area3D) -> void:
	print("DEBUG: Bala encostou na área -> ", other_area.name)
	
	if other_area.has_method("take_damage"):
		print("DEBUG: Inimigo atingido! Aplicando dano...")
		other_area.take_damage(damage)
	
	# Destrói a bala
	queue_free()

# Função acionada quando encostar em Corpos Físicos (AnimatableBody3D, StaticBody3D, etc.)
func _on_body_entered(body: Node3D) -> void:
	print("DEBUG: Bala bateu no corpo -> ", body.name)
	
	# Se colidir com uma parede ou qualquer corpo físico, destrói a bala
	if body is AnimatableBody3D or body.is_in_group("Paredes"):
		queue_free()

# Função acionada quando o tiro sair do campo de visão da câmera
func _on_screen_exited() -> void:
	print("DEBUG: Bala saiu da tela. Limpando...")
	queue_free()
