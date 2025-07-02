extends Node2D

@onready var camera: Camera2D = $Sana/FollowCamera
@onready var button: Button = $CanvasLayer/CameraToggleButton
@onready var camera_pivot: Node2D = $CameraPivot
@onready var character: Node2D = $Sana

var following := true
var dragging := false
var drag_start_mouse_x := 0.0
var drag_start_camera_x := 0.0

# Width of background (update this if background is different)
@export var background_width := 2332.2
@onready var camera_viewport_width := get_viewport_rect().size.x

func _ready():
	button.pressed.connect(_on_camera_toggle)

func _on_camera_toggle():
	if following:
		camera_pivot.global_position = camera.global_position
		character.remove_child(camera)
		camera_pivot.add_child(camera)
		camera.position = Vector2.ZERO
		camera.enabled = true
		following = false
		button.text = "Follow"

	else:
		# Smooth follow transition
		var target_position = character.global_position
		var tween := create_tween()

		tween.tween_property(
			camera, "global_position",
			target_position,
			0.6
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		tween.tween_callback(func ():
			var global_before = camera.global_position  # Store exact world pos
			camera_pivot.remove_child(camera)
			character.add_child(camera)
			camera.global_position = global_before  # Restore exact world pos
			camera.enabled = true
			following = true
			button.text = "Unfollow"
		)

func _unhandled_input(event):
	if following:
		return  # Don't allow dragging while camera follows

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_start_mouse_x = event.position.x
				drag_start_camera_x = camera_pivot.position.x
			else:
				dragging = false

	elif event is InputEventMouseMotion and dragging:
		var delta_x = event.position.x - drag_start_mouse_x
		camera_pivot.position.x = clamp(
			drag_start_camera_x - delta_x,
			0,
			background_width - camera_viewport_width
		)

func _process(_delta):
	if following:
		# Clamp the camera's x to the background edges
		var new_x = clamp(character.global_position.x, 0, background_width - camera_viewport_width)
		camera.global_position.x = new_x
		camera.global_position.y = character.global_position.y  # optional
