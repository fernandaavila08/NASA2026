
extends Control

# =====================================
# CONFIGURACION DE LA MISION
# =====================================

@export_group("Tiempos de mision")

@export var tiempo_despegue: float = 5.0
@export var tiempo_separacion: float = 9.0
@export var tiempo_llegada: float = 25.0
@export var tiempo_orbita: float = 32.0
@export var tiempo_aterrizaje: float = 40.0

@export_group("Probabilidad de fallos (%)")

@export_range(0, 100) var fallo_motor: float = 5.0
@export_range(0, 100) var fallo_separacion: float = 5.0
@export_range(0, 100) var fallo_navegacion: float = 5.0
@export_range(0, 100) var fallo_orbita: float = 5.0
@export_range(0, 100) var fallo_aterrizaje: float = 10.0

@export_group("Condiciones de la nave")

@export_range(0, 100) var combustible: float = 100.0
@export_range(0, 100) var integridad_nave: float = 100.0

@export var velocidad_aterrizaje: float = 8.0
@export var velocidad_maxima_aterrizaje: float = 10.0

# =====================================
# VARIABLES INTERNAS
# =====================================

var tiempo_mision: float = 0.0
var velocidad_simulacion: float = 1.0

var iniciada: bool = false
var pausada: bool = false
var finalizada: bool = false
var mision_fallida: bool = false

var etapa_actual: int = 0
var mensaje_fallo: String = ""

var tierra: Vector2
var luna: Vector2
var posicion_nave: Vector2

var rng = RandomNumberGenerator.new()

var etapa_1_separada: bool = false
var etapa_2_separada: bool = false
var cubierta_separada: bool = false

# =====================================
# INTERFAZ
# =====================================

var panel: PanelContainer
var estado_label: Label
var etapa_label: Label
var tiempo_label: Label
var combustible_label: Label
var integridad_label: Label
var mensaje_label: Label
var progreso: ProgressBar

var boton_iniciar: Button
var boton_pausa: Button
var boton_reiniciar: Button


func _ready() -> void:

	rng.randomize()

	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	crear_interfaz()
	reiniciar_mision()

	resized.connect(queue_redraw)


# =====================================
# PROCESO PRINCIPAL
# =====================================

func _process(delta: float) -> void:

	if iniciada and not pausada and not finalizada:

		tiempo_mision += delta * velocidad_simulacion

		comprobar_etapas()

		actualizar_posicion_nave()

	actualizar_interfaz()
	queue_redraw()


# =====================================
# COMPROBAR ETAPAS
# =====================================

func comprobar_etapas() -> void:

	if etapa_actual == 0 and tiempo_mision >= tiempo_despegue:

		etapa_actual = 1

		if comprobar_fallo(fallo_motor):
			fallar_mision("FALLO DEL MOTOR PRINCIPAL")
			return

		if combustible <= 0:
			fallar_mision("COMBUSTIBLE INSUFICIENTE")
			return

	if etapa_actual == 1 and tiempo_mision >= tiempo_separacion:

		etapa_actual = 2

		if comprobar_fallo(fallo_separacion):
			fallar_mision("FALLO EN LA SEPARACION DE ETAPAS")
			return

		etapa_1_separada = true

	if etapa_actual == 2 and tiempo_mision >= tiempo_llegada:

		etapa_actual = 3

		if comprobar_fallo(fallo_navegacion):
			fallar_mision("ERROR DE NAVEGACION")
			return

	if etapa_actual == 3 and tiempo_mision >= tiempo_orbita:

		etapa_actual = 4

		if comprobar_fallo(fallo_orbita):
			fallar_mision("ERROR DE INSERCION EN ORBITA LUNAR")
			return

		etapa_2_separada = true

	if etapa_actual == 4 and tiempo_mision >= tiempo_aterrizaje:

		etapa_actual = 5

		if combustible <= 0:
			fallar_mision("COMBUSTIBLE AGOTADO DURANTE EL DESCENSO")
			return

		if velocidad_aterrizaje > velocidad_maxima_aterrizaje:
			fallar_mision("VELOCIDAD DE ATERRIZAJE EXCESIVA")
			return

		if comprobar_fallo(fallo_aterrizaje):
			fallar_mision("FALLO DURANTE EL ATERRIZAJE")
			return

		finalizar_mision()


