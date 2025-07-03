extends Area2D

@onready var player: AudioStreamPlayer2D = $AudioStreamPlayer
@onready var sprite: Sprite2D = $Sprite2D

var playing := false

func _ready():
	connect("input_event", _on_input_event)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if playing:
			player.stop()
			playing = false
			sprite.modulate = Color(1, 1, 1)  # normal color
		else:
			player.play()
			playing = true
			sprite.modulate = Color(0.7, 1.0, 0.7)  # green tint to show it's active
