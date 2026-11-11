extends Control


func _on_btn_ta_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/konk.tscn")


func _on_btn_tela_inicial_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/tela_inicial.tscn")


func _on_btn_sair_pressed() -> void:
	get_tree().quit()
