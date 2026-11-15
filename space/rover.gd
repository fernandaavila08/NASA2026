extends Control

# Busca por nombre ("roversin") y por tipo ("AnimatedSprite2D")
@onready var sprite_rover: AnimatedSprite2D = $roversito.find_children("roversin", "AnimatedSprite2D", true, false)[0]


func _ready() -> void:
	# Al entrar a la escena, pone el último frame que dejaste guardado
	sprite_rover.frame = frames_rover.frame_rover


func _on_izq_pressed() -> void:
	sprite_rover.frame = clamp(sprite_rover.frame - 1, 0, 3)
	frames_rover.guardar_frame(sprite_rover.frame)


func _on_der_pressed() -> void:
	sprite_rover.frame = clamp(sprite_rover.frame + 1, 0, 3)
	frames_rover.guardar_frame(sprite_rover.frame)


func _on_regreso_pressed() -> void:
	get_tree().change_scene_to_file("res://mision2.tscn")