# =====================================
# PROBABILIDAD DE FALLO
# =====================================

func comprobar_fallo(probabilidad: float) -> bool:

	var resultado = rng.randf_range(0.0, 100.0)

	return resultado < probabilidad


# =====================================
# FALLAR MISION
# =====================================

func fallar_mision(mensaje: String) -> void:

	mision_fallida = true
	finalizada = true
	pausada = true

	mensaje_fallo = mensaje

	estado_label.text = "MISION FALLIDA"
	mensaje_label.text = mensaje


# =====================================
# FINALIZAR MISION
# =====================================

func finalizar_mision() -> void:

	finalizada = true
	pausada = true

	estado_label.text = "MISION COMPLETADA"
	mensaje_label.text = "ATERRIZAJE LUNAR EXITOSO"


# =====================================
# POSICION DE LA NAVE
# =====================================

func actualizar_posicion_nave() -> void:

	var pantalla = get_viewport_rect().size

	var centro_y = pantalla.y * 0.55

	tierra = Vector2(pantalla.x * 0.17, centro_y)
	luna = Vector2(pantalla.x * 0.82, centro_y - 15)

	var inicio = tierra + Vector2(0, -75)
	var control = Vector2(pantalla.x * 0.48, centro_y - 180)
	var destino = luna + Vector2(0, -55)

	if tiempo_mision <= tiempo_despegue:

		var p = clamp(tiempo_mision / tiempo_despegue, 0.0, 1.0)

		posicion_nave = tierra + Vector2(0, -70 - p * 150)

	elif tiempo_mision <= tiempo_llegada:

		var p = inverse_lerp(
			tiempo_despegue,
			tiempo_llegada,
			tiempo_mision
		)

		posicion_nave = inicio.lerp(control, p).lerp(
			control.lerp(destino, p),
			p
		)

	elif tiempo_mision <= tiempo_orbita:

		var p = inverse_lerp(
			tiempo_llegada,
			tiempo_orbita,
			tiempo_mision
		)

		var angulo = p * TAU * 3.0

		posicion_nave = luna + Vector2(
			cos(angulo) * 70,
			sin(angulo) * 70
		)

	elif tiempo_mision <= tiempo_aterrizaje:

		var p = inverse_lerp(
			tiempo_orbita,
			tiempo_aterrizaje,
			tiempo_mision
		)

		posicion_nave = luna + Vector2(
			lerp(70.0, 0.0, p),
			lerp(0.0, -40.0, p)
		)

	# Si falla, la nave deja de avanzar.


# =====================================
# CREAR INTERFAZ
# =====================================

