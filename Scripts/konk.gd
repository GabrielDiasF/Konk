extends Node3D

@export var integrity: int = 50
@export var lives: int = 10
@export var numero_fase_atual: int = 1
@export var proxima_cena_path: String = "res://Scenes/fases.tscn"

@onready var ui_node = $CanvasLayer/UI

func _ready() -> void:
	if ui_node and ui_node.has_method("atualizar_textos"):
		ui_node.atualizar_textos(integrity, lives)

func perde_integridade() -> void:
	print("DEBUG: A função perde_integridade foi chamada com sucesso!")
	integrity -= 1
	
	# Garante que a integridade nunca será menor do que 0
	integrity = max(0, integrity)
	if ui_node and ui_node.has_method("atualizar_integridade"):
		ui_node.atualizar_integridade(integrity)
	if ui_node and ui_node.has_method("mostrar_feedback_acerto"):
		ui_node.mostrar_feedback_acerto()

func perde_vidas() -> void:
	lives = lives - 1
	if ui_node and ui_node.has_method("atualizar_vidas"):
		ui_node.atualizar_vidas(lives)
	
	if lives < 1:
		get_tree().change_scene_to_file("res://Scenes/tela_morte.tscn")
		return # Interrompe a função imediatamente para não executar o resto após mudar de cena
	
	var tree = get_tree()
	if tree:
		var player = tree.get_first_node_in_group("Player")
		if player and player.has_method("tremer_cam"):
			player.tremer_cam(0.1, 0.15)

func _on_area_passar_body_entered(body: Node3D) -> void:
	if body.name == "Player" or body.is_in_group("Player"):
		GameProgress.concluir_fase(numero_fase_atual)
		get_tree().change_scene_to_file(proxima_cena_path)
