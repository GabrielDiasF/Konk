extends Control

@export var cenas_das_fases: Dictionary = {
	1: "res://Scenes/konk.tscn",
	2: "res://Scenes/konk2.tscn",
	3: "res://Scenes/fase_3.tscn"
}

@onready var botoes_fases: Dictionary = {
	1: $BotaoFase1,
	2: $BotaoFase2,
	3: $BotaoFase3
}

func _ready() -> void:
	atualizar_botoes()

func atualizar_botoes() -> void:
	for fase_num in botoes_fases.keys():
		var botao: Button = botoes_fases[fase_num]
		if not botao:
			continue
		var desbloqueada := GameProgress.fase_esta_desbloqueada(fase_num)
		botao.disabled = not desbloqueada
		botao.text = "Fase %d" % fase_num if desbloqueada else "Fase %d (Bloqueada)" % fase_num
		if not botao.pressed.is_connected(_on_botao_fase_pressed):
			botao.pressed.connect(_on_botao_fase_pressed.bind(fase_num))

func _on_botao_fase_pressed(fase_num: int) -> void:
	if not is_inside_tree():
		return
	if not GameProgress.fase_esta_desbloqueada(fase_num):
		return
	var caminho: String = cenas_das_fases.get(fase_num, "")
	if caminho == "" or not ResourceLoader.exists(caminho):
		print("ERRO: Caminho da fase %d inválido ou cena inexistente: %s" % [fase_num, caminho])
		return
	var tree := get_tree()
	if tree:
		tree.change_scene_to_file(caminho)
