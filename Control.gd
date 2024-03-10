extends Node3D

var time_elapsed = 0
var grid = []
var size
var current_piece = [2,12,2]
var queue = []
var piece

@export var HUD : CanvasLayer
@export var MinoesRender : Node
@export var GridNode : Node

const speed = 2
const preload_piece = preload("res://piece.tscn")

var shapes = [
	preload("res://pieces/b_shape.tscn"),
	preload("res://pieces/d_shape.tscn"),
	preload("res://pieces/f_shape.tscn"),
	preload("res://pieces/i_shape.tscn"),
	preload("res://pieces/l_shape.tscn"),
	preload("res://pieces/o_shape.tscn"),
	preload("res://pieces/s_shape.tscn"),
	preload("res://pieces/t_shape.tscn"),
]

var letters = ['b', 'd', 'f', 'i', 'l', 'o', 's', 't']

func _ready():
	HUD = get_parent().find_child('HUD')
	size = MinoesRender.size
	init_grid()
	MinoesRender.generate_mino_nodes()
	queue = [0,1,2,3,4,5,6,7]
	queue.shuffle()
	var queuetmp = [0,1,2,3,4,5,6,7]
	queuetmp.shuffle()
	queue += queuetmp
	spawn_new_piece()

func _process(delta):
	if Input.is_action_just_pressed('move_left'):
		attempt_move([-1,0,0])
	if Input.is_action_just_pressed('move_right'):
		attempt_move([1,0,0])
	if Input.is_action_just_pressed('move_backward'):
		attempt_move([0,0,1])
	if Input.is_action_just_pressed('move_forward'):
		attempt_move([0,0,-1])
	if Input.is_action_just_pressed('rot_x_cw'):
		attempt_rotation([1,0,0])
	if Input.is_action_just_pressed('rot_x_ccw'):
		attempt_rotation([-1,0,0])
	if Input.is_action_just_pressed('rot_y_cw'):
		attempt_rotation([0,1,0])
	if Input.is_action_just_pressed('rot_y_ccw'):
		attempt_rotation([0,-1,0])
	if Input.is_action_just_pressed('rot_z_cw'):
		attempt_rotation([0,0,1])
	if Input.is_action_just_pressed('rot_z_ccw'):
		attempt_rotation([0,0,-1])
	if Input.is_action_just_pressed('hard_drop'):
		while attempt_move([0,-1,0]):
			pass
		time_elapsed = speed
	if Input.is_action_pressed('soft_drop'):
		delta *= 10
	
	#Natural fall gestion
	time_elapsed += delta
	while time_elapsed >= speed:
		time_elapsed -= speed
		if not attempt_move([0,-1,0]):
			add_to_grid()
			update_grid_render()
			GridNode.remove_child(piece)
			piece.queue_free()
			check_line_clears()
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

func attempt_move(d):
	if not piece.is_valid_move(grid, d):
		return false
	piece.move_piece(d)
	piece.update_render()
	time_elapsed = 0
	return true

func attempt_rotation(d):
	var kick = piece.is_valid_rotation(grid, d)
	if not kick:
		return false
	piece.rotate_piece(d, kick)
	piece.update_render()
	time_elapsed = 0
	return true

func add_to_grid():
	var minoes = piece.MinoShape.minoes
	for mino in minoes:
		var mino_pos = array_add(mino, piece.pos)
		grid[mino_pos[0]][mino_pos[1]][mino_pos[2]] = 1

func array_add(a, b):
	var res = []
	for i in range(len(a)):
		res.append(a[i] + b[i])
	return res

func spawn_new_piece():
	var piece_type = queue.pop_front()
	piece = preload_piece.instantiate()
	var shape = shapes[piece_type].instantiate()
	piece.MinoShape = shape
	piece.add_child(shape)
	if len(queue) == 8:
		var queuetmp = [0,1,2,3,4,5,6,7]
		queuetmp.shuffle()
		queue += queuetmp
	HUD.find_child('Label').text = "Next Pieces :\n"
	for i in range(6):
		HUD.find_child('Label').text += letters[queue[i]] + "\n"
	piece.pos = [2,12,2]
	time_elapsed = 0
	GridNode.add_child(piece)
	piece.init_render()

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
						transfer_mino_state(x, yy - 1, z)

func update_grid_render():
	var minoes = piece.MinoShape.minoes
	for mino in minoes:
		var mino_pos = array_add(mino, piece.pos)
		var mino_name =  "%s %s %s" % mino_pos
		var MinoNode = MinoesRender.find_child(mino_name, true, false)
		MinoNode.visible = true
		var mat = MinoNode.get_child(0).get_surface_override_material(0).duplicate()
		mat.albedo_color = Color(piece.MinoShape.color)
		MinoNode.get_child(0).set_surface_override_material(0, mat)

func transfer_mino_state(x,y,z):
	var low_mino = MinoesRender.find_child("%s %s %s" % [x,y,z], true, false)
	var high_mino = MinoesRender.find_child("%s %s %s" % [x,y + 1,z], true, false)
	low_mino.visible = high_mino.visible
	low_mino.get_child(0).set_surface_override_material(0, high_mino.get_child(0).get_surface_override_material(0))
	
