extends AnimatableBody3D

func _ready() -> void:
	iniciar_movimento()

func iniciar_movimento() -> void:
	# Cria o tween configurado estritamente para o ciclo de física
	var tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_loops() # Faz com que o movimento se repita indefinidamente
	
	# Exemplo: move-se 5 unidades no eixo Z (ajuste o valor e o eixo conforme o seu jogo)
	tween.tween_property(self, "position:z", 5.0, 2.0)
	# Retorna à posição original após 2 segundos
	tween.tween_property(self, "position:z", 0.0, 2.0)
