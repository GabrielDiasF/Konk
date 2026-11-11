extends Control

func atualizar_textos(integrity: int, lives: int) -> void:
	atualizar_integridade(integrity)
	atualizar_vidas(lives)

func atualizar_integridade(integrity: int) -> void:
	$LabelIntegridade.text = "Integridade: " + str(integrity)

func atualizar_vidas(lives: int) -> void:
	$LabelVida.text = "Vidas: " + str(lives)