func crear_interfaz() -> void:

	panel = PanelContainer.new()

	panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	panel.offset_left = 20
	panel.offset_right = -20
	panel.offset_top = 15
	panel.offset_bottom = 160

	add_child(panel)

	var estilo = StyleBoxFlat.new()
	estilo.bg_color = Color(0.025, 0.045, 0.10, 0.96)
	estilo.border_color = Color(0.15, 0.4, 0.65)
	estilo.set_border_width_all(1)
	estilo.set_corner_radius_all(12)
	estilo.content_margin_left = 18
	estilo.content_margin_right = 18
	estilo.content_margin_top = 12
	estilo.content_margin_bottom = 12

	panel.add_theme_stylebox_override("panel", estilo)

	var columna = VBoxContainer.new()
	columna.add_theme_constant_override("separation", 7)
	panel.add_child(columna)

	var titulo = Label.new()
	titulo.text = "CENTRO DE CONTROL | MISION LUNA"
	titulo.add_theme_font_size_override("font_size", 23)
	titulo.add_theme_color_override("font_color", Color.CYAN)
	columna.add_child(titulo)

	estado_label = Label.new()
	estado_label.add_theme_font_size_override("font_size", 17)
	columna.add_child(estado_label)

	etapa_label = Label.new()
	columna.add_child(etapa_label)

	tiempo_label = Label.new()
	columna.add_child(tiempo_label)

	var datos = HBoxContainer.new()
	datos.add_theme_constant_override("separation", 20)
	columna.add_child(datos)

	combustible_label = Label.new()
	datos.add_child(combustible_label)

	integridad_label = Label.new()
	datos.add_child(integridad_label)

	progreso = ProgressBar.new()
	progreso.custom_minimum_size = Vector2(0, 12)
	progreso.max_value = 100
	columna.add_child(progreso)

	# PANEL INFERIOR

	var panel_inferior = PanelContainer.new()

	panel_inferior.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel_inferior.offset_left = 20
	panel_inferior.offset_right = -20
	panel_inferior.offset_top = -80
	panel_inferior.offset_bottom = -15

	add_child(panel_inferior)

	var estilo_inferior = StyleBoxFlat.new()
	estilo_inferior.bg_color = Color(0.025, 0.045, 0.10, 0.96)
	estilo_inferior.set_corner_radius_all(12)
	estilo_inferior.content_margin_left = 15
	estilo_inferior.content_margin_right = 15
	estilo_inferior.content_margin_top = 10
	estilo_inferior.content_margin_bottom = 10

	panel_inferior.add_theme_stylebox_override("panel", estilo_inferior)

	var fila = HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 15)
	panel_inferior.add_child(fila)

	boton_iniciar = Button.new()
	boton_iniciar.text = "INICIAR MISION"
	boton_iniciar.custom_minimum_size = Vector2(150, 42)
	boton_iniciar.pressed.connect(_on_iniciar_pressed)
	fila.add_child(boton_iniciar)

	boton_pausa = Button.new()
	boton_pausa.text = "PAUSAR"
	boton_pausa.custom_minimum_size = Vector2(130, 42)
	boton_pausa.pressed.connect(_on_pausa_pressed)
	fila.add_child(boton_pausa)

	boton_reiniciar = Button.new()
	boton_reiniciar.text = "REINICIAR"
	boton_reiniciar.custom_minimum_size = Vector2(130, 42)
	boton_reiniciar.pressed.connect(_on_reiniciar_pressed)
	fila.add_child(boton_reiniciar)

	mensaje_label = Label.new()
	mensaje_label.add_theme_font_size_override("font_size", 15)
	fila.add_child(mensaje_label)


# =====================================
# ACTUALIZAR INTERFAZ
# =====================================

func actualizar_interfaz() -> void:

	tiempo_label.text = "TIEMPO DE MISION: %.1f s" % tiempo_mision

	combustible_label.text = "COMBUSTIBLE: %.0f%%" % combustible

	integridad_label.text = "INTEGRIDAD: %.0f%%" % integridad_nave

	progreso.value = min(
		tiempo_mision / tiempo_aterrizaje * 100.0,
		100.0
	)

	if mision_fallida:
		estado_label.text = "ESTADO: MISION FALLIDA"
		return

	if finalizada:
		estado_label.text = "ESTADO: MISION COMPLETADA"
		return

	match etapa_actual:
		0:
			estado_label.text = "ESTADO: PREPARACION Y DESPEGUE"
			etapa_label.text = "ETAPA: LANZAMIENTO"

		1:
			estado_label.text = "ESTADO: ASCENSO"
			etapa_label.text = "ETAPA: PRIMERA ETAPA"

		2:
			estado_label.text = "ESTADO: VIAJE HACIA LA LUNA"
			etapa_label.text = "ETAPA: TRANSFERENCIA LUNAR"

		3:
			estado_label.text = "ESTADO: APROXIMACION LUNAR"
			etapa_label.text = "ETAPA: INSERCION ORBITAL"

		4:
			estado_label.text = "ESTADO: DESCENSO"
			etapa_label.text = "ETAPA: ATERRIZAJE"

		5:
			estado_label.text = "ESTADO: COMPLETADA"
			etapa_label.text = "ETAPA: SUPERFICIE LUNAR"


# =====================================
# DIBUJAR ESCENA
# =====================================

