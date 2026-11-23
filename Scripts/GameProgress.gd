extends Node

const SAVE_PATH := "user://progresso.cfg"

# Dicionário: chave = número da fase, valor = true se já foi concluída
var fases_concluidas: Dictionary = {}

func _ready() -> void:
	carregar_progresso()

func fase_esta_desbloqueada(numero_fase: int) -> bool:
	# A Fase 1 sempre começa liberada
	if numero_fase <= 1:
		return true
	# Para ir para a fase N, é preciso ter concluído a fase N - 1
	return bool(fases_concluidas.get(numero_fase - 1, false))

func concluir_fase(numero_fase: int) -> void:
	fases_concluidas[numero_fase] = true
	salvar_progresso()

func salvar_progresso() -> void:
	var config := ConfigFile.new()
	for fase_num in fases_concluidas.keys():
		config.set_value("fases", str(fase_num), fases_concluidas[fase_num])
	config.save(SAVE_PATH)

func carregar_progresso() -> void:
	fases_concluidas.clear()
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		for key in config.get_section_keys("fases"):
			fases_concluidas[int(key)] = bool(config.get_value("fases", key, false))
