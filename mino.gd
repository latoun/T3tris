extends Node3D

func set_color(color):
	var mat = get_child(0).get_surface_override_material(0).duplicate()
	mat.albedo_color = color
	get_child(0).set_surface_override_material(0, mat)
