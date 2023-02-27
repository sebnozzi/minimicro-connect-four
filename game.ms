// == IMPORTS

import "animation"
import "solutions"
import "altSequence"

Animation = animation.Animation
newAlternatingSequence = @altSequence.newAlternatingSequence

// == CONSTANTS

colCount = 7
rowCount = 6

discSize = 70

marginSize = 10
boardMarginBottom = 30
droppingAreaOffset = 100

displayWidth = 960
displayHeight = 640

displayCenterX = displayWidth / 2
displayCenterY = displayHeight / 2

// == DISPLAY SETUP

clear

display(6).mode = displayMode.sprite
sprd = display(6)
sprd.clear

display(5).mode = displayMode.pixel
gfx = display(5)

// == MAIN

main = function
	
	Board.init
	DroppingArea.init
	
	players = newAlternatingSequence([RedPlayer, YellowPlayer])
	
	keepPlaying = true
	
	while keepPlaying
		
		Board.reset
		resetDisplays
		
		player = null
		solved = false
		
		while not Board.isFull
			
			player = players.next
			
			piece = player.newPiece
			
			targetPosition = DroppingArea.waitUntilDropped(piece)
			colNr = targetPosition.colNr
			rowNr = targetPosition.rowNr
			
			Board.movePiece piece,colNr,rowNr
			
			if Board.isSolvedByPiece(piece) then
				solvingPieces = Board.findSolvingPieces(piece)
				drawSolutionLine solvingPieces
				solved = true
				break
			end if
			
		end while
		
		if solved then
			print player.name + " player wins!"
		else
			print "Board full. Game over."
		end if
		
		answer = input("Play again? ")
		answer = answer.lower
		keepPlaying = answer.len > 0 and answer[0] == "y"
		
	end while
	
end function

// == BOARD

Board = new Sprite

Board.pieces = null

Board.init = function
	// Initialize model
	self.initModel
	// Set image
	self.image = generateBoardImg
	// Center horizontally
	self.x = displayCenterX 
	// Place towards bottom of display, with a certain margin
	self.y = displayCenterY - (displayHeight - boardTotalHeight) / 2 + boardMarginBottom
	self.width = self.image.width
	self.height = self.image.height	
	// Add to display
	sprd.sprites.push self
end function

Board.reset = function
	for rowNr in range(1,rowCount)
		for colNr in range(1,colCount)
			self.removePiece colNr,rowNr
		end for
	end for
end function

Board.initModel = function
	rows = []
	for rowNr in range(1,rowCount)
		column = []
		for colNr in range(1,colCount)
			column.push null
		end for
		rows.push column
	end for
	self.pieces = rows
end function

Board.freeRowAtColumn = function(colNr)
	for rowNr in range(1,rowCount)
		if not self.hasPiece(colNr,rowNr) then
			return rowNr
		end if
	end for
	return null
end function

Board.hasFreeRowAtColumn = function(colNr)
	return self.freeRowAtColumn(colNr) != null
end function

Board.isFull = function
	for colNr in range(1,colCount)
		if self.hasFreeRowAtColumn(colNr) then
			return false
		end if
	end for
	return true
end function

Board.isSolvedByPiece = function(startPiece)
	solvingPieces = self.findSolvingPieces(startPiece)
	return solvingPieces.len == 4
end function

Board.findSolvingPieces = function(startPiece)
	playerToMatch = startPiece.player
	
	solutions = solutions.solutionOffsets(4)
	
	for offsets in solutions
		solvingPieces = []
		for offset in offsets
			pieceColNr = startPiece.colNr + offset.col
			pieceRowNr = startPiece.rowNr + offset.row
			piece = self.getPiece(pieceColNr,pieceRowNr)
			if piece != null and piece.player == playerToMatch then
				solvingPieces.push piece
			end if
		end for
		if solvingPieces.len == 4 then return solvingPieces
	end for
	
	return []
end function

Board.getPiece = function(colNr,rowNr)
	if isValidPosition(colNr,rowNr) then
		row = self.pieces[rowNr - 1]
		return row[colNr - 1]
	else
		return null
	end if
