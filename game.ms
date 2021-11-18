// Cell margin (negative overlap)
ov = 1
// Tile dimensions
tw = 20
th = 20
// Board dimensions in cells (cols, rows)
bcc = 40
brr = 20
// Board dimensions in pixels
bw = bcc*(tw+ov)
bh = brr*(th+ov)
// Origin coordinates
ox = 960/2-bw/2
oy = 640/2-bh/2

// Delay between iterations when animating ("playing")
animationFrameDelay = 0.5

gfx.clear
// Generate tileset image
gfx.fillRect 0,0,tw,th,color.gray
gfx.fillRect tw,0,tw,th,color.white
tileImgs = gfx.getImage(0,0,tw*2,th)

// Generate button images

buildButtonImage = function(label,width=90,height=40)
	gfx.clear
	gfx.fillRect 0,0,width,height,color.silver
	gfx.print label,10,5,color.black,"small"
	return gfx.getImage(0,0,width,height)
end function

resetImg=buildButtonImage("Clear",65,30)
nextImg=buildButtonImage("Step",55,30)
playImg=buildButtonImage("Play",55,30)
stopImg=buildButtonImage("Stop",55,30)
randomizeImg=buildButtonImage("Random",75,30)

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

createButtonSprite = function(img)
	buttonSprite = new Sprite
	buttonSprite.image = img
	buttonSprite.localBounds = new Bounds
	buttonSprite.localBounds.width = img.width
	buttonSprite.localBounds.height = img.height
	buttonSprite.appearEnabled = function()
		self.tint = color.white
	end function
	buttonSprite.appearDisabled = function()
		self.tint = color.gray
	end function
	return buttonSprite
end function

nextButton = createButtonSprite(nextImg)
resetButton = createButtonSprite(resetImg)
playButton = createButtonSprite(playImg)
randomizeButton = createButtonSprite(randomizeImg)

playButton.showPlay = function()
	self.image = playImg
end function

playButton.showStop = function()
	self.image = stopImg
end function

// Clear displays
gfx.clear color.clear
spr.clear
tdisp.clear
text.clear

// Place sprite buttons
buttonsToPlace = [nextButton, playButton, randomizeButton, resetButton]
for btnIdx in buttonsToPlace.indexes
	btn = buttonsToPlace[btnIdx]
	img = btn.image
	btn.x = ox+btn.image.width/2+btnIdx*150
	btn.y = oy-btn.image.height
	spr.sprites.push btn
end for

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
// Returns the amount of changed cells
setBoardValues = function(boardValues)
	changes = 0
	for row in range(0,brr-1)
		for col in range(0,bcc-1)
			currentValue = tdisp.cell(col,row)
			newValue = boardValues[row][col]
			if currentValue != newValue then changes = changes + 1
			tdisp.setCell(col,row,newValue)
		end for
	end for
	return changes
end function

// Resets the board to all empty cells
resetBoard = function()
	emptyBoard = [[0]*bcc]*brr
	setBoardValues(emptyBoard)
end function

// Fills board with random cells
randomizeBoard = function()
	for row in range(0,brr-1)
		for col in range(0,bcc-1)
			randomValue = rnd*3 < 1
			tdisp.setCell(col,row,randomValue)
		end for
	end for	
end function

// Performs one iteration
// Returns true if something changed from the previous iteration
iterate = function()
	nextBoard = calculateNextIteration
	changedCellsCount = setBoardValues(nextBoard)
	return changedCellsCount > 0
end function

// == MAIN PROGRAM ==

resetBoard

wasDown = false
isDown = false
playing = false
nextIterationTime = 0

startPlaying = function()
	globals.playing = true
	for btn in [resetButton, randomizeButton, nextButton]
		btn.appearDisabled
	end for
	playButton.showStop
end function

stopPlaying = function()
	globals.playing = false
	for btn in [resetButton, randomizeButton, nextButton]
		btn.appearEnabled
	end for
	playButton.showPlay
end function

togglePlaying = function()
	if playing then
		stopPlaying
	else
		startPlaying
	end if
end function

while true
	isDown = mouse.button
	if isDown and not wasDown then
		if nextButton.contains(mouse) then
			if not playing then iterate
		else if resetButton.contains(mouse) then
			if not playing then resetBoard
		else if randomizeButton.contains(mouse) then
			if not playing then randomizeBoard
		else if playButton.contains(mouse) then
			togglePlaying
		else
			col = floor((mouse.x-ox) / (tw+ov))
			row = floor((mouse.y-oy) / (th+ov))		
			toggleCell(col,row)
		end if
	end if
	wasDown = isDown
	
	if playing and time > nextIterationTime then
		hadChanges = iterate
		// Schedule next iteration some time in the future
		nextIterationTime = time + animationFrameDelay
		// Stop playing if nothing changes anymore
		if not hadChanges then 
			stopPlaying
		end if
	end if
	
	if key.available then
		k = key.get
		if k == "q" then exit
		if k == "r" and not playing then resetBoard
		if k == "n" and not playing then iterate
		if k == "p" then togglePlaying
	end if
end while