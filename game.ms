// Cell margin (negative overlap)
ov = 1
// Tile dimensions
tw = 20
th = 20
// Board dimensions in cells (cols, rows)
bcc = 20
brr = 20
// Board dimensions in pixels
bw = bcc*(tw+ov)
bh = brr*(th+ov)
// Origin coordinates
ox = 960/2-bw/2
oy = 640/2-bh/2

gfx.clear
// Generate tileset image
gfx.fillRect 0,0,tw,th,color.white
gfx.fillRect tw,0,tw,th,color.gray
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
	cell = tdisp.cell(col,row)
	if cell == 0 then
		tdisp.setCell(col,row,1)
	else
		tdisp.setCell(col,row,0)
	end if
end function

// Initialize all cells to the unset tile
for row in range(0,brr)
	for col in range(0,bcc)
		tdisp.setCell(col,row,1)
	end for
end for

wasDown = false
isDown = false

while true
	isDown = mouse.button
	if isDown and not wasDown then
		col = floor((mouse.x-ox) / (tw+ov))
		row = floor((mouse.y-oy) / (th+ov))
		toggleCell(col,row)
	end if
	wasDown = isDown
end while