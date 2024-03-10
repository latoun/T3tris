extends Node3D

@export var MinoShape : Node

var pos
var size = [5, 20, 5]

func _ready():
	pass

func get_kicks(rot):
	if rot[0] == 1:
		return MinoShape.kicks[0]
	if rot[0] == -1:
		return MinoShape.kicks[1]
	if rot[1] == 1:
		return MinoShape.kicks[2]
	if rot[1] == -1:
		return MinoShape.kicks[3]
	if rot[2] == 1:
		return MinoShape.kicks[4]
	if rot[2] == -1:
		return MinoShape.kicks[5]

func update_kicks(d):
	if d[0] == 1:
		var tmp = MinoShape.kicks[2].duplicate()
		MinoShape.kicks[2] = MinoShape.kicks[4]
		MinoShape.kicks[4] = MinoShape.kicks[3]
		MinoShape.kicks[3] = MinoShape.kicks[5]
		MinoShape.kicks[5] = tmp
	if d[0] == -1:
		var tmp = MinoShape.kicks[4].duplicate()
		MinoShape.kicks[4] = MinoShape.kicks[2]
		MinoShape.kicks[2] = MinoShape.kicks[5]
		MinoShape.kicks[5] = MinoShape.kicks[3]
		MinoShape.kicks[3] = tmp
	if d[1] == 1:
		var tmp = MinoShape.kicks[0].duplicate()
		MinoShape.kicks[0] = MinoShape.kicks[5]
		MinoShape.kicks[5] = MinoShape.kicks[1]
		MinoShape.kicks[1] = MinoShape.kicks[4]
		MinoShape.kicks[4] = tmp
	if d[1] == -1:
		var tmp = MinoShape.kicks[5].duplicate()
		MinoShape.kicks[5] = MinoShape.kicks[0]
		MinoShape.kicks[0] = MinoShape.kicks[4]
		MinoShape.kicks[4] = MinoShape.kicks[1]
		MinoShape.kicks[1] = tmp
	if d[2] == 1:
		var tmp = MinoShape.kicks[0].duplicate()
		MinoShape.kicks[0] = MinoShape.kicks[2]
		MinoShape.kicks[2] = MinoShape.kicks[1]
		MinoShape.kicks[1] = MinoShape.kicks[3]
		MinoShape.kicks[3] = tmp
	if d[2] == -1:
		var tmp = MinoShape.kicks[2].duplicate()
		MinoShape.kicks[2] = MinoShape.kicks[0]
		MinoShape.kicks[0] = MinoShape.kicks[3]
		MinoShape.kicks[3] = MinoShape.kicks[1]
		MinoShape.kicks[1] = tmp
	
	for i in range(6):
		for j in range(len(MinoShape.kicks[i])):
			var kick = MinoShape.kicks[i][j]
			if d[0] != 0:
				MinoShape.kicks[i][j] = [kick[0], d[0]*kick[2], -d[0]*kick[1]]
			if d[1] != 0:
				MinoShape.kicks[i][j] = [-d[1]*kick[2], kick[1], d[1]*kick[0]]
			if d[2] != 0:
				MinoShape.kicks[i][j] = [d[2]*kick[1], -d[2]*kick[0], kick[2]]

func rotate_piece(d, kick):
	rotate_minoes(d)
	move_piece(kick)
	update_kicks(d)

func rotate_minoes(d):
	for i in len(MinoShape.minoes):
		var mino = MinoShape.minoes[i]
		if d[0] != 0:
			MinoShape.minoes[i] = [
				mino[0],
				d[0]*mino[2],
				-d[0]*mino[1]
			]
		if d[1] != 0:
			MinoShape.minoes[i] = [
				-d[1]*mino[2],
				mino[1],
				d[1]*mino[0]
			]
		if d[2] != 0:
			MinoShape.minoes[i] = [
				d[2]*mino[1],
				-d[2]*mino[0],
				mino[2]
			]

func move_piece(d):
	pos = [pos[0] + d[0], pos[1] + d[1], pos[2] + d[2]]

func is_valid_move(grid, d):
	for mino in MinoShape.minoes:
		var tmp = array_add(mino, pos)
		var end_pos = array_add(tmp, d)
		for i in range(3):
			if not (0 <= end_pos[i] and end_pos[i] < size[i]) :
				return false
		if grid[end_pos[0]][end_pos[1]][end_pos[2]] == 1:
			return false
	return true

func is_valid_rotation(grid, d):
	# Simplest shit, we apply the rotation and we try every kick as a movement
	rotate_minoes(d)
	for kick in get_kicks(d):
		if is_valid_move(grid, kick):
			rotate_minoes([-d[0], -d[1], -d[2]])
			return kick
	rotate_minoes([-d[0], -d[1], -d[2]])
	return false

func update_render():
	position = Vector3(pos[0] - 2, pos[1], pos[2] - 2)
	var MinoNodes = find_child("Minoes").get_children()
	for i in len(MinoNodes):
		MinoNodes[i].position = Vector3(
			MinoShape.minoes[i][0],
			MinoShape.minoes[i][1],
			MinoShape.minoes[i][2]
		)

func init_render():
	for mino in find_child("Minoes").get_children():
		mino.set_color(Color(MinoShape.color))
	update_render()

func array_add(a, b):
	var res = []
	for i in range(len(a)):
		res.append(a[i] + b[i])
	return res

