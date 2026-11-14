extends Node

const RUTA_GUARDADO = "user://datos_nave.cfg"
var frame_rover: int = 0

func _ready() -> void:
	cargar_datos()

func guardar_frame(nuevo_frame: int) -> void:
	frame_rover = nuevo_frame
	var config = ConfigFile.new()
	config.set_value("rover", "frame", frame_rover)
	config.save(RUTA_GUARDADO)

func cargar_datos() -> void:
	var config = ConfigFile.new()
	if config.load(RUTA_GUARDADO) == OK:
		frame_rover = config.get_value("rover", "frame", 0)
