
extends CharacterBody2D
signal mision_fallida

var integridad_estructural: float = 100.0
@export var dano_por_choque: float = 10.0
@export var velocidad: float = 150.0

func _ready() -> void:
	$DetectorChoque.body_entered.connect(_al_chocar)

func _physics_process(delta: float) -> void:

	var direccion = Input.get_vector(
		"izq",
		"der",
		"arriba",
        "abajo"
	)
	
	

	velocity = direccion * velocidad

	move_and_slide()
	
func _al_chocar(body: Node2D) -> void:
	if body.is_in_group("obstaculos"):
		integridad_estructural -= dano_por_choque
		integridad_estructural = max(integridad_estructural, 0.0)

		print("¡Choque detectado!")
		print("Integridad estructural: ", integridad_estructural, "%")

		if integridad_estructural <= 0:
			set_physics_process(false)
			mision_fallida.emit()
			
func obtener_integridad() -> float:
	return integridad_estructural
