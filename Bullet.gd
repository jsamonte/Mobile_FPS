extends RigidBody3D


var direction = Vector3.ZERO
var speed = 10

@onready var ray_cast = $RayCast3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	#translate(direction.normalized() * delta * speed)
	#position += transform.basis.z * speed * delta
	#apply_impulse(transform.basis.z, -transform.basis.z * speed)
	#apply_impulse(Vector3(0,0,1), direction)
	apply_central_force(- transform.basis.z * speed)
	if ray_cast.is_colliding():
		var hit_player = ray_cast.get_collider()
		print(hit_player.get_class())
		if(hit_player.get_class() == "CharacterBody3D"):
			hit_player.damage_recieved.rpc_id(hit_player.get_multiplayer_authority())
	
	
func set_direction(dir):
	# Set the direction of the bullet and rotate it accordingly
	direction = dir.normalized()
	rotation = direction.rotation_to(Vector3.FORWARD)
		
