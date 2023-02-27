
AIPlayer = new Player

AIPlayer.selectColumn = function(piece)
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
