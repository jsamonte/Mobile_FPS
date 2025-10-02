extends CharacterBody3D

signal health_changed(health_value)

const SPEED = 4.0
const SPRINT = 2.0
const LOOK_SPEED = 0.04
const JUMP_VELOCITY = 10.0
const BULLET = preload("res://Bullet.tscn")

var fallMultiplier = 2 
var lowJumpMultiplier = 10 
var jumpVelocity = 20 #Jump height
var gravity = 5
var health = 5
# Get the gravity from the project settings to be synced with RigidBody nodes.

@onready var player = $"."
@onready var camera = $Neck/Camera3D
@onready var body := $Neck
@onready var animation_player = $AnimationPlayer
@onready var muzzle_flash = $Neck/Camera3D/pistol_model/MuzzleFlash
@onready var ray_cast = $Neck/Camera3D/RayCast3D
@onready var pistol = $Neck/Camera3D/pistol_model/MuzzleFlash
@onready var floor_check = $FloorCheck


func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	
func _ready():
	if not is_multiplayer_authority(): return
	camera.current = true
		

func _process(_delta):
	if not is_multiplayer_authority(): return
	# Add the gravity.
	if not is_on_floor():
		velocity.y -=  gravity
		move_and_slide()     
		
	#Fall Physics
	#f velocity.y < 0: #Player is falling
		
	
	if Input.is_action_just_pressed("jump"):
		#animation_player.play("jump") 
		if not floor_check.is_colliding():
			velocity.y += gravity * jumpVelocity #Normal Jump action
			move_and_slide()

	#Handle shooting.
	if Input.is_action_just_pressed("shoot") and animation_player.current_animation != "shoot":
		shoot_effects.rpc()
		shoot.rpc()
		#if ray_cast.is_colliding():
		#	var hit_player = ray_cast.get_collider()
		#	print(hit_player)
		#	hit_player.damage_recieved.rpc_id(hit_player.get_multiplayer_authority())

	#get view
	var view_point = $UI/RightJoyStick.get_viewpoint()
	var view_direction = Vector3(view_point.x, 0, view_point.y)
	if view_direction:
		body.rotate_y(- view_direction.x * LOOK_SPEED)
		camera.rotate_x(- view_direction.z * LOOK_SPEED)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
	else:
		body.rotate_y(view_direction.y * 0)
		camera.rotate_x(view_direction.x * 0)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = $UI/LeftJoyStick.get_velocity()
	var direction = (body.transform.basis * Vector3(velocity.x, 0, velocity.y))
	animation_player.play("idl")
	if direction:	
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		velocity.y = 0
	#animation_player.play("move")
#else:
	#animation_player.play("idl")
	move_and_slide()

	
	

@rpc("call_local")
func shoot():
	var bullet = BULLET.instantiate()
	bullet.position = pistol.global_position
	player.add_child(bullet)
	bullet.global_transform = pistol.global_transform
	

	

@rpc("call_local")
func shoot_effects():
	#animation_player.play("fire")
	muzzle_flash.restart()
	muzzle_flash.emitting = true

	
	

@rpc("any_peer")
func damage_recieved():
	health -= 1
	if health <= 0:
		health = 5
		position = Vector3.ZERO
	health_changed.emit(health)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		animation_player.play("idl")
