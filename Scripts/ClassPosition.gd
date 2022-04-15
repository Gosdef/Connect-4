class_name Position

const empty = 0
const human = -1
const ai = 1

var field = []
var height = []  # Number of stones per column
var last_move
var moves

func _init(pos = null):
	if pos:
		self.field = pos.field.duplicate(true)
		self.last_move = pos.last_move
		self.moves = pos.moves
		self.height = pos.height.duplicate(true)
	else:
		for row in range(gl.table_width):
			var add = []
			for column in range(gl.table_height):
				add.append(empty)
			self.field.append(add)

		for row in range(gl.table_width):
			self.height.append(empty)
		
		self.last_move = ai
		self.moves = 0

func can_play(column): 
	# return field[0][column] == empty
	return height[column] < gl.table_height

func isWinningMove___(j):
	var ans
	for row in range(gl.table_size[1] - 1, -1, -1):
		if self.field[row][j] == empty:
			ans = row
			break
	if ans == null:
		ans = j
	var i = ans
	
	var gr = self.field
	var tb = gl.table_size - Vector2(1, 1)
	var need_score
	
	if self.last_move == self.human:
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

func isWinningMove(col):
	#print('-----------------')
	var win_arr = []
	var current_player = last_move
	var prev_height = height[col] - 1
	# check for vertical alignments
	if(prev_height >= 3 
		and field[col][prev_height-1] == current_player 
		and field[col][prev_height-2] == current_player 
		and field[col][prev_height-3] == current_player):
			gl.win_line = [
				Vector2(prev_height, col), 
				Vector2(prev_height - 1, col), 
				Vector2(prev_height - 2, col), 
				Vector2(prev_height - 3, col)
			]
			
			return true
	
	var cor = []
	for dy in [-1, 0, 1]:  # Iterate on horizontal (dy = 0) or two diagonal directions (dy = -1 or dy = 1).
		cor = [Vector2(prev_height, col)]
		var nb = 0         # counter of the number of stones of current player surronding the played stone in tested direction
		for dx in [-1, 1]: # count continuous stones of current player on the left, then right of the played column.
			var x = col + dx
			var y = prev_height + dx * dy
			var condition = (
				(x >= 0) and
				(x < gl.table_width) and 
				(y >= 0) and 
				(y < gl.table_height) and 
				(field[x][y] == current_player)
			)
			while condition:
				cor.append(Vector2(y, x))
				x += dx
				y += dx * dy
				condition = (
					(x >= 0) and 
					(x < gl.table_width) and 
					(y >= 0) and 
					(y < gl.table_height) and 
					(field[x][y] == current_player)
				)
				nb += 1
		if(nb >= 3):
			gl.win_line = cor #[Vector2(1, 1), Vector2(1, 2), Vector2(1, 3), Vector2(1, 4)]
			return true  # there is an aligment if at least 3 other stones of the current user 
						 # are surronding the played stone in the tested direction.  
	return false

func isWinningMove2(col):
	#print('-----------------')
	var win_arr = []
	var current_player = -last_move
	var prev_height = height[col]
	# check for vertical alignments
	if(prev_height >= 3 
		and field[col][prev_height-1] == current_player 
		and field[col][prev_height-2] == current_player 
		and field[col][prev_height-3] == current_player):
			gl.win_line = [
				Vector2(prev_height, col), 
				Vector2(prev_height - 1, col), 
				Vector2(prev_height - 2, col), 
				Vector2(prev_height - 3, col)
			]
			
			return true
	
	var cor = []
	for dy in [-1, 0, 1]:  # Iterate on horizontal (dy = 0) or two diagonal directions (dy = -1 or dy = 1).
		cor = [Vector2(prev_height, col)]
		var nb = 0         # counter of the number of stones of current player surronding the played stone in tested direction
		for dx in [-1, 1]: # count continuous stones of current player on the left, then right of the played column.
			var x = col + dx
			var y = prev_height + dx * dy
			var condition = (
				(x >= 0) and
				(x < gl.table_width) and 
				(y >= 0) and 
				(y < gl.table_height) and 
				(field[x][y] == current_player)
			)
			while condition:
				cor.append(Vector2(y, x))
				x += dx
				y += dx * dy
				condition = (
					(x >= 0) and 
					(x < gl.table_width) and 
					(y >= 0) and 
					(y < gl.table_height) and 
					(field[x][y] == current_player)
				)
				nb += 1
		if(nb >= 3):
			gl.win_line = cor #[Vector2(1, 1), Vector2(1, 2), Vector2(1, 3), Vector2(1, 4)]
			return true  # there is an aligment if at least 3 other stones of the current user 
						 # are surronding the played stone in the tested direction.  
	return false

func create_win_line(dir):
	var win_arr = []
	var x = dir[1][0]
	var y = dir[1][1]
	var dir_x = dir[0][0]
	var dir_y = dir[0][1]
	
	print([dir[0], Vector2(x, y)])
	
	while x >= 0  and y >= 0 and x < gl.table_width  and y < gl.table_height and field[x][y] == last_move: # current_player = last_move
		win_arr.append(Vector2(x, y))
		x -= dir_x
		y -= dir_y * dir_x
	
	x = dir[1][0]
	y = dir[1][1]
	
	while x >= 0  and y >= 0 and x < gl.table_width and y < gl.table_height and field[x][y] == last_move: # current_player = last_move
		win_arr.append(Vector2(x, y))
		x += dir_x
		y += dir_y * dir_x
	
	gl.win_line = win_arr.duplicate(true)

func play(col):
	var row = self.height[col]
	self.field[col][row] = -self.last_move
	self.height[col] += 1
	self.moves += 1
	self.last_move = -self.last_move
	return row

func show():
	for row in range(gl.table_height):
		print(self.field[row])

func load_arr(arr):
	self.moves = 0
	self.field = arr.duplicate(true)
	var sm = 0
	for i in range(gl.table_width):
		for j in range(gl.table_height):
			if self.field[i][j] != empty:
				sm += self.field[i][j]
				self.moves += 1
				self.height[i] += 1
	if sm == 0:
		self.last_move = ai
	elif sm == 1:
		self.last_move = human
	else:
		print('Wrong number of moves')

func load_arr_by_string(string):
	for i in string:
		play(int(i) - 1)

func nbMoves():
	return self.moves
