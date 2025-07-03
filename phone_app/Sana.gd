extends CharacterBody2D

@export var walk_speed: float = 40.0
@export var wander_range: float = 200.0
@export var idle_time_range := Vector2(1.0, 3.0)

var state := "idle"
var idle_timer := 0.0
var target_x := 0.0
var target_y := 0.0

# Define the walkable trapezoid bounds
const TOP_Y := 570
const BOTTOM_Y := 675
const LEFT_TOP := 488.375
const RIGHT_TOP := 1846.625
const LEFT_BOTTOM := 83.375
const RIGHT_BOTTOM := 2238.825

var dash_target := Vector2.ZERO
var current_task := ""

@onready var clock_sprite: Sprite2D = $ClockSprite
@onready var time_label: Label = $ClockSprite/TimeLabel

var showing_clock := false
var time_timer := Timer.new()

func _ready():
	set_idle()
	update_depth_scale()
	add_child(time_timer)
	time_timer.start()
	time_timer.wait_time = 1.0  # Update every second
	time_timer.timeout.connect(_update_clock_time)
	
func _process(delta):
	match state:
		"idle":
			idle_timer -= delta
			if idle_timer <= 0:
				start_walking()

		"walking":
			var move_vec = Vector2(
				sign(target_x - position.x),
				sign(target_y - position.y)
			)

			# Stop walking if we're close enough to the target
			if abs(target_x - position.x) < 2 and abs(target_y - position.y) < 2:
				set_idle()
			else:
				velocity = move_vec.normalized() * walk_speed
				move_and_slide()
		"dashing":
			var dir = dash_target - position
			if dir.length() < 4:
				velocity = Vector2.ZERO
				$AnimatedSprite2D.play("idle")
				state = current_task  # Transition into the appropriate task
			else:
				velocity = dir.normalized() * (walk_speed * 2.5)
				move_and_slide()
				
	# 🛑 Clamp position every frame so character stays in trapezoid
	var bounds = get_walk_bounds(position.y)
	position.x = clamp(position.x, bounds.x, bounds.y)
	
	update_depth_scale()

func set_idle():
	state = "idle"
	idle_timer = randf_range(idle_time_range.x, idle_time_range.y)
	$AnimatedSprite2D.play("idle")
	velocity = Vector2.ZERO

func start_walking():
	state = "walking"
	$AnimatedSprite2D.play("walk")

	# Pick a new Y within the trapezoid vertical range
	target_y = randf_range(BOTTOM_Y, TOP_Y)

	# Get horizontal bounds at that Y
	var bounds = get_walk_bounds(target_y)

	# Pick a new X within those bounds
	target_x = randf_range(bounds.x, bounds.y)

	#target_y = TOP_Y
	#target_x = LEFT_TOP

	# Flip sprite if moving left
	$AnimatedSprite2D.flip_h = target_x < position.x
	
func get_walk_bounds(y: float) -> Vector2:
	var t = clamp((y - TOP_Y) / (BOTTOM_Y - TOP_Y), 0.0, 1.0)
	var left = lerp(LEFT_TOP, LEFT_BOTTOM, t)
	var right = lerp(RIGHT_TOP, RIGHT_BOTTOM, t)
	return Vector2(left, right)


func update_depth_scale():
	# Adjust this range to match your scene’s vertical walk space
	var min_y = TOP_Y
	var max_y = BOTTOM_Y
	
	var t = clamp((position.y - min_y) / (max_y - min_y), 0.0, 1.0)

	var min_scale = 0.85
	var max_scale = 1.0

	var s = lerp(min_scale, max_scale, t)
	scale = Vector2(s, s)

func dash_to(target_pos: Vector2, task_name: String):
	dash_target = target_pos
	current_task = task_name
	state = "dashing"
	$AnimatedSprite2D.play("walk")

func show_clock():
	if not showing_clock:
		showing_clock = true
		clock_sprite.visible = true
		$AnimatedSprite2D.play("hold_clock")

		# Set position to front (e.g., center X, front Y)
		dash_target = Vector2(position.x, 680)  # Adjust Y (BOTTOM_Y-like value)
		current_task = "clock"
		state = "dashing"

func hide_clock():
	if showing_clock:
		showing_clock = false
		clock_sprite.visible = false
		set_idle()
		
func _update_clock_time():
	var time = Time.get_time_dict_from_system()
	var hour = time["hour"]
	var minute = time["minute"]
	var second = time["second"]

	time_label.text = "%02d:%02d:%02d" % [hour, minute, second]
