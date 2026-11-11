extends Control


func _on_jogar_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/konk.tscn")


func _on_sair_btn_pressed() -> void:
	get_tree().quit()
