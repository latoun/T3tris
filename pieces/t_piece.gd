extends Node3D

@export var minoes = [[0,0,0], [0,1,0], [-1,0,0], [1,0,0]]

# I give up, kick table will not match SRS

var base_kicks = [
	[[0,0,0]],
	[[0,0,0]],
	[[0,0,0]],
	[[0,0,0]],
	[[0,0,0]],
	[[0,0,0]],
	]

var kicks = [
	[[0,0,0]],
	[[0,0,0]],
	[[0,0,0]],
	[[0,0,0]],
	[[0,0,0]],
	[[0,0,0]],
	]

func get_kicks(rot):
	if rot[0] == 1:
		return kicks[0]
	if rot[0] == -1:
		return kicks[1]
	if rot[1] == 1:
		return kicks[2]
	if rot[1] == -1:
		return kicks[3]
	if rot[2] == 1:
		return kicks[4]
	if rot[2] == -1:
		return kicks[5]

func update_kicks(d):
	if d[0] == 1:
		var tmp = kicks[2].duplicate()
		kicks[2] = kicks[4]
		kicks[4] = kicks[3]
		kicks[3] = kicks[5]
		kicks[5] = tmp
	if d[0] == -1:
		var tmp = kicks[4].duplicate()
		kicks[4] = kicks[2]
		kicks[2] = kicks[5]
		kicks[5] = kicks[3]
		kicks[3] = tmp
	if d[1] == 1:
		var tmp = kicks[0].duplicate()
		kicks[0] = kicks[5]
		kicks[5] = kicks[1]
		kicks[1] = kicks[4]
		kicks[4] = tmp
	if d[1] == -1:
		var tmp = kicks[5].duplicate()
		kicks[5] = kicks[0]
		kicks[0] = kicks[4]
		kicks[4] = kicks[1]
		kicks[1] = tmp
	if d[2] == 1:
		var tmp = kicks[0].duplicate()
		kicks[0] = kicks[2]
		kicks[2] = kicks[1]
		kicks[1] = kicks[3]
		kicks[3] = tmp
	if d[2] == -1:
		var tmp = kicks[2].duplicate()
		kicks[2] = kicks[0]
		kicks[0] = kicks[3]
		kicks[3] = kicks[1]
		kicks[1] = tmp
	
	for i in range(6):
		for j in range(len(kicks[i])):
			var kick = kicks[i][j]
			if d[0] != 0:
				kicks[i][j] = [kick[0], d[0]*kick[2], -d[0]*kick[1]]
			if d[1] != 0:
				kicks[i][j] = [-d[1]*kick[2], kick[1], d[1]*kick[0]]
			if d[2] != 0:
				kicks[i][j] = [d[2]*kick[1], -d[2]*kick[0], kick[2]]
	
	
	
	
func rotate_minoes(d):
	for i in range(4):
		var mino = minoes[i]
		if d[0] != 0:
			minoes[i] = [mino[0], d[0]*mino[2], -d[0]*mino[1]]
		if d[1] != 0:
			minoes[i] = [-d[1]*mino[2], mino[1], d[1]*mino[0]]
		if d[2] != 0:
			minoes[i] = [d[2]*mino[1], -d[2]*mino[0], mino[2]]

func update_render():
	for i in range(4):
		var mino = self.find_child("Mino" + str(i))
		mino.set_position(Vector3(minoes[i][0], minoes[i][1], minoes[i][2]))
