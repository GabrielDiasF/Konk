extends CharacterBody3D

signal morreu

const SPEED = 5.0

@export_group("Atributos do Player")
@export var health: int = 10
@export var tempo_esmagado_para_morrer: float = 0.12

@export_group("Dano de Paredes")
@export var dano_parede_normal: int = 1
@export var cooldown_dano_parede: float = 0.6

@export_group("Inclinacao da Nave")
## Opcional: arraste o nó visual/modelo da nave aqui para girar só o visual sem afetar colisão/muzzle. Se deixar vazio, gira o próprio nó.
@export var visual_node: Node3D
@export var angulo_inclinacao_graus: float = 30.0
@export var velocidade_giro: float = 12.0
@export var inverter_inclinacao: bool = true

@export_group("Limites da Tela")
@export var limit_left: float = -12.0
@export var limit_right: float = 12.0
@export var limit_bottom: float = -80.0 
@export var limit_top: float = 80.0      

@export_group("Sistema de Tiro")
@export var bullet_scene: PackedScene = preload("res://Scenes/bullet.tscn")
@export var fire_rate: float = 0.15 
var time_since_last_shot: float = 0.0

@onready var muzzle: Node3D = $Muzzle
@onready var fixed_x: float = global_position.x

var _tempo_sendo_esmagado: float = 0.0
var _pode_tomar_dano_parede: bool = true
var _morto: bool = false

