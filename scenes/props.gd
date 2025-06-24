extends TileMapLayer


func _on_ready() -> void:
	print("Iniciando creación de áreas para props...")
	var count = 0
	
	for tile_pos in get_used_cells():
		var tile_rect = get_cell_tile_data(tile_pos)
		if tile_rect:
			var area = Area2D.new()
			var collision = CollisionShape2D.new()
			var shape = RectangleShape2D.new()
			
			# Asignamos un nombre único para facilitar la depuración
			area.name = "PropArea_" + str(tile_pos.x) + "_" + str(tile_pos.y)
			
			# Configuramos para detectar todo tipo de interacciones
			area.collision_layer = 0xFFFFFFFF  # Todas las capas
			area.collision_mask = 0xFFFFFFFF   # Todas las máscaras
			# division de enteros, decimal irrelevante de momento
			shape.extents = Vector2(tile_set.tile_size.x / 2, tile_set.tile_size.y / 2)
			collision.shape = shape
			collision.position = Vector2(tile_set.tile_size.x / 2, tile_set.tile_size.y / 2)
			area.position = map_to_local(tile_pos)
			
			area.monitorable = true
			area.monitoring = true
			collision.debug_color = Color(1, 0, 0, 0.5)
			
			area.add_child(collision)
			
			# Conectamos múltiples señales para asegurar la detección
			area.area_entered.connect(_on_area_area_entered.bind(tile_pos))
			area.body_entered.connect(_on_area_body_entered.bind(tile_pos))
			
			add_child(area)
			count += 1
	
	print("Se crearon " + str(count) + " áreas para props.")


# Esta función se llama cuando otra área entra en contacto
func _on_area_area_entered(other_area, tile_pos: Vector2i) -> void:
	print("Área detectada: ", other_area.name, " en posición: ", tile_pos)
	
	# Verificamos si el área pertenece a la ardilla de varias maneras posibles
	var parent = other_area.get_parent()
	if parent and "Ardilla" in parent.name or "Player" in parent.name or parent is PlatformerController2D:
		print("¡Hitbox de la ardilla activó un área en la posición: ", tile_pos, "!")
		
		# Intentamos llamar a la función en hitboxArdilla.gd
		if other_area.has_method("on_prop_interaction"):
			other_area.on_prop_interaction(tile_pos)
		elif parent.has_method("on_prop_interaction"):
			parent.on_prop_interaction(tile_pos)


# Esta función se llama cuando un cuerpo físico entra en el área
func _on_area_body_entered(body, tile_pos: Vector2i) -> void:
	print("Cuerpo detectado: ", body.name, " en posición: ", tile_pos)
	
	# Verificamos si el cuerpo es la ardilla
	if "Ardilla" in body.name or "Player" in body.name or body is PlatformerController2D:
		print("¡Cuerpo de la ardilla activó un área en la posición: ", tile_pos, "!")
		
		# Buscamos el nodo hitboxArdilla entre los hijos
		for child in body.get_children():
			if child.get_script() and "hitboxArdilla" in child.get_script().resource_path:
				if child.has_method("on_prop_interaction"):
					child.on_prop_interaction(tile_pos)
					return
		
		# Si no encontramos la hitbox específica, intentamos con el cuerpo directamente
		if body.has_method("on_prop_interaction"):
			body.on_prop_interaction(tile_pos)
