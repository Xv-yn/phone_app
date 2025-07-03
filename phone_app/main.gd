extends Node2D

@onready var camera: Camera2D = $CameraPivot/FollowCamera
@onready var button: Button = $CanvasLayer/CameraToggleButton
@onready var camera_pivot: Node2D = $CameraPivot
@onready var character: Node2D = $Sana

var following := true
var dragging := false
var drag_start_mouse_x := 0.0
var drag_start_camera_x := 0.0

@export var background_width := 2332.2
@onready var camera_viewport_width := get_viewport_rect().size.x

# Fixed Y position for camera (no vertical movement)
const CAMERA_Y_LOCK := 0

func _ready():
	button.pressed.connect(_on_camera_toggle)
	
	if following:
		# Start camera centered on the character immediately
		var half_viewport = Vector2(camera_viewport_width / 2, get_viewport_rect().size.y / 2)
		var target_x = clamp(
			character.global_position.x - half_viewport.x,
			0,
			background_width - camera_viewport_width
		)
		camera.global_position = Vector2(target_x, CAMERA_Y_LOCK)
		
func _on_camera_toggle():
	if following:
		# Stop following and switch to free camera
		var global_pos = camera.global_position
		if camera.get_parent() == character:
			character.remove_child(camera)
		if camera.get_parent() != camera_pivot:
			camera_pivot.add_child(camera)
		camera.global_position = global_pos
		camera.position = Vector2.ZERO  # <-- Important: reset local offset
		camera.enabled = true

		# Reset pivot position within bounds
		var clamped_x = clamp(global_pos.x, 0, background_width - camera_viewport_width)
		camera_pivot.position = Vector2(clamped_x, CAMERA_Y_LOCK)  # <-- reset to bounded location

		following = false
		button.text = "Follow"

	else:
		# Switch to follow mode (without tween)
		var global_pos = camera.global_position
		if camera.get_parent() == camera_pivot:
			camera_pivot.remove_child(camera)
		if camera.get_parent() != character:
			character.add_child(camera)
		camera.global_position = global_pos  # Restore exact position
		camera.position = character.to_local(global_pos)  # Optional correction
		camera.enabled = true
		following = true
		button.text = "Unfollow"

func _unhandled_input(event):
	if following:
		return

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

func _process(delta):
	if following:
		var half_viewport = Vector2(camera_viewport_width / 2, get_viewport_rect().size.y / 2)
		var target_x = clamp(character.global_position.x - half_viewport.x, 0, background_width - camera_viewport_width)
		var target_pos = Vector2(target_x, CAMERA_Y_LOCK)

		# Smooth interpolation (lerp camera toward character)
		camera.global_position = camera.global_position.lerp(target_pos, 8 * delta)