end function

Board.setPiece = function(piece,colNr,rowNr)
	row = self.pieces[rowNr - 1]
	row[colNr - 1] = piece
	// Save position into piece
	piece.colNr = colNr
	piece.rowNr = rowNr
end function

Board.hasPiece = function(colNr,rowNr)
	pieceOrNull = self.getPiece(colNr,rowNr)
	return pieceOrNull != null
end function

Board.removePiece = function(colNr,rowNr)
	existingPiece = self.getPiece(colNr,rowNr)
	if existingPiece then existingPiece.remove
	row = self.pieces[rowNr - 1]
	row[colNr - 1] = null
end function

Board.movePiece = function(piece,col,row)
	m = new PieceMovement
	coords = self.positionCoordinates(col,row)
	m.init piece,coords.x,coords.y
	board = self
	doneFun = function
		board.setPiece piece,col,row
	end function
	m.onDone = doneFun
	m.move
end function

Board.positionCoordinates = function(col,row)
	relativeCoords = positionCenterCoordinates(col,row)
	bottomLeftCornerX = self.x - self.width / 2
	bottomLeftCornerY = self.y - self.height / 2
	absoluteCoords = {
	"x": relativeCoords.x + bottomLeftCornerX, 
	"y": relativeCoords.y + bottomLeftCornerY }
	return absoluteCoords
end function

Board.moveToFront = function
	idx = sprd.sprites.indexOf(self)
	sprd.sprites.remove(idx)
	sprd.sprites.push self
end function

// == PIECE

newYellowPiece = function
	p = newPiece(YellowPlayer)
	return p
end function

newRedPiece = function
	p = newPiece(RedPlayer)
	return p
end function

newPiece = function(player)
	p = new Piece
	p.init
	p.player = player
	p.tint = player.tint
	sprd.sprites.insert 0,p
	return p
end function

Piece = new Sprite
Piece.init = function
	self.image = generatePieceImage
	self.x = 100
	self.y = 100
	self.tint = color.white
	self.player = null
	// Will be set by Board
	self.colNr = null
	self.rowNr = null
end function

Piece.moveToDroppingArea = function(colNr)
	self.moveToBoardPosition colNr,rowCount
	self.y = self.y + droppingAreaOffset
end function

Piece.moveToBoardPosition = function(col,row)
	coords = Board.positionCoordinates(col,row)
	self.x = coords.x
	self.y = coords.y
end function

Piece.remove = function
	sprIdx = sprd.sprites.indexOf(self)
	sprd.sprites.remove sprIdx
end function

// == Players

Player = {}
Player.name = null
Player.tint = null

Player.init = function(name, tint)
	self.name = name
	self.tint = tint
end function

Player.newPiece = function
	p = newPiece(self)
	return p
end function

newPlayer = function(name, tint)
	p = new Player
	p.init name, tint
	return p
end function

RedPlayer = newPlayer("Red", color.red)
YellowPlayer = newPlayer("Yellow", color.yellow)

// == DROPPING AREA

DroppingArea = {}

DroppingArea.slots = null

DroppingArea.init = function
	self.slots = {}
	lastRow = rowCount
	for colNr in range(1,colCount)
		coords = Board.positionCoordinates(colNr,lastRow)
		
		rect = new Bounds
		rect.x = coords.x
		rect.y = coords.y + droppingAreaOffset
		rect.width = discSize + marginSize
		rect.height = discSize + marginSize
		
		self.slots[colNr] = rect
	end for
end function

DroppingArea.waitUntilDropped = function(piece)
	piece.moveToDroppingArea 1
	pieceColNr = 1
	targetPosition = {}
	while true
		// Move piece to slot where mouse is positioned
		for slot in self.slots
			slotColNr = slot.key
			slot = slot.value
			if slot.contains(mouse) then
				piece.moveToDroppingArea slotColNr
				pieceColNr = slotColNr
			end if			
		end for
		// When clicked, return target position if column not full
		if mouse.button and Board.hasFreeRowAtColumn(pieceColNr) then
			rowNr = Board.freeRowAtColumn(pieceColNr)
			targetPosition.colNr = pieceColNr
			targetPosition.rowNr = rowNr
			break
		end if
		yield
	end while
	
	// Wait until mouse is "up" again
	while mouse.button; yield; end while
	
	return targetPosition
