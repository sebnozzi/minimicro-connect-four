// Minimax Algorithm with Alpha-Beta Pruning
// Reference:
//  https://en.wikipedia.org/wiki/Alpha%E2%80%93beta_pruning

infinity = 1E12

max = function(a,b)
	if b > a then return b else return a
end function

min = function(a,b)
	if b < a then return b else return a
end function

// Node class: represents a state of the game, and provides
// methods to find "child" states (next states that could be
// reached by a single move), and a heuristic value which
// is > 0 for one player and < 0 for the other player.  This
// heuristic could be 0 everywhere except when the game is
// over (when it is + or -infinity), but for deep games it
// will work better if you can provide some sort of mid-game
// score.
Node = {}

// which player is up next: 1 for maximizing player, 0 for minimizing player
Node.player = 0  

// get child states of this node (i.e., states that represent
// the game after all possible moves of self.player)
Node.children = function
	return []  // override me!
end function

// get the heuristic value of this game state (< 0 if player 0
// is winning, > 0 if player 1 is winning)
Node.heuristicValue = function
	return 0   // override me!
end function

// also, return whether the game is over
Node.isGameOver = function
	print "Please override Node.isGameOver"
	exit
end function

alphaBeta = function(node, depth, alpha, beta, maximizingPlayer)
	if depth == 0 or node.isGameOver then
		return node.heuristicValue  // depth cutoff, or game-over
	end if
	if maximizingPlayer then
		value = -infinity
		for child in node.children
			value = max(value, alphaBeta(child, depth-1, alpha, beta, false))
			if value > beta then break  // beta cutoff
			alpha = max(alpha, value)
		end for
	else
		value = infinity
		for child in node.children
			value = min(value, alphaBeta(child, depth-1, alpha, beta, true))
			if value < alpha then break  // alpha cutoff
			beta = min(beta, value)
		end for
	end if
	return value	
end function

matchesDemo = function
	// Let's test/demo the code with the matchstick game:
	// starting with 21 matches, players take turn taking away
	// 1, 2, or 3 matches; whoever takes the last one loses.
	// (There are much simpler ways of making a perfect AI
	// for this game, but the point is to test alphaBeta.)
	MatchesNode = new Node
	MatchesNode.matchesLeft = 21
	MatchesNode.isGameOver = function
		return self.matchesLeft < 1
	end function
	MatchesNode.makeChild = function(qtyToTake)
		child = new MatchesNode
		child.player = not self.player
		child.matchesLeft = self.matchesLeft - qtyToTake
		return child
	end function
	MatchesNode.children = function
		// Possible states result from taking 1, 2, or 3
		// matches (but never more than we have).
		result = []
		if self.matchesLeft >= 1 then result.push self.makeChild(1)
		if self.matchesLeft >= 2 then result.push self.makeChild(2)
		if self.matchesLeft >= 3 then result.push self.makeChild(3)
		return result
	end function
	MatchesNode.heuristicValue = function
		// For this test, we will only score actual win/loss.
		if self.matchesLeft > 0 then return 0
		// And we'll assume that if the game is over (no matches
		// left) when it's player 0's turn, then they won,
		// and conversely for player 1.
		if self.player == 0 then return -infinity else return infinity
	end function
	
	// Let's play a game!  P0 = Human, P1 = AlphaBeta
	curState = new MatchesNode
	while not curState.isGameOver
		print "Matches left: " + curState.matchesLeft
		if curState.player == 0 then
			qty = input("How many do you take? ").val
			curState = curState.makeChild(qty)
		else
			// We have to consider each possible move the
			// AI could make.  That's a little redundant
			// with the code in .children, but it keeps
			// the plumbing clean.
			bestMove = null; bestScore = null
			for qty in range(1,3)
				if qty > curState.matchesLeft then continue
				imagine = curState.makeChild(qty)
				score = alphaBeta(imagine, 5, -infinity, infinity, 0)
				print "...if I take " + qty + ", my worst result is " + score
				if bestScore == null or score > bestScore then
					print "    That's the best so far!"
					bestScore = score
					bestMove = qty
				end if
			end for
			print "So, I take " + bestMove
			curState = curState.makeChild(bestMove)			
		end if
	end while
	print "Game over!"
	if curState.heuristicValue > 0 then print "I win!" else print "You win."
end function

if locals == globals then matchesDemo
