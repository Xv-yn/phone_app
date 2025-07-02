extends CharacterBody2D

@export var walk_speed: float = 40.0
@export var wander_range: float = 200.0
@export var idle_time_range := Vector2(1.0, 3.0)

var state := "idle"
var idle_timer := 0.0
var target_x := 0.0

func _ready():
	set_idle()

func _process(delta):
	match state:
		"idle":
			idle_timer -= delta
			if idle_timer <= 0:
				start_walking()
		"walking":
			var move_vec = Vector2(sign(target_x - position.x), 0)
			if abs(target_x - position.x) < 2:
				set_idle()
			else:
				velocity = move_vec * walk_speed
				move_and_slide()

func set_idle():
	state = "idle"
	idle_timer = randf_range(idle_time_range.x, idle_time_range.y)
	$AnimatedSprite2D.play("idle")
	velocity = Vector2.ZERO

func start_walking():
	state = "walking"
	$AnimatedSprite2D.play("walk")
	# This part sets random walking
	# NOTE THAT THIS ONLY WORKS LEFT TO RIGHT
	var offset = randf_range(-wander_range, wander_range)
	target_x = position.x + offset
	$AnimatedSprite2D.flip_h = target_x < position.x
