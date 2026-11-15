extends CanvasLayer

@onready var barra: ProgressBar = $BarraIntegridad
@onready var rover = get_parent().get_node("roversito/rover")


func _ready() -> void:
	barra.min_value = 0
	barra.max_value = 100
	barra.value = rover.obtener_integridad()


func _process(_delta: float) -> void:
	barra.value = rover.obtener_integridad()
