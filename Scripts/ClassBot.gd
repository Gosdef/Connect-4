class_name Bot

const empty = 0
const player = -1
const ai = 1

var field
var p

func _init(pos):
	self.p = pos
	self.field = pos.field

func turn():
	if self.p.nbMoves() == gl.table_size[0] * gl.table_size[1]:
		return 0
	
	for x in range(gl.table_size[0]):
		if self.p.can_play(x) and self.p.isWinningMove(x):
			return (gl.table_size[0] * gl.table_size[1] + 1 - p.nbMoves())/2
	
	var bestScore = -gl.table_size[0] * gl.table_size[1]
	for x in range(gl.table_size[0]):
		if self.p.can_play():
			var p2 = Position.new(p)
			p2.play(x)
			var score

func show():
	for row in range(gl.table_size[1]):
		print(self.field[row])
