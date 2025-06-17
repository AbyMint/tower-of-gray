extends CollisionShape2D

# Esta función será llamada cuando la hitbox interactúe con un prop
func on_prop_interaction(tile_pos: Vector2i) -> void:
	print("¡La ardilla interactuó con un prop en la posición: ", tile_pos, "!")
	
	# Aquí puedes añadir cualquier lógica específica que necesites
	# Por ejemplo, reproducir un sonido, animar algo, etc.
