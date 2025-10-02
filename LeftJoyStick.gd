extends Area2D

@onready var big_circle = $BigCircle
@onready var small_circle = $BigCircle/SmallCircle
@onready var max_distance = $CollisionShape2D.shape.radius

var touched = false
var inputevent = Vector2(0,0)



func _input(event):
	if Input.is_action_just_pressed("steady"):
		small_circle.position = Vector2(0,0)
	if event is InputEventScreenDrag:
		var distance = event.position.distance_to(big_circle.global_position)
		if not touched:
			if distance < max_distance: 
				touched = true		
				inputevent = event
		else:
			touched = false	
	
func _process(_delta):
	if touched:
		small_circle.global_position = inputevent.position
		small_circle.position = (big_circle.position + (small_circle.position - big_circle.position)).limit_length(max_distance)

func get_velocity():
	var joystick_velocity = Vector3(0,0,0)
	joystick_velocity.x = small_circle.position.x / max_distance
	joystick_velocity.y = small_circle.position.y / max_distance
	return joystick_velocity
