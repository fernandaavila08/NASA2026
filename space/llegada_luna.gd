extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_regreso_pressed() -> void:
	get_tree().change_scene_to_file("res://mision2.tscn")
	pass # Replace with function body.


func _on_mission_1_pressed() -> void:
	Misionextra.mision=1
	#print(Misionextra.mision)
	pass # Replace with function body.


func _on_mission_2_pressed() -> void:
	Misionextra.mision=2
	#print("2")
	pass # Replace with function body.


func _on_mission_3_pressed() -> void:
	Misionextra.mision=3
	#print("3")
	pass # Replace with function body.
