extends Control

@onready var sprite_nave: AnimatedSprite2D = $navesita.find_children("", "AnimatedSprite2D", true, false)[0]


func _ready() -> void:
	# Al entrar a la escena, pone el último frame que dejaste guardado
	sprite_nave.frame = frames_nave.frame_nave


func _on_topizq_pressed() -> void:
	sprite_nave.frame = clamp(sprite_nave.frame - 1, 0, 5)
	frames_nave.guardar_frame(sprite_nave.frame)


func _on_topder_pressed() -> void:
	sprite_nave.frame = clamp(sprite_nave.frame + 1, 0, 5)
	frames_nave.guardar_frame(sprite_nave.frame)
	
	

func _on_medioziq_pressed() -> void:
	pass # Replace with function body.


func _on_medioder_pressed() -> void:
	pass # Replace with function body.


func _on_bottomizq_pressed() -> void:
	pass # Replace with function body.


func _on_bottomder_pressed() -> void:
	pass # Replace with function body.


func _on_regreso_pressed() -> void:
	get_tree().change_scene_to_file("res://mision2.tscn")
	pass # Replace with function body.
