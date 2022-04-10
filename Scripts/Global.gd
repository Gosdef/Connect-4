extends Node

const start_pos = Vector2(448, 128)
const table_size = Vector2(7, 6)
const table_width = int(table_size[0])
const table_height = int(table_size[1])
const win_lenght = 4
const width = 64
const height = 64

var win_line
var winner

var fl_game_end = false
var player_turn = true
