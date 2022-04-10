extends Node2D

var mouse_pos = get_local_mouse_position()
var cur_pos = load("res://Scripts/ClassPosition.gd").new()
var bot = load("res://Scripts/ClassBot.gd").new(cur_pos)

func _ready():
	randomize()
	#cur_pos.load_arr([
	#	[1, -1, 1, -1, 1, -1],
	#	[-1, 1, -1, 1, -1, 1],
	#	[1, 1, 1, -1, 1, -1],
	#	[0, 0, 0, 0, 0, 0],
	#	[-1, 1, -1, 1, -1, 1],
	#	[1, -1, 1, -1, 1, -1],
	#	[-1, 1, -1, 1, -1, 1],
	#])
	
	cur_pos.load_arr([
		[1, -1, 1, -1, 1, -1],
		[-1, 1, -1, 1, -1, 1],
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0],
		[1, -1, 1, -1, 1, -1],
		[-1, 1, -1, 1, -1, 1],
	])

func _process(delta):
	if gl.player_turn == false and not gl.fl_game_end:
		bot_turn()
	
	mouse_pos = get_local_mouse_position()
	update()

func _draw():
	for col in range(gl.table_width):
		for row in range(gl.table_height):
			var i = col
			var j = gl.table_height - row - 1
			var start = gl.start_pos + Vector2(i * 64, j * 64)
			var end = gl.start_pos + Vector2(i * 64, j * 64) + Vector2(64, 64)
			if (mouse_pos[0] > start[0]) and (mouse_pos[1] > start[1]) and (mouse_pos[1] < end[1]) and (mouse_pos[0] < end[0]):
				draw_clicable_pos(gl.start_pos + Vector2(i * 64, j * 64), gl.start_pos + Vector2(i * 64 + 64, j * 64 + 64))
	
	for col in range(gl.table_width):
		for row in range(gl.table_height):
			var i = col
			var j = gl.table_height - row - 1
			if cur_pos.field[i][row] == -1:
				draw_circle(gl.start_pos + Vector2(i * 64, j * 64) + Vector2(gl.width / 2, gl.height / 2), 28, Color.red)
			elif cur_pos.field[i][row] == 1:
				draw_circle(gl.start_pos + Vector2(i * 64, j * 64) + Vector2(gl.width / 2, gl.height / 2), 28, Color.orange)
	
	for i in range(gl.table_width):
		for j in range(gl.table_height):
			draw_square(gl.start_pos + Vector2(i * 64, j * 64), gl.start_pos + Vector2(i * 64 + 64, j * 64 + 64))
	
	if gl.win_line != null:
		for pos in gl.win_line:
			var i = gl.table_height - pos[0] - 1
			var j = pos[1]
			draw_circle(gl.start_pos + Vector2(j * gl.width, i * gl.height) + Vector2(gl.width / 2, gl.height / 2), 12, Color.white)

func draw_clicable_pos(start, end):
	draw_line(start, (end - Vector2(0, gl.height)), Color.black, 5.0)
	draw_line((end - Vector2(0, gl.height)), end, Color.black, 5.0)
	draw_line(end, (start + Vector2(0, gl.height)), Color.black, 5.0)
	draw_line((start + Vector2(0, gl.height)), start, Color.black, 5.0)

func draw_square(start, end):
	draw_line(start, end - Vector2(0, gl.height), Color.black, 2.0)
	draw_line(end - Vector2(0, gl.height), end, Color.black, 2.0)
	draw_line(end, start + Vector2(0, gl.height), Color.black, 2.0)
	draw_line(start + Vector2(0, gl.height), start, Color.black, 2.0)

func table_click(mouse_pos):
	var x = mouse_pos[0]
	var y = mouse_pos[1]
	
	if(x >= gl.start_pos[0]
		and x <= (gl.start_pos[0] + gl.table_width * gl.width)
		and y >= gl.start_pos[1]
		and y <= (gl.start_pos[1] + gl.table_height * gl.height)):
		return true
	
	return false
		
func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if table_click(mouse_pos):
			var col = int((mouse_pos[0] - gl.start_pos[0]) / gl.width)
			if cur_pos.can_play(col) and gl.player_turn and not gl.fl_game_end:
				var row = cur_pos.play(col)
				check_game_over(row, col)
				gl.player_turn = false

