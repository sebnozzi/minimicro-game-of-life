// Cell margin (negative overlap)
ov = 1
// Tile dimensions
tw = 20
th = 20
// Board dimensions in cells (cols, rows)
bcc = 10
brr = 10
// Board dimensions in pixels
bw = bcc*(tw+ov)
bh = brr*(th+ov)
// Origin coordinates
ox = 960/2-bw/2
oy = 640/2-bh/2

gfx.clear
// Generate tileset image
gfx.fillRect 0,0,tw,th,color.gray
gfx.fillRect tw,0,tw,th,color.white
tileImgs = gfx.getImage(0,0,tw*2,th)

// Generate button images
gfx.clear
gfx.fillRect 0,0,90,40,color.silver
gfx.print "Reset",10,10,color.black
resetImg = gfx.getImage(0,0,90,40)
gfx.clear
gfx.fillRect 0,0,80,40,color.silver
gfx.print "Next",10,10,color.black
nextImg = gfx.getImage(0,0,80,40)

// Setup displays
display(6).mode = displayMode.tile
tdisp = display(6)
tdisp.extent = [bcc,brr]
tdisp.tileSet = tileImgs
tdisp.tileSetTileSize = tw
tdisp.cellSize = th
tdisp.scrollX = -ox
tdisp.scrollY = -oy
tdisp.overlap = -ov

spr = display(4)

// Create button sprites
nextButton = new Sprite
nextButton.image = nextImg
nextButton.localBounds = new Bounds
nextButton.localBounds.width = nextImg.width
nextButton.localBounds.height = nextImg.height
nextButton.x = ox+nextImg.width/2+bw-nextImg.width
nextButton.y = oy+nextImg.height/2-nextImg.height-10

resetButton = new Sprite
resetButton.image = resetImg
resetButton.localBounds = new Bounds
resetButton.localBounds.width = resetImg.width
resetButton.localBounds.height = resetImg.height
resetButton.x = ox+resetImg.width/2
resetButton.y = oy+resetImg.height/2-resetImg.height-10

// Clear displays
gfx.clear color.clear
spr.clear
tdisp.clear
text.clear

// Place sprites

spr.sprites.push nextButton
spr.sprites.push resetButton

// Draw boundary box
// gfx.drawRect ox,oy,bw,bh,color.red

toggleCell = function(col,row)
	if col < 0 or col >= bcc then return
	if row < 0 or row >= brr then return
	
	cell = tdisp.cell(col,row)
	if cell == 1 then
		tdisp.setCell(col,row,0)
	else
		tdisp.setCell(col,row,1)
	end if
end function

// Counts live neighbours of cell
countLiveNeighbours = function(col,row)
	count = 0
	offsets = [[-1,1],[0,1],[1,1],[-1,0],[1,0],[-1,-1],[0,-1],[1,-1]]
	for offset in offsets
		ncol = col+offset[0]
		nrow = row+offset[1]
		idx = tdisp.cell(ncol,nrow)
		if idx == 1 then count = count + 1
	end for
	return count
end function

makeEmptyBoard = function()
	rows = []
	for row in range(0,brr-1)
		emptyRow = [0]*bcc
		rows.push emptyRow
	end for
	return rows
end function

// Calculates values of next iteration
calculateNextIteration = function()
	nextBoard = makeEmptyBoard
	for row in range(0,brr-1)
		for col in range(0,bcc-1)
			nbb = countLiveNeighbours(col,row)
			idx = tdisp.cell(col,row)
			if idx == 1 then 
				// Cell is alive - lives on if neighbours == 2 or 3
				if nbb == 2 or nbb == 3 then 
					nextBoard[row][col] = 1
				end if
			else
				// Cell is dead - originates new cell if neighbours == 3
				if nbb == 3 then 
					nextBoard[row][col] = 1				
				end if
			end if
		end for
	end for
	return nextBoard
end function

// Sets the board to the given multi-dimensional values
setBoardValues = function(boardValues)
	for row in range(0,brr-1)
		for col in range(0,bcc-1)
			newValue = boardValues[row][col]
			tdisp.setCell(col,row,newValue)
		end for
	end for
end function

// Resets the board to all empty cells
resetBoard = function()
	emptyBoard = [[0]*bcc]*brr
	setBoardValues(emptyBoard)
end function

// Performs one iteration
iterate = function()
	nextBoard = calculateNextIteration
	setBoardValues(nextBoard)
end function

// == MAIN PROGRAM ==

resetBoard

wasDown = false
isDown = false

while true
	isDown = mouse.button
	if isDown and not wasDown then
		if nextButton.contains(mouse) then
			iterate
		else if resetButton.contains(mouse) then
			resetBoard
		else
			col = floor((mouse.x-ox) / (tw+ov))
			row = floor((mouse.y-oy) / (th+ov))		
			toggleCell(col,row)
		end if
	end if
	wasDown = isDown
end while