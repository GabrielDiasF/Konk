extends Area3D

@export var health: int = 10
@export var atraso_explosao: float = 0.25
@export var onda_choque_scene: PackedScene = preload("res://Scenes/explosao.tscn")

# Ajuste este ângulo no Inspector se o anel ainda ficar deitado ou de lado (ex: Vector3(0, 0, 90) ou Vector3(90, 0, 0))
@export var rotacao_anel_graus: Vector3 = Vector3(0, 0, 90)

@onready var area_deteccao: Area3D = $AreaDeteccao

var ja_explodiu: bool = false

func _ready() -> void:
	if area_deteccao:
		area_deteccao.body_entered.connect(_on_area_deteccao_body_entered)

func _on_area_deteccao_body_entered(body: Node3D) -> void:
	if ja_explodiu:
		return

	if body.name == "Player" or body.is_in_group("Player"):
		ja_explodiu = true
		print("DEBUG: Player se aproximou da bomba!")

		if atraso_explosao > 0.0:
			await get_tree().create_timer(atraso_explosao).timeout

		if is_inside_tree():
			explodir()

func explodir() -> void:
	print("DEBUG: Bomba detonou! Spawnando anel de onda de choque.")

	if onda_choque_scene:
		var onda = onda_choque_scene.instantiate()
		get_tree().current_scene.add_child(onda)
		onda.global_position = global_position
		onda.rotation_degrees = rotacao_anel_graus
	else:
		print("ERRO CRÍTICO: Cena OndaDeChoque não atribuída!")

	queue_free()

func take_damage(amount: int) -> void:
	health -= amount
	print("DEBUG: Bomba levou tiro! Vida: ", health)
	if health <= 0 and not ja_explodiu:
		ja_explodiu = true
		explodir()

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()
