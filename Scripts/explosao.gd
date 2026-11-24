extends Area3D

@export var escala_inicial: float = 0.2
@export var escala_maxima: float = 7.0
@export var velocidade_expansao: float = 11.5
@export var raio_limite: float = 0.0 # Se maior que 0, destrói ao passar dessa distância da origem
@export var dano_parede: int = 999

var posicao_inicial: Vector3
var ja_acertou_player: bool = false

func _ready() -> void:
	posicao_inicial = global_position
	scale = Vector3.ONE * escala_inicial
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	var nova_escala = scale.x + velocidade_expansao * delta
	scale = Vector3.ONE * nova_escala

	# Destrói ao atingir a escala máxima
	if nova_escala >= escala_maxima:
		queue_free()
		return

	# Destrói se sair do raio limite configurado
	if raio_limite > 0.0 and global_position.distance_to(posicao_inicial) >= raio_limite:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if not body:
		return

	print("DEBUG BOMBA TOCOU EM: ", body.name, " | Tipo: ", body.get_class(), " | Tem take_damage? ", body.has_method("take_damage"))

	var eh_player := body.name == "Player" or body.is_in_group("Player")

	# Aplica dano de parede apenas em corpos que não sejam o Player
	if not eh_player and body.has_method("take_damage"):
		body.take_damage(dano_parede)
		print("DEBUG: Parede quebrada pela bomba -> ", body.name)

	if ja_acertou_player:
		return

	if eh_player:
		ja_acertou_player = true
		var main_node = get_tree().current_scene
		if main_node and main_node.has_method("perde_vidas"):
			main_node.perde_vidas()
		print("DEBUG: Player encostou na explosão e perdeu vida!")
