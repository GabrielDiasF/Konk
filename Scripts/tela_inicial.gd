extends Control

func _on_jogar_btn_pressed() -> void:
	if not is_inside_tree():
		return
	var tree := get_tree()
	if tree:
		tree.change_scene_to_file("res://Scenes/introducao.tscn")

func _on_sair_btn_pressed() -> void:
	if not is_inside_tree():
		return
	var tree := get_tree()
	if tree:
		tree.change_scene_to_file("res://Scenes/fases.tscn")

func _on_creditos_btn_pressed() -> void:
	if not is_inside_tree():
		return
	var tree := get_tree()
	if tree:
		tree.change_scene_to_file("res://Scenes/creditos.tscn")
