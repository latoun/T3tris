extends Node3D

@export var size = [5,20,5]

func generate_mino_nodes():
	var preload_mino = preload("res://mino.tscn")
	for x in range(size[0]):
		for y in range(size[1]):
			for z in range(size[2]):
				var mino = preload_mino.instantiate()
				add_child(mino)
				mino.name = "%s %s %s" % [x,y,z]
				mino.position.x = x - size[0] / 2
				mino.position.y = y
				mino.position.z = z - size[0] / 2
				mino.visible = false
