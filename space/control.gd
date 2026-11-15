
extends Control

# -----------------------------
# VARIABLES DE LA ORBITA
# -----------------------------

var a: float = 6.0
var e: float = 0.5
var inclinacion: float = 30.0
var periodo: float = 12.0
var velocidad: float = 1.0

var tiempo: float = 0.0
var animar: bool = true

var planeta: MeshInstance3D
var sol: MeshInstance3D
var linea_orbita: MeshInstance3D

var mundo: Node3D
var rotacion_orbita: Basis

var etiqueta_estado: Label
var etiqueta_excentricidad: Label
var etiqueta_tamano: Label
var etiqueta_inclinacion: Label
var etiqueta_velocidad: Label


func _ready() -> void:

	crear_escenario()
	crear_interfaz()
	actualizar_orbita()


func _process(delta: float) -> void:

	if animar:
		tiempo += delta * velocidad
		actualizar_planeta()


# -----------------------------
# ESCENARIO 3D
# -----------------------------

func crear_escenario() -> void:

	var contenedor = SubViewportContainer.new()

	contenedor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	contenedor.stretch = true

	add_child(contenedor)

	var viewport = SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	contenedor.add_child(viewport)

	mundo = Node3D.new()
	viewport.add_child(mundo)

	# Sol

	sol = MeshInstance3D.new()

	var esfera = SphereMesh.new()
	esfera.radius = 0.65
	esfera.height = 1.3

	sol.mesh = esfera

	var material_sol = StandardMaterial3D.new()
	material_sol.albedo_color = Color.ORANGE
	material_sol.emission_enabled = true
	material_sol.emission = Color.ORANGE

	sol.material_override = material_sol

	mundo.add_child(sol)

	# Planeta

	planeta = MeshInstance3D.new()

	var esfera_planeta = SphereMesh.new()
	esfera_planeta.radius = 0.25
	esfera_planeta.height = 0.5

	planeta.mesh = esfera_planeta

	var material_planeta = StandardMaterial3D.new()
	material_planeta.albedo_color = Color.DODGER_BLUE

	planeta.material_override = material_planeta

	mundo.add_child(planeta)

	# Camara

	var camara = Camera3D.new()
	camara.position = Vector3(0, 9, 15)
	camara.look_at(Vector3.ZERO, Vector3.UP)
	camara.current = true

	mundo.add_child(camara)

	# Luz

	var luz = DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-45, -30, 0)

	mundo.add_child(luz)


# -----------------------------
# INTERFAZ
# -----------------------------

func crear_interfaz() -> void:

	var panel = PanelContainer.new()

	panel.position = Vector2(20, 20)
	panel.custom_minimum_size = Vector2(300, 0)

	add_child(panel)

	var columna = VBoxContainer.new()
	columna.add_theme_constant_override("separation", 12)

	panel.add_child(columna)

	# Titulo

	var titulo = Label.new()
	titulo.text = "SIMULADOR ORBITAL"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	columna.add_child(titulo)

	var separador = HSeparator.new()
	columna.add_child(separador)

	# Estado

	etiqueta_estado = Label.new()
	etiqueta_estado.text = "Estado: Reproduciendo"

	columna.add_child(etiqueta_estado)

	# Excentricidad

	etiqueta_excentricidad = Label.new()
	columna.add_child(etiqueta_excentricidad)

	var slider_e = crear_slider(columna, 0.0, 0.95, e, 0.01)

	slider_e.value_changed.connect(
		func(valor):
			e = valor
			etiqueta_excentricidad.text = "Excentricidad: %.2f" % e
			actualizar_orbita()
	)

	etiqueta_excentricidad.text = "Excentricidad: %.2f" % e

	# Tamaño

	etiqueta_tamano = Label.new()
	columna.add_child(etiqueta_tamano)

	var slider_a = crear_slider(columna, 2.0, 12.0, a, 0.1)

	slider_a.value_changed.connect(
		func(valor):
			a = valor
			etiqueta_tamano.text = "Tamaño: %.1f" % a
			actualizar_orbita()
	)

	etiqueta_tamano.text = "Tamaño: %.1f" % a

	# Inclinacion

	etiqueta_inclinacion = Label.new()
	columna.add_child(etiqueta_inclinacion)

	var slider_i = crear_slider(columna, 0.0, 90.0, inclinacion, 1.0)

	slider_i.value_changed.connect(
		func(valor):
			inclinacion = valor
			etiqueta_inclinacion.text = "Inclinación: %.0f°" % inclinacion
			actualizar_orbita()
	)

	etiqueta_inclinacion.text = "Inclinación: %.0f°" % inclinacion

	# Velocidad

	etiqueta_velocidad = Label.new()
	columna.add_child(etiqueta_velocidad)

	var slider_v = crear_slider(columna, 0.1, 5.0, velocidad, 0.1)

	slider_v.value_changed.connect(
		func(valor):
			velocidad = valor
			etiqueta_velocidad.text = "Velocidad: %.1fx" % velocidad
	)

	etiqueta_velocidad.text = "Velocidad: %.1fx" % velocidad

	var separador2 = HSeparator.new()
	columna.add_child(separador2)

	# Botones

	var botones = HBoxContainer.new()
	columna.add_child(botones)

	var boton_play = Button.new()
	boton_play.text = "Play / Pause"
	boton_play.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	botones.add_child(boton_play)

	boton_play.pressed.connect(cambiar_estado)

	var boton_reset = Button.new()
	boton_reset.text = "Reset"
	boton_reset.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	botones.add_child(boton_reset)

	boton_reset.pressed.connect(reiniciar)


