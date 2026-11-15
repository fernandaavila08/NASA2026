extends CanvasLayer

@onready var barra: ProgressBar = $PanelEstadoRover/ContenidoEstado/BarraIntegridad
@onready var texto_integridad: Label = $PanelEstadoRover/ContenidoEstado/TextoIntegridad
@onready var rover = get_parent().get_node("roversito/rover")

@onready var panel_derrota = $PanelDerrota
@onready var boton_reintentar = $PanelDerrota/Contenido/BotonReintentar


func _ready() -> void:
	barra.min_value = 0
	barra.max_value = 100
	barra.value = rover.obtener_integridad()

	panel_derrota.hide()

	rover.mision_fallida.connect(_al_finalizar_mision)
	boton_reintentar.pressed.connect(_reiniciar_mision)


func _process(_delta: float) -> void:
	var integridad = rover.obtener_integridad()
	barra.value = integridad
	texto_integridad.text = "Integridad estructural: " + str(int(integridad)) + "%"


func _al_finalizar_mision() -> void:
	panel_derrota.show()


func _reiniciar_mision() -> void:
	get_tree().reload_current_scene()
