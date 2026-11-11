extends CharacterBody3D

const SPEED = 5.0

@export_group("Limites da Tela")
@export var limit_left: float = -12.0
@export var limit_right: float = 12.0
@export var limit_bottom: float = -8.0 
@export var limit_top: float = 8.0     

@export_group("Sistema de Tiro")
@export var bullet_scene: PackedScene = preload("res://Scenes/bullet.tscn")
@export var fire_rate: float = 0.15 
var time_since_last_shot: float = 0.0

@onready var muzzle: Node3D = $Muzzle

@onready var fixed_x: float = global_position.x

func _physics_process(delta: float) -> void:
	var dir_z = Input.get_axis("ui_left", "ui_right")
	var dir_y = Input.get_axis("ui_down", "ui_up")

	if dir_z != 0 or dir_y != 0:
		velocity.z = dir_z * SPEED
		velocity.y = dir_y * SPEED
	else:
		velocity.z = move_toward(velocity.z, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	# OBRIGATÓRIO: Esta linha faz o player parar ao bater nas paredes!
	move_and_slide()
		
	velocity.x = 0 

	move_and_slide()

	restrict_to_camera_view()

	time_since_last_shot += delta
	if Input.is_action_pressed("ui_accept") and time_since_last_shot >= fire_rate:
		fire()
		time_since_last_shot = 0.0

func restrict_to_camera_view():
	var camera = get_viewport().get_camera_3d()
	if camera:
		var cam_pos = camera.global_position
		

		global_position.z = clamp(global_position.z, cam_pos.z + limit_left, cam_pos.z + limit_right)
		global_position.y = clamp(global_position.y, cam_pos.y + limit_bottom, cam_pos.y + limit_top)
		

		global_position.x = fixed_x

func fire():
	if not bullet_scene or not muzzle:
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_transform = muzzle.global_transform
	
	
