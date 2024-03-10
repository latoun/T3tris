extends Node3D

func _ready():
	var preload_tile = preload("res://grid_tile.tscn")
	var mat = preload_tile.instantiate().get_surface_override_material(0).duplicate()
	mat.albedo_color = Color("7F7F7F")
	for x in range(-2, 3):
		for z in range(-2, 3):
			var tile = preload_tile.instantiate()
			tile.position = Vector3(x,-0.5,z)
			if (x + z) % 2 == 0:
				tile.set_surface_override_material(0, mat)
			add_child(tile)
	for i in range(-2, 3):
		var tile = preload_tile.instantiate()
		var mesh = tile.mesh.duplicate()
		mesh.size = Vector2(1, 20)
		tile.mesh = mesh
		tile.position = Vector3(i, 9.5, -2.5)
		tile.rotate_x(PI/2)
		if i % 2 == 0: 
			tile.set_surface_override_material(0, mat)
		add_child(tile)
		tile = preload_tile.instantiate()
		mesh = tile.mesh.duplicate()
		mesh.size = Vector2(20, 1)
		tile.mesh = mesh
		tile.position = Vector3(-2.5, 9.5, i)
		tile.rotate_z(-PI/2)
		if i % 2 == 0: 
			tile.set_surface_override_material(0, mat)
		add_child(tile)
