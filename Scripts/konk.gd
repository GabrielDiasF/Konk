extends Node3D

@export var integrity: int = 100
@export var lives: int = 10


@onready var ui_node = $CanvasLayer/UI

func _ready() -> void:

	if ui_node.has_method("atualizar_textos"):
		ui_node.atualizar_textos(integrity, lives)

func perde_integridade() -> void:
	print("DEBUG: A função perde_integridade foi chamada com sucesso!")
	integrity -= 1
	
	# Garante que a integridade nunca será menor do que 0
	integrity = max(0, integrity)
	

	if ui_node and ui_node.has_method("atualizar_integridade"):
		ui_node.atualizar_integridade(integrity)

func perde_vidas() -> void:
	lives = lives - 1
	if ui_node and ui_node.has_method("atualizar_vidas"):
		ui_node.atualizar_vidas(lives)
	if lives < 1:
		get_tree().change_scene_to_file("res://Scenes/tela_morte.tscn")


func _on_area_passar_body_entered(body: Node3D) -> void:
	get_tree().change_scene_to_file("res://Scenes/tela_vitoria.tscn")
