extends Node3D

var time_elapsed = 0
var grid = []
var size = [5,20,5]
var current_piece = [2,12,2]
var queue = []
var HUD


const speed = 2
const piece_scene = [
	preload("res://pieces/b_piece.tscn"),
	preload("res://pieces/d_piece.tscn"),
	preload("res://pieces/f_piece.tscn"),
	preload("res://pieces/i_piece.tscn"),
	preload("res://pieces/l_piece.tscn"),
	preload("res://pieces/o_piece.tscn"),
	preload("res://pieces/s_piece.tscn"),
	preload("res://pieces/t_piece.tscn"),
]

var letters = ['b', 'd', 'f', 'i', 'l', 'o', 's', 't']

func _ready():
	HUD = get_parent().find_child('HUD')
	init_grid()
	queue = [0,1,2,3,4,5,6,7]
	queue.shuffle()
	var queuetmp = [0,1,2,3,4,5,6,7]
	queuetmp.shuffle()
	queue += queuetmp
	spawn_new_piece()

func _process(delta):
	for piece in self.get_children():
		if Input.is_action_just_pressed('move_left'):
			move_piece(piece,[-1,0,0])
		if Input.is_action_just_pressed('move_right'):
			move_piece(piece,[1,0,0])
		if Input.is_action_just_pressed('move_backward'):
			move_piece(piece,[0,0,1])
		if Input.is_action_just_pressed('move_forward'):
			move_piece(piece,[0,0,-1])
		if Input.is_action_just_pressed('rot_x_cw'):
			rotate_piece(piece,[1,0,0])
		if Input.is_action_just_pressed('rot_x_ccw'):
			rotate_piece(piece,[-1,0,0])
		if Input.is_action_just_pressed('rot_y_cw'):
			rotate_piece(piece,[0,1,0])
		if Input.is_action_just_pressed('rot_y_ccw'):
			rotate_piece(piece,[0,-1,0])
		if Input.is_action_just_pressed('rot_z_cw'):
			rotate_piece(piece,[0,0,1])
		if Input.is_action_just_pressed('rot_z_ccw'):
			rotate_piece(piece,[0,0,-1])
		if Input.is_action_just_pressed('hard_drop'):
			while move_piece(piece,[0,-1,0]):
				pass
			add_to_grid(piece)
			self.remove_child(piece)
			for mino in piece.get_children():
				piece.remove_child(mino)
				mino.translate(Vector3(current_piece[0] -2, current_piece[1], current_piece[2] - 2))
				get_parent().find_child("Minoes").add_child(mino)
			piece.queue_free()
			spawn_new_piece()
		if Input.is_action_pressed('soft_drop'):
			delta *= 10
		time_elapsed += delta
		while time_elapsed > speed:
			time_elapsed -= speed
			if not move_piece(piece,[0,-1,0]):
				add_to_grid(piece)
				self.remove_child(piece)
				for mino in piece.get_children():
					piece.remove_child(mino)
					mino.translate(Vector3(current_piece[0] -2, current_piece[1], current_piece[2] - 2))
					get_parent().find_child("Minoes").add_child(mino)
				piece.queue_free()
				spawn_new_piece()

func init_grid():
	grid.resize(size[0])
	grid.fill(0)
	for gx in range(size[0]):
		grid[gx] = []
		grid[gx].resize(size[1])
		grid[gx].fill(0)
		for gy in range(size[1]):
			grid[gx][gy] = []
			grid[gx][gy].resize(size[2])
			grid[gx][gy].fill(0)

func move_piece(piece, d):
	var minoes = piece.minoes
	if not check_position(minoes, array_add(current_piece, d)):
		return false
	current_piece = array_add(current_piece, d)
	piece.translate(Vector3(d[0], d[1], d[2]))
	return true
	
func check_position(minoes, piece_pos):
	for mino in minoes:
		for i in range(3):
			var tmp = mino[i] + piece_pos[i]
			if not (0 <= tmp and tmp < size[i]) :
				return false
		var pos = array_add(mino, piece_pos)
		if grid[pos[0]][pos[1]][pos[2]] == 1:
			return false
	return true

func rotate_piece(piece,rot):
	piece.rotate_minoes(rot)
	var minoes = piece.minoes
	var kicks = piece.get_kicks(rot)
	for kick in kicks:
		var pos = array_add(kick, current_piece)
		if check_position(minoes, pos):
			piece.update_kicks(rot)
			piece.update_render()
			piece.translate(Vector3(kick[0], kick[1], kick[2]))
			current_piece = pos
			return true
	var inverse_rot = [-rot[0], -rot[1], -rot[2]]
	piece.rotate_minoes(inverse_rot)
	return false
	
func add_to_grid(piece):
	var minoes = piece.minoes
	for mino in minoes:
		var pos = array_add(mino, current_piece)
		grid[pos[0]][pos[1]][pos[2]] = 1

func array_add(a, b):
	var res = []
	for i in range(len(a)):
		res.append(a[i] + b[i])
	return res

func spawn_new_piece():
	var piece_type = queue.pop_front()
	var new_piece = piece_scene[piece_type].instantiate()
	if len(queue) == 8:
		var queuetmp = [0,1,2,3,4,5,6,7]
		queuetmp.shuffle()
		queue += queuetmp
	HUD.find_child('Label').text = "Next Pieces :\n"
	for i in range(6):
		HUD.find_child('Label').text += letters[queue[i]] + "\n"
	new_piece.position.y = 12
	self.add_child(new_piece)
	current_piece = [2,12,2]
	time_elapsed = 0
	check_line_clears()
	
	
func check_line_clears():
	for y in range(size[1] - 1, -1, -1):
		var clear = true
		for x in range(size[0]):
			for z in range(size[2]):
				if grid[x][y][z] == 0:
					clear = false
		if clear:
			for x in range(size[0]):
				for yy in range(y + 1, size[1]):
					for z in range(size[2]):
						grid[x][yy - 1][z] = grid[x][yy][z]
			var Minoes = get_parent().find_child('Minoes')
			for mino in Minoes.get_children():
				if  y - 0.5 < mino.position.y and mino.position.y < y + 0.5:
					Minoes.remove_child(mino)
					mino.queue_free()
					continue
				if  mino.position.y > y + 0.5:
					mino.translate(Vector3(0,-1,0))