func _draw() -> void:

	var pantalla = get_viewport_rect().size

	draw_rect(
		Rect2(Vector2.ZERO, pantalla),
		Color(0.008, 0.015, 0.045)
	)

	for i in range(130):
		var x = fposmod(i * 137.5, pantalla.x)
		var y = fposmod(i * 83.7, pantalla.y)

		draw_circle(
			Vector2(x, y),
			1.2,
			Color(0.7, 0.8, 1.0, 0.7)
		)

	# TIERRA
	draw_circle(tierra, 48, Color(0.05, 0.25, 0.75))
	draw_circle(tierra + Vector2(-15, -15), 17, Color(0.1, 0.55, 0.9))
	draw_circle(tierra + Vector2(20, 18), 17, Color(0.1, 0.55, 0.35))

	# LUNA
	draw_circle(luna, 27, Color(0.67, 0.67, 0.7))
	draw_circle(luna + Vector2(-10, -7), 5, Color.GRAY)
	draw_circle(luna + Vector2(12, 9), 7, Color.DIM_GRAY)

	draw_string(
		ThemeDB.fallback_font,
		tierra + Vector2(-25, 70),
		"TIERRA",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		15,
		Color.WHITE
	)

	draw_string(
		ThemeDB.fallback_font,
		luna + Vector2(-20, 50),
		"LUNA",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		15,
		Color.WHITE
	)

	# TRAYECTORIA
	draw_line(
		tierra + Vector2(30, -20),
		luna + Vector2(-30, 0),
		Color(0.1, 0.65, 1.0, 0.4),
		2.0
	)

	# ORBITA
	if tiempo_mision >= tiempo_llegada:
		draw_arc(
			luna,
			70,
			0,
			TAU,
			100,
			Color.CYAN,
			2.0
		)

	# ETAPAS SEPARADAS
	if etapa_1_separada:
		draw_rect(
			Rect2(tierra + Vector2(120, 30), Vector2(12, 35)),
			Color.ORANGE
		)

	if etapa_2_separada:
		draw_rect(
			Rect2(tierra.lerp(luna, 0.55) + Vector2(-30, 40), Vector2(10, 25)),
			Color.GRAY
		)

	if cubierta_separada:
		draw_arc(
			tierra.lerp(luna, 0.4) + Vector2(-35, -40),
			9,
			PI,
			TAU,
			20,
			Color.LIGHT_GRAY,
			4.0
		)

	# NAVE
	if tiempo_mision > 0:
		dibujar_cohete(posicion_nave)

	# MENSAJES
	if mision_fallida:
		draw_string(
			ThemeDB.fallback_font,
			Vector2(pantalla.x * 0.38, pantalla.y * 0.52),
			"MISION FALLIDA",
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			28,
			Color.RED
		)

	elif finalizada:
		draw_string(
			ThemeDB.fallback_font,
			luna + Vector2(-90, -55),
			"ATERRIZAJE EXITOSO",
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			17,
			Color.GREEN
		)


# =====================================
# DIBUJAR COHETE
# =====================================

func dibujar_cohete(posicion: Vector2) -> void:

	draw_set_transform(posicion, 0.0, Vector2.ONE)

	draw_colored_polygon(
		PackedVector2Array([
			Vector2(0, -25),
			Vector2(10, 5),
			Vector2(7, 20),
			Vector2(-7, 20),
			Vector2(-10, 5)
		]),
		Color.WHITE
	)

	draw_colored_polygon(
		PackedVector2Array([
			Vector2(0, -25),
			Vector2(10, 5),
			Vector2(-10, 5)
		]),
		Color.RED
	)

	draw_circle(Vector2(0, -3), 4, Color.CYAN)

	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-7, 12),
			Vector2(-17, 23),
			Vector2(-7, 20)
		]),
		Color.RED
	)

	draw_colored_polygon(
		PackedVector2Array([
			Vector2(7, 12),
			Vector2(17, 23),
			Vector2(7, 20)
		]),
		Color.RED
	)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# =====================================
# BOTONES
# =====================================

func _on_iniciar_pressed() -> void:

	if not finalizada:
		iniciada = true
		pausada = false


func _on_pausa_pressed() -> void:

	if iniciada and not finalizada:

		pausada = not pausada

		boton_pausa.text = "CONTINUAR" if pausada else "PAUSAR"


func _on_reiniciar_pressed() -> void:

	reiniciar_mision()


# =====================================
# REINICIAR MISION
# =====================================

func reiniciar_mision() -> void:

	tiempo_mision = 0.0

	iniciada = false
	pausada = false
	finalizada = false
	mision_fallida = false

	etapa_actual = 0
	mensaje_fallo = ""

	etapa_1_separada = false
	etapa_2_separada = false
	cubierta_separada = false

	boton_pausa.text = "PAUSAR"
	mensaje_label.text = "SISTEMAS LISTOS"

	actualizar_posicion_nave()
	actualizar_interfaz()
	queue_redraw()
