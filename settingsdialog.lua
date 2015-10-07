-- @namespace MapMaker
-- @class DimensionDialog: Class description
--font = love.graphics.newFont("SourceCodePro-Regular.ttf", 14)
local MapMaker = {}; function MapMaker.newSettingsDialog()
	
	-- Constructor
	local this = 
	{
		width = 150,
		height = 76,
		winH = 0,
		winW = 0,
		dimH = 8,
		dimW = 8,
		x = 0,
		y = 0,
		settingsChosen
	}

	local text = require 'textbox'
	local btn = require 'button'

	local x, y
	local heightBox
	local widthBox

		this.winH = love.window.getHeight()
		this.winW = love.window.getWidth()
		--print(this.winH)
		this.x = ((this.winW / 2) - (150/2))
		this.y = ((this.winH / 2) - 45)

	local heightBox = text.newTextBox(this.x + 5, this.y + 20, 67)
	local widthBox = text.newTextBox(this.x + this.width - 72, this.y + 20, 67)
	local confirmButton = btn.newButton(
		'Submit', this.x + 10, this.y + this.height - 30, this.width - 20)

	this.dimH = heightBox.value
	this.dimW = widthBox.value

	-- Handle display of the dialog
	function this.Show()
		-- Darken bg
		love.graphics.setColor(0, 0, 0, 200)
		love.graphics.rectangle('fill', 0, 0, this.winW, this.winH)

		-- Draw diaglog box
		love.graphics.setColor(200, 200, 200, 255)
		love.graphics.rectangle('fill', this.x, this.y, this.width, this.height)
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.rectangle('line', this.x, this.y, this.width, this.height)
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.print('Height', this.x + 15, this.y + 1)
		love.graphics.print('Width', this.x + 89, this.y + 1)
		heightBox.Show(); widthBox.Show(); confirmButton.Show()
	end

	-- Read settings file
	function this.Read()

	end

	-- Write to settings file
	function this.Write()

	end

	-- Handle mouse press
	function this.mousepressed(x, y, button)
		heightBox.mousepressed(x, y, button)
		widthBox.mousepressed(x, y, button)
		confirmButton.mousepressed(x, y, button)
	end

	-- Handle mouse release
	function this.mousereleased(x, y, button)
		confirmButton.mousereleased(x, y, button)
		if confirmButton.clicked then
			this.settingsChosen = true
			confirmButton.clicked = false
		end
	end

	return this
end

-- Make a coord fit a cell
function toCell(number)
	local blockSize = 30
	return number * blockSize
end

return MapMaker