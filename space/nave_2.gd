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


@onready var navesita = $navesita


func _on_topizq_pressed() -> void:
	navesita.frame -= 1


func _on_topder_pressed() -> void:
	navesita.frame += 1
	
	

func _on_medioziq_pressed() -> void:
	pass # Replace with function body.


func _on_medioder_pressed() -> void:
	pass # Replace with function body.


func _on_bottomizq_pressed() -> void:
	pass # Replace with function body.


func _on_bottomder_pressed() -> void:
	pass # Replace with function body.