end function

// == ANIMATION

PieceMovement = {}
PieceMovement.init = function(piece,endX,endY)
	self.animation = new Animation
	deltaX = abs(endX - piece.x)
	deltaY = abs(endY - piece.y)
	delta = max(deltaX, deltaY)
	duration = 0.05 * (delta / (discSize + marginSize))
	self.animation.init piece,endX,endY,duration
end function
PieceMovement.move = function
	while self.animation.isRunning
		self.animation.update
		yield
	end while
	self.onDone
end function
PieceMovement.onDone = function
	// REPLACE
end function

// == METRICS

boardTotalWidth = function
	return (discSize + marginSize) * colCount + marginSize
end function

boardTotalHeight = function
	return (discSize + marginSize) * rowCount + marginSize
end function

positionCoordinates = function(col,row)
	x = marginSize + (col - 1) * (discSize + marginSize)
	y = marginSize + (row - 1) * (discSize + marginSize)
	coords = {"x": x, "y": y}
	return coords
end function

positionCenterCoordinates = function(col,row)
	coords = positionCoordinates(col,row)
	coords.x = coords.x + discSize / 2
	coords.y = coords.y + discSize / 2
	return coords
end function

isValidPosition = function(colNr,rowNr)
	validColNr = colNr >= 1 and colNr <= colCount
	validRowNr = rowNr >= 1 and rowNr <= rowCount
	return validColNr and validRowNr
end function

// == DRAWING

generateBoardImg = function
	
	drawBoard = function(disp)
		drawSurface = function
			disp.fillRect 0,0,boardTotalWidth,boardTotalHeight,color.blue
		end function
		drawHoles = function
			for row in range(1,rowCount)
				for col in range(1,colCount)
					coords = positionCoordinates(col, row)
					x = coords.x
					y = coords.y
					disp.fillEllipse x,y,discSize,discSize,color.clear
				end for
			end for	
		end function
		drawSurface
		drawHoles
	end function
	
	disp = new PixelDisplay
	disp.clear color.clear
	drawBoard(disp)
	img = disp.getImage(0,0,boardTotalWidth,boardTotalHeight)
	return img
end function

generatePieceImage = function
	disp = new PixelDisplay
	disp.clear color.clear
	disp.fillEllipse 0,0,discSize,discSize,color.white
	img = disp.getImage(0,0,discSize,discSize)
	return img
end function

drawSolutionLine = function(solvingPieces)
	first = solvingPieces[0]
	last = solvingPieces[-1]
	gfx.line first.x,first.y,last.x,last.y,color.green,20
end function

resetDisplays = function
	gfx.clear color.clear
	text.clear
	text.row = 25
end function

// == HELPERS

max = function(a,b)
	if a > b then return a else return b
end function

// == DROP DEMO

dropDemo = function
	
	Board.init
	players = [RedPlayer, YellowPlayer]
	
	playerIdx = 0
	solved = false
	
	while not Board.isFull
		player = players[playerIdx]
		playerIdx = (playerIdx + 1) % 2
		
		colNr = 1 + floor(rnd * 7)
		
		rowNr = Board.freeRowAtColumn(colNr)
		if rowNr == null then continue
		
		piece = player.newPiece
		
		piece.moveToDroppingArea colNr
		
		wait 0.2		
		
		Board.movePiece piece,colNr,rowNr
		
		if Board.isSolvedByPiece(piece) then
			solvingPieces = Board.findSolvingPieces(piece)
			drawSolutionLine solvingPieces
			solved = true
			break
		end if
		
	end while
	
	if solved then
		print "Solved!"
	else
		print "Board full. Game over."
	end if
	
end function

// == MAIN INVOCATION

main
