extends Node

const RUTA_GUARDADO = "user://datos_nave.cfg"
var frame_nave: int = 0

func _ready() -> void:
	cargar_datos()

func guardar_frame(nuevo_frame: int) -> void:
	frame_nave = nuevo_frame
	var config = ConfigFile.new()
	config.set_value("nave", "frame", frame_nave)
	config.save(RUTA_GUARDADO)

func cargar_datos() -> void:
	var config = ConfigFile.new()
	if config.load(RUTA_GUARDADO) == OK:
		frame_nave = config.get_value("nave", "frame", 0)
		
		

var p: int =1
var c: int =1
var pl: int =1
var t: int =1