# -----------------------------
# CREAR SLIDERS
# -----------------------------

func crear_slider(contenedor: VBoxContainer, minimo: float, maximo: float, inicial: float, paso: float) -> HSlider:

	var slider = HSlider.new()

	slider.min_value = minimo
	slider.max_value = maximo
	slider.value = inicial
	slider.step = paso

	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	contenedor.add_child(slider)

	return slider


# -----------------------------
# PLAY / PAUSE
# -----------------------------

func cambiar_estado() -> void:

	animar = not animar

	if animar:
		etiqueta_estado.text = "Estado: Reproduciendo"
	else:
		etiqueta_estado.text = "Estado: Pausado"


# -----------------------------
# REINICIAR
# -----------------------------

func reiniciar() -> void:

	tiempo = 0.0
	actualizar_planeta()


# -----------------------------
# ACTUALIZAR ORBITA
# -----------------------------

func actualizar_orbita() -> void:

	rotacion_orbita = Basis(Vector3.RIGHT, deg_to_rad(45.0)) * Basis(Vector3(0, 0, 1), deg_to_rad(inclinacion))

	if is_instance_valid(linea_orbita):
		linea_orbita.queue_free()

	dibujar_orbita()
	actualizar_planeta()


# -----------------------------
# DIBUJAR ELIPSE
# -----------------------------

func dibujar_orbita() -> void:

	var malla = ImmediateMesh.new()

	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.CYAN

	malla.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, material)

	for i in range(121):

		var E = TAU * float(i) / 120.0

		var x = a * (cos(E) - e)
		var y = a * sqrt(1.0 - e * e) * sin(E)

		var punto = Vector3(x, y, 0)

		punto = rotacion_orbita * punto

		malla.surface_add_vertex(punto)

	malla.surface_end()

	linea_orbita = MeshInstance3D.new()
	linea_orbita.mesh = malla

	mundo.add_child(linea_orbita)


# -----------------------------
# ECUACION DE KEPLER
# -----------------------------

func resolver_kepler(M: float) -> float:

	var E = M

	for i in range(15):

		var numerador = E - e * sin(E) - M
		var denominador = 1.0 - e * cos(E)

		E -= numerador / denominador

	return E


# -----------------------------
# POSICION DEL PLANETA
# -----------------------------

func actualizar_planeta() -> void:

	var M = fposmod(TAU * tiempo / periodo, TAU)

	var E = resolver_kepler(M)

	var x = a * (cos(E) - e)
	var y = a * sqrt(1.0 - e * e) * sin(E)

	var posicion = Vector3(x, y, 0)

	posicion = rotacion_orbita * posicion

	planeta.position = posicion
