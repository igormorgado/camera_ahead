extends KinematicBody2D

var look_direction = Vector2()

const MAX_WALK_SPEED = 450
const MAX_RUN_SPEED = 700

enum STATES { IDLE, MOVE, RUN }
var state = null


func _ready():
	_change_state(STATES.IDLE)


func _change_state(new_state):
	match new_state:
		STATES.IDLE:
			$AnimationPlayer.play('idle')
		STATES.MOVE:
			$AnimationPlayer.play('walk')
		STATES.RUN:
			$AnimationPlayer.play('walk')

	var fmt_str = "STATE: {0} -> {1}"
	print(fmt_str.format([state, new_state]))
	state = new_state


func _physics_process(delta):
	var input_direction = get_input_direction()
	var run_action = Input.is_action_pressed("run")
	
	update_look_direction(input_direction)

	# FSM
	if state == STATES.IDLE:
		if input_direction:
			if run_action:
				_change_state(STATES.RUN)
			else:
				_change_state(STATES.MOVE)
	elif state == STATES.MOVE:
		if not input_direction:
			_change_state(STATES.IDLE)
		elif run_action:
			_change_state(STATES.RUN)
	elif state == STATES.RUN:
		if not input_direction:
			_change_state(STATES.IDLE)
		elif not run_action:
			_change_state(STATES.MOVE)

	# Applying results of FSM
	var speed	
	if state == STATES.RUN:
		speed = MAX_RUN_SPEED
		$Pivot/CameraOffset.position.x = $Pivot.dynamic_camera_offset()
	elif state == STATES.MOVE:
		speed = MAX_WALK_SPEED
		$Pivot/CameraOffset.position.x = $Pivot.initial_camera_offset_x
	else:
		$Pivot/CameraOffset.position.x = $Pivot.initial_camera_offset_x
		#$Pivot/CameraOffset.position.x = 0
		return

	move(speed, input_direction)


func get_input_direction():
	var input_direction = Vector2()
	input_direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	input_direction.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return input_direction


func update_look_direction(input_direction):
	if not input_direction:
		return
	look_direction = input_direction
	if not input_direction.x in [-1, 1]:
		return
	$BodyPivot.set_scale(Vector2(input_direction.x, 1))


func move(speed, direction):
	var velocity = direction.normalized() * speed
	move_and_slide(velocity, Vector2(), 5, 2)