func _physics_process(delta: float) -> void:
	if _morto or not is_inside_tree():
		return

	var dir_z = Input.get_axis("ui_left", "ui_right")
	var dir_y = Input.get_axis("ui_down", "ui_up")

	if dir_z != 0 or dir_y != 0:
		velocity.z = dir_z * SPEED
		velocity.y = dir_y * SPEED
	else:
		velocity.z = move_toward(velocity.z, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	_atualizar_inclinacao(dir_y, delta)

	move_and_slide()
	if _morto or not is_inside_tree():
		return

	_verificar_dano_paredes()
	if _morto or not is_inside_tree():
		return

	velocity.x = 0 
	move_and_slide()
	if _morto or not is_inside_tree():
		return

	_verificar_dano_paredes()
	if _morto or not is_inside_tree():
		return

	_verificar_esmagamento(delta)
	if _morto or not is_inside_tree():
		return

	restrict_to_camera_view()

	time_since_last_shot += delta
	if Input.is_action_pressed("ui_accept") and time_since_last_shot >= fire_rate:
		fire()
		time_since_last_shot = 0.0

func _atualizar_inclinacao(dir_y: float, delta: float) -> void:
	var alvo: Node3D = visual_node if visual_node else self
	var fator := -1.0 if inverter_inclinacao else 1.0
	var angulo_alvo_rad := deg_to_rad(dir_y * angulo_inclinacao_graus * fator)
	alvo.rotation.x = lerp_angle(alvo.rotation.x, angulo_alvo_rad, clamp(velocidade_giro * delta, 0.0, 1.0))

func _verificar_dano_paredes() -> void:
	if _morto or not is_inside_tree() or not _pode_tomar_dano_parede:
		return

	for i in range(get_slide_collision_count()):
		var colisao := get_slide_collision(i)
		var collider := colisao.get_collider()
		if not collider:
			continue

		if collider is AnimatableBody3D or collider.is_in_group("Paredes"):
			_aplicar_dano_parede(dano_parede_normal)
			break

func _aplicar_dano_parede(quantidade: int) -> void:
	if quantidade <= 0 or _morto or not is_inside_tree():
		return

	_pode_tomar_dano_parede = false
	take_damage(quantidade)

	if cooldown_dano_parede > 0.0 and is_inside_tree():
		await get_tree().create_timer(cooldown_dano_parede).timeout
		if is_inside_tree():
			_pode_tomar_dano_parede = true

func _verificar_esmagamento(delta: float) -> void:
	if _morto or not is_inside_tree():
		return

	var colisoes_laterais: Array[KinematicCollision3D] = []

	for i in range(get_slide_collision_count()):
		var colisao := get_slide_collision(i)
		var collider := colisao.get_collider()
		if not collider:
			continue

		var normal := colisao.get_normal()
		var eh_lateral: bool = abs(normal.z) > abs(normal.y) and abs(normal.z) >= abs(normal.x)
		if not eh_lateral:
			continue

		if collider.is_in_group("Paredes") or collider is AnimatableBody3D or collider.name.to_lower().contains("parede"):
			colisoes_laterais.append(colisao)
			if colisoes_laterais.size() >= 2:
				break

	var encostou_parede_lateral := colisoes_laterais.size() >= 1
	var prensado_limite_lateral := false

	var vp := get_viewport()
	var camera := vp.get_camera_3d() if vp else null
	if camera:
		var cam_pos = camera.global_position
		var margem := 0.05
		if global_position.z <= cam_pos.z + limit_left + margem or global_position.z >= cam_pos.z + limit_right - margem:
			prensado_limite_lateral = true

	# Considera esmagado apenas quando há colisão lateral em parede + limite lateral (ou duas colisões laterais)
	var esta_sendo_esmagado := (encostou_parede_lateral and prensado_limite_lateral) or (colisoes_laterais.size() >= 2)

	if esta_sendo_esmagado:
		_tempo_sendo_esmagado += delta
		if _tempo_sendo_esmagado >= tempo_esmagado_para_morrer:
			print("DEBUG: Esmagado lateralmente! Laterais: ", colisoes_laterais.size(), " | Limite Z: ", prensado_limite_lateral)
			_zerar_vidas_cena_principal()
			die()
	else:
		_tempo_sendo_esmagado = max(0.0, _tempo_sendo_esmagado - delta * 3.0)

func _zerar_vidas_cena_principal() -> void:
	if not is_inside_tree():
		return
	var tree := get_tree()
	if not tree:
		return
	var cena_atual = tree.current_scene
	if cena_atual and "lives" in cena_atual:
		cena_atual.lives = 0

func restrict_to_camera_view():
	if _morto or not is_inside_tree():
		return

	var vp := get_viewport()
	if not vp:
		return

	var camera := vp.get_camera_3d()
	if camera:
		var cam_pos = camera.global_position
		
		global_position.z = clamp(global_position.z, cam_pos.z + limit_left, cam_pos.z + limit_right)
		global_position.y = clamp(global_position.y, cam_pos.y + limit_bottom, cam_pos.y + limit_top)
		global_position.x = fixed_x

func fire():
	if _morto or not is_inside_tree() or not bullet_scene or not muzzle:
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_transform = muzzle.global_transform

# --- SISTEMA DE DANO E TREMOR DA CÂMARA ---

func _atualizar_ui_vida() -> void:
	if not is_inside_tree():
		return
	var tree := get_tree()
	var cena_atual := tree.current_scene if tree else null
	if cena_atual:
		if "lives" in cena_atual:
			cena_atual.lives = health
		if "ui_node" in cena_atual and cena_atual.ui_node:
			if cena_atual.ui_node.has_method("atualizar_vidas"):
				cena_atual.ui_node.atualizar_vidas(health)

func take_damage(amount: int) -> void:
	if _morto:
		return

	health = max(0, health - amount)
	print("Player levou dano! Vida restante: ", health)
	_atualizar_ui_vida()
	
	# Dispara o tremor na câmara atual do jogo
	tremer_cam(0.2, 0.25)
	
	if health <= 0:
		die()

func tremer_cam(intensidade: float = 0.15, duracao: float = 0.3) -> void:
	if _morto or not is_inside_tree():
		return

	var vp := get_viewport()
	var camera := vp.get_camera_3d() if vp else null
	if not camera:
		return
		
	var posicao_original = camera.position
	var tempo_passado = 0.0
	
	while tempo_passado < duracao:
		if _morto or not is_inside_tree() or not is_instance_valid(camera):
			return
		var offset_x = randf_range(-intensidade, intensidade)
		var offset_y = randf_range(-intensidade, intensidade)
		
		camera.position = posicao_original + Vector3(0, offset_y, offset_x)
		
		tempo_passado += get_process_delta_time()
		await get_tree().process_frame
		
	if is_instance_valid(camera):
		camera.position = posicao_original

func die():
	if _morto:
		return
	_morto = true
	print("Player destruído!")
	_atualizar_ui_vida()
	morreu.emit()

	var tree := get_tree()
	var cena_atual := tree.current_scene if tree else null
	if cena_atual and "lives" in cena_atual:
		cena_atual.lives = 0

	if is_inside_tree():
		get_tree().change_scene_to_file("res://Scenes/tela_morte.tscn")

	queue_free()
