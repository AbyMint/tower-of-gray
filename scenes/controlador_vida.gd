extends Node2D
# Controlador de daño y vida
# Crea nuevos corazones cuando sea necesario, actualiza la UI y maneja la lógica de daño y curación.

# Nodos de referencia
@onready var contenedor_corazones = $CanvasLayer/ContenedorCorazones if has_node("CanvasLayer/ContenedorCorazones") else null

# Variables de control
var corazones_totales = 3  # Cantidad inicial de corazones
var corazones_actuales = 3  # Vida actual
var tiempo_invulnerabilidad = 1.0  # Tiempo en segundos de invulnerabilidad
var puede_recibir_danio = true  # Flag para controlar el tiempo de invulnerabilidad
var escena_corazon = preload("res://scenes/corazon.tscn")  # Precargar la escena del corazón
var separacion_corazones = 40  # Separación horizontal entre corazones en píxeles

# Señales
signal vida_cambiada(corazones_actuales)
signal jugador_muerto()

func _ready():
	# Inicializar los corazones en la UI
	if contenedor_corazones:
		_inicializar_corazones()
	else:
		push_error("No se encontró el nodo ContenedorCorazones. Asegúrate de que existe y está correctamente nombrado.")

# Crea la estructura básica de UI si no existe
func _crear_estructura_ui():
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "CanvasLayer"
	canvas_layer.layer = 10  # Capa alta para asegurar que esté por encima de todo
	
	var container = HBoxContainer.new()
	container.name = "ContenedorCorazones"
	container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	container.position = Vector2(20, 20)  # Posición en la esquina superior izquierda con margen
	
	canvas_layer.add_child(container)
	add_child(canvas_layer)
	
	contenedor_corazones = container
	_inicializar_corazones()

# Inicializa los corazones en la UI
func _inicializar_corazones():
	# Eliminar corazones existentes si los hay
	for hijo in contenedor_corazones.get_children():
		hijo.queue_free()
	
	# Crear los corazones iniciales
	for i in range(corazones_totales):
		var nuevo_corazon = escena_corazon.instantiate()
		nuevo_corazon.name = "Corazon_" + str(i)
		nuevo_corazon.custom_minimum_size = Vector2(40, 40)  # or your heart size + margin
		# Si estamos usando un HBoxContainer, no necesitamos posicionar manualmente
		# Si no, establecemos la posición manualmente
		if not contenedor_corazones is HBoxContainer:
			nuevo_corazon.position.x = i * separacion_corazones
		
		contenedor_corazones.add_child(nuevo_corazon)

# Función para recibir daño
func recibir_danio(cantidad := 1):
	if not puede_recibir_danio:
		return
	
	puede_recibir_danio = false
	corazones_actuales = max(0, corazones_actuales - cantidad)
	
	# Actualizar la UI
	_actualizar_corazones_ui()
	
	# Emitir señal de cambio de vida
	emit_signal("vida_cambiada", corazones_actuales)
	
	# Verificar si el jugador ha muerto
	if corazones_actuales <= 0:
		emit_signal("jugador_muerto")
	
	# Iniciar temporizador de invulnerabilidad
	var timer = get_tree().create_timer(tiempo_invulnerabilidad)
	timer.timeout.connect(_terminar_invulnerabilidad)

# Función para curar vida
func curar(cantidad := 1):
	corazones_actuales = min(corazones_totales, corazones_actuales + cantidad)
	
	# Actualizar la UI
	_actualizar_corazones_ui()
	
	# Emitir señal de cambio de vida
	emit_signal("vida_cambiada", corazones_actuales)

# Actualiza la visualización de los corazones en la UI
func _actualizar_corazones_ui():
	var corazones = contenedor_corazones.get_children()
	
	# Actualizar cada corazón según la vida actual
	for i in range(corazones.size()):
		var corazon = corazones[i]
		
		# Los corazones se rompen de derecha a izquierda (índice más alto primero)
		var indice_inverso = corazones.size() - 1 - i
		
		if indice_inverso < corazones_actuales:
			# Corazón completo
			corazon.texture = preload("res://sprites/corazonLleno.png")
		else:
			# Corazón roto
			corazon.texture = preload("res://sprites/corazonRoto.png")

# Termina el período de invulnerabilidad
func _terminar_invulnerabilidad():
	puede_recibir_danio = true
