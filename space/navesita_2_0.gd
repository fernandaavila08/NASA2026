extends Control

# Variables globales:
# frames_nave.p
# frames_nave.c
# frames_nave.pl
# frames_nave.t


func _on_tizq_pressed() -> void:
	frames_nave.t = max(1, frames_nave.t - 1)

	for i in range(1, 5):
		get_node("t" + str(i)).hide()

	get_node("t" + str(frames_nave.t)).show()


func _on_izq_2_pressed() -> void:
	frames_nave.pl = max(1, frames_nave.pl - 1)

	for i in range(1, 4):
		get_node("pl" + str(i)).hide()

	get_node("pl" + str(frames_nave.pl)).show()


func _on_izq_3_pressed() -> void:
	frames_nave.c = max(1, frames_nave.c - 1)

	for i in range(1, 4):
		get_node("c" + str(i)).hide()

	get_node("c" + str(frames_nave.c)).show()


func _on_izq_4_pressed() -> void:
	frames_nave.p = max(1, frames_nave.p - 1)

	for i in range(1, 4):
		get_node("p" + str(i)).hide()

	get_node("p" + str(frames_nave.p)).show()


func _on_tder_pressed() -> void:
	frames_nave.t = min(4, frames_nave.t + 1)

	for i in range(1, 5):
		get_node("t" + str(i)).hide()

	get_node("t" + str(frames_nave.t)).show()


func _on_der_2_pressed() -> void:
	frames_nave.pl = min(3, frames_nave.pl + 1)

	for i in range(1, 4):
		get_node("pl" + str(i)).hide()

	get_node("pl" + str(frames_nave.pl)).show()


func _on_der_3_pressed() -> void:
	frames_nave.c = min(3, frames_nave.c + 1)

	for i in range(1, 4):
		get_node("c" + str(i)).hide()

	get_node("c" + str(frames_nave.c)).show()


func _on_der_4_pressed() -> void:
	frames_nave.p = min(3, frames_nave.p + 1)

	for i in range(1, 4):
		get_node("p" + str(i)).hide()

	get_node("p" + str(frames_nave.p)).show()


func _on_regreso_pressed() -> void:
	get_tree().change_scene_to_file("res://mision2.tscn")
	pass # Replace with function body.
