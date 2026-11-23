extends Control

func atualizar_textos(integrity: int, lives: int) -> void:
	atualizar_integridade(integrity)
	atualizar_vidas(lives)

func atualizar_integridade(integrity: int) -> void:
	$LabelIntegridade.text = "Integridade: " + str(integrity)

func atualizar_vidas(lives: int) -> void:
	$LabelVida.text = "Vidas: " + str(lives)


@onready var hit_imgs: Array[TextureRect] = [
	$HitImg1,
	$HitImg2,
	$HitImg3
]

var _geracao_acerto: int = 0

func _ready() -> void:
	for img in hit_imgs:
		if img:
			img.visible = false
	# Se você já tiver algo no _ready() do seu ui.gd, mantenha aqui também

func mostrar_feedback_acerto(duracao: float = 2.5) -> void:
	if hit_imgs.is_empty():
		return

	_geracao_acerto += 1
	var minha_geracao := _geracao_acerto

	for img in hit_imgs:
		if img:
			img.visible = false

	var indice := randi() % hit_imgs.size()
	var escolhida := hit_imgs[indice]
	if escolhida:
		escolhida.visible = true

	await get_tree().create_timer(duracao).timeout

	if minha_geracao == _geracao_acerto and escolhida and escolhida.is_inside_tree():
		escolhida.visible = false
