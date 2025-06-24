extends CollisionShape2D

# Esta función será llamada cuando la hitbox interactúe con un prop
func on_prop_interaction(tile_pos: Vector2i) -> void:
	print("¡La ardilla interactuó con un prop en la posición: ", tile_pos, "!")
	
	# Aquí puedes añadir cualquier lógica específica que necesites
	# Por ejemplo, reproducir un sonido, animar algo, etc.
	# Buscar el controlador de vida en el árbol de escena
	var controlador_vida = get_tree().get_first_node_in_group("controlador_vida")
	
	# Si encontramos el controlador, llamamos a su función para recibir daño
	if controlador_vida:
		controlador_vida.recibir_danio(1)
	else:
		print("No se encontró el controlador de vida. Asegúrate de que existe y está en el grupo 'controlador_vida'.")
