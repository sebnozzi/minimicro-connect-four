newAlternatingSequence = function(elements)
	seq = new AlternatingSequence
	seq.init elements
	return seq
end function

AlternatingSequence = {}

AlternatingSequence.init = function(elements)
	self.idx = 0
	self.elements = elements
end function

AlternatingSequence.next = function
	element = self.peek
	self.advance
	return element
end function

AlternatingSequence.peek = function
	return self.elements[self.idx]
end function

AlternatingSequence.advance = function
	self.idx = (self.idx + 1) % self.elements.len
end function

// == DEMO
if globals == locals then
	clear
	seq = newAlternatingSequence(["Tic","Tac","Toe","-"])
	for i in range(1,25)
		print seq.next
		wait 0.1
	end for 
end if