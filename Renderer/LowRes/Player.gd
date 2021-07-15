extends KinematicBody2D

onready var body = $Visuals/Body
onready var visuals = $Visuals
onready var state = "IDLE"
var previous_state = ""

var can_jump
onready var jumps_left = 3
onready var stopping = true
var hit_the_floor

export (float) var acceleration = 300.0
export (float) var deceleration = 1100.0
export (float) var air_acceleration = 400.0
export (float) var jump_speed = -170.0
var acceleration_scale = 1
var air_acceleeration_scale = 1

var move_direction = Vector2()
var velocity = Vector2()
var direction = 1
var previous_velocity = Vector2()

onready var gravity_scale = 1
const GRAVITY = 360.0
const MAX_SPEED = 170.0
const MAX_AIR_SPEED = 90.0
const MAX_JUMP_NUMBER = 3

		   ## Movement (Start) ##
func _physics_process(delta):
	get_direction()
	move_direction = get_move_direction()
	velocity.y += GRAVITY * delta * gravity_scale
	velocity.normalized()
	previous_velocity = velocity
	
	match state:
		"IDLE":
			velocity.y = 0
			if move_direction.x != 0 and on_ground():
				change_state("RUN")
			if Input.is_action_pressed("Up"):
				jump()
			if !is_on_floor():
				change_state("AIR")
			else:
				velocity.x = 0
		"RUN":
			gravity_scale = 1
			if Input.is_action_pressed("Up"):
				jump()
			if move_direction.x != 0:
				stopping = false
				velocity.x += move_direction.x * acceleration * delta
				velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
				if Input.is_action_just_pressed("Up"):
					jump()
			else:
				if Input.is_action_just_pressed("Up"):
					jump()
				if velocity.x != 0:
					velocity.x += deceleration * delta * -direction
					if !stopping:
						stopping = true
						yield(get_tree().create_timer((abs(velocity.x)) / deceleration), "timeout")
						velocity.x = 0
						change_state("IDLE")
			if !is_on_floor():
				change_state("AIR")
		"AIR":
			body.position = Vector2(0, 8)
			body.offset = Vector2(0, -8)
			
			if Input.is_action_just_pressed("Up"):
				if jumps_left > 0:
					jump()
				else:
					if previous_state == "WALL":
						velocity.y = jump_speed
						change_state("AIR")
			#Landing
			if is_on_floor() and velocity.x != 0:
				jumps_left = MAX_JUMP_NUMBER
				change_state("RUN")
			if is_on_floor() and velocity.x == 0:
				jumps_left = MAX_JUMP_NUMBER
				change_state("IDLE")
			elif is_on_floor() and move_direction.x == 0:
				jumps_left = MAX_JUMP_NUMBER
				change_state("IDLE")
			#Moving directions
			if move_direction.x != 0:
				stopping = false
				if velocity.y >= 0:
					velocity.x += move_direction.x * air_acceleration * 5 * delta
				else:
					velocity.x += move_direction.x * air_acceleration * delta
				velocity.x = clamp(velocity.x, -MAX_AIR_SPEED, MAX_AIR_SPEED)
			else:
				if velocity.x != 0:
					velocity.x += air_acceleration * delta * -direction
					if !stopping:
						stopping = true
						yield(get_tree().create_timer(((abs(velocity.x)) / air_acceleration) + 0.4), "timeout")
						velocity.x = 0
	velocity = move_and_slide(velocity, Vector2.UP)
	
	
	#Squash
	if !is_on_floor():
		hit_the_floor = false
		body.scale.y = range_lerp(abs(velocity.y), 0, abs(jump_speed), 1, 1.2)
		body.scale.x = range_lerp(abs(velocity.y), 0, abs(jump_speed), 1, 0.9)
	if !hit_the_floor and is_on_floor():
		body.scale.x = range_lerp(abs(previous_velocity.y), 0, 450, 1.0, 1.2)
		body.scale.y = range_lerp(abs(previous_velocity.y), 0, 450, 1.0, 0.8)
		hit_the_floor = true
	if hit_the_floor and is_on_floor():
		body.scale.x = lerp(body.scale.x, 1.0, 3.5 * delta)
		body.scale.y = lerp(body.scale.y, 1.0, 3.5 * delta)

func change_state(new_state):
	previous_state = state
	state = new_state
	
	if state == "RUN":
		body.play("Run")
	else:
		body.play("Idle")

func jump():
	velocity.y = jump_speed
	change_state("AIR")

func on_ground():
	if is_on_floor():
		body.position = Vector2(0, 8)
		body.offset = Vector2(0, -8)
		return true
	else:
		return false

#direction the player is moving
func get_direction():
	if velocity.x < 0:
		direction = -1
	else:
		direction = 1

#direction of input
func get_move_direction():
	var dir = Vector2(
		int(Input.is_action_pressed("Right")) - 
		int(Input.is_action_pressed("Left"))
		, int(Input.is_action_pressed("Down")) - 
		int(Input.is_action_pressed("Up")))
	return dir

func _input(_event):
	var dir = int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
	if dir != 0:
		visuals.scale.x = dir