func check_game_over2(i, j):
	print(cur_pos.nbMoves())
	
	var gr = cur_pos.field
	var tb = gl.table_size - Vector2(1, 1)
	var need_score
	
	if cur_pos.last_move == cur_pos.human:
		gl.winner = "red"
		need_score = -4
	else:
		gl.winner = "org"
		need_score = 4
	
	
	var left_id_horiz = j - min(j, gl.win_lenght - 1)
	var right_id_horiz = j + min(tb[0] - j, gl.win_lenght - 1)
	
	for x in range(left_id_horiz, right_id_horiz + 1 - 3):
		if gr[i][x] + gr[i][x + 1] + gr[i][x + 2] + gr[i][x + 3] == need_score:
			gl.fl_game_end = true
			gl.win_line = [Vector2(i, x), Vector2(i, x + 1), Vector2(i, x + 2), Vector2(i, x + 3)]
			print(gl.winner, 'win!')
	
	
	var up_id_vert = i - min(i, gl.win_lenght - 1)
	var down_id_vert = i + min(tb[1] - i, gl.win_lenght - 1)
	
	for x in range(up_id_vert, down_id_vert + 1 - 3):
		if gr[x][j] + gr[x + 1][j] + gr[x + 2][j] + gr[x + 3][j] == need_score:
			gl.fl_game_end = true
			gl.win_line = [Vector2(x, j), Vector2(x + 1, j), Vector2(x + 2, j), Vector2(x + 3, j)]
	
	
	var diag_id_up_left = min(min(i, j), gl.win_lenght - 1)
	var diag_id_down_right = min(min(tb[1] - i, tb[0] - j), gl.win_lenght - 1)
	var st_j = j - diag_id_up_left
	var st_i = i - diag_id_up_left
	
	for x in range(diag_id_up_left + diag_id_down_right + 1 - 3):
		if gr[st_i + x][st_j + x] + gr[st_i + 1 + x][st_j + 1 + x] + gr[st_i + 2 + x][st_j + 2 + x] + gr[st_i + 3 + x][st_j + 3 + x] == need_score:
			gl.fl_game_end = true
			gl.win_line = [Vector2(st_i + x, st_j + x), Vector2(st_i + x + 1, st_j + x + 1), Vector2(st_i + x + 2, st_j + x + 2), Vector2(st_i + x + 3, st_j + x + 3)]
	
	
	var diag_id_up_right = min(min(tb[0] - j, i), gl.win_lenght - 1)
	var diag_id_down_left = min(min(j, tb[1] - i), gl.win_lenght - 1)
	st_j = j - diag_id_down_left
	st_i = i + diag_id_down_left
	
	for x in range(diag_id_up_right + diag_id_down_left + 1 - 3):
		if gr[st_i - x][st_j + x] + gr[st_i - 1 - x][st_j + 1 + x] + gr[st_i - 2 - x][st_j + 2 + x] + gr[st_i - 3 - x][st_j + 3 + x] == need_score:
			gl.fl_game_end = true
			gl.win_line = [Vector2(st_i - x, st_j + x), Vector2(st_i - x - 1, st_j + x + 1), Vector2(st_i - x - 2, st_j + x + 2), Vector2(st_i - x - 3, st_j + x + 3)]

func check_game_over(row, col):
	if cur_pos.isWinningMove(col):
		gl.fl_game_end = true
		if gl.player_turn:
			print('Human win')
		else:
			print('AI win')

func bot_turn():
	var col = randi() % gl.table_width
	while not cur_pos.can_play(col):
		col = randi() % gl.table_width
	
	var row = cur_pos.play(col)
	check_game_over(row, col)
	#bot = bot_algo(cur_pos)
	gl.player_turn = true

func bot_algo(p):
	#const empty = 0
	#const human = -1
	#const ai = 1

	if p.nbMoves() == gl.table_width * gl.table_height:
		return 0
	
	for x in range(gl.table_width):
		if p.can_play(x) and p.isWinningMove(x):
			return (gl.table_width * gl.table_height + 1 - p.nbMoves())/2
	
	var bestScore = -gl.table_width * gl.table_height
	for x in range(gl.table_width):
		if p.can_play(x):
			var p2 = Position.new(p)
			p2.play(x)
			var score = -bot_algo(p2)
			if score > bestScore: bestScore = score
	return bestScore
