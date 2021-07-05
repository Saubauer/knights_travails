require_relative 'lib/classes'

board = Board.new(16, 16)

board.knight_moves([0, 0], [0, 15])
board.knight_moves([2, 5], [1, 10])
board.knight_moves([0, 0], [15, 15])
