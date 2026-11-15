extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_orbitas_pressed() -> void:
	get_tree().change_scene_to_file("res://lanzamiento.tscn")

	pass # Replace with function body.


func _on_rover_pressed() -> void:
	get_tree().change_scene_to_file("res://rover.tscn")
	pass # Replace with function body.


func _on_llegadaalaluna_pressed() -> void:
	get_tree().change_scene_to_file("res://llegada_luna.tscn")
	pass # Replace with function body.


func _on_launch_pressed() -> void:
	get_tree().change_scene_to_file("res://video_despeje.tscn")
	pass # Replace with function body.


func _on_nave_2_pressed() -> void:
	get_tree().change_scene_to_file("res://nave_2.tscn")
	pass # Replace with function body.
