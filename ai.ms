import "alphaBeta"
import "listUtil"

BoardNode = new alphaBeta.Node
BoardNode.pieces = null	// 2D array of 0 (empty), 1 (red), 2 (yellow)
BoardNode.player = 1	// 1 for red (minimizer), 2 for yellow (maximizer)
BoardNode.initFromGlobalState = function
	self.pieces = list.init2d(rowCount, colCount, 0)
	for row in range(0, rowCount-1)
		for col in range(0, colCount-1)
			p = Board.pieces[row][col]
			if p == null then continue
			if p.tint == "#FF0000" then
				self.pieces[row][col] = 1
			else
				self.pieces[row][col] = 2
			end if
		end for
	end for
end function

// get child states of this node (i.e., states that represent
// the game after all possible moves of self.player)
BoardNode.children = function
	return []  // override me!
end function

// get the heuristic value of this game state (< 0 if player 0
// is winning, > 0 if player 1 is winning)
BoardNode.heuristicValue = function
	return 0   // override me!
end function

// return whether the game is over
BoardNode.isGameOver = function
	
end function

// If the four coordinates contain pieces
// that are all the same (and nonzero), return 
// the value they all have (i.e., which player).
BoardNode.allSame = function(xy0, xy1, xy2, xy3)
	p = self.pieces
	c = p[xy0[0]][xy0[1]]
	if c == 0 then return 0
	if p[xy1[0]][xy1[1]] == c and
	   p[xy2[0]][xy2[1]] == c and
	   p[xy3[0]][xy3[1]] == c then return c
	return 0
end function

// Search for a winner in this board.  Return 0 if none,
// 1 if player 1, or 2 if player 2.
BoardNode.winner = function
	// horizontal
	for y in range(0, rowCount-1)
		for x in range(0, colCount-4)
			pl = self.allSame([x,y], [x+1,y], [x+2,y], [x+3,y])
			if pl then return pl
		end for
	end for
	// vertical
	for y in range(0, rowCount-4)
		for x in range(0, colCount-1)
			pl = self.allSame([x,y], [x,y+1], [x,y+2], [x,y+3])
			if pl then return pl
		end for
	end for
	// ToDo: diagonal!
	return 0
end function

AIPlayer = new Player

AIPlayer.selectColumnRandom = function(piece)
	// let's just pick a random move!
	while true
		col = ceil(rnd * 7)
		if Board.hasFreeRowAtColumn(col) then break
	end while
	for i in range(0, col)
		piece.moveToDroppingArea i
		wait 1/(col+1)
	end for
	return col
end function


AIPlayer.selectColumn = function(piece)
	return self.selectColumnRandom(piece)
	origin = new BoardNode
	origin.initFromGlobalState
	origin.player = 2		// for now, assume we are always player 2

end function