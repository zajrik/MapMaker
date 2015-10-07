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
		x = 0,
		y = 0,
		settingsChosen,
		gridH,
		gridW
	}

	local text = require 'textbox'
	local btn = require 'button'

	local x, y
	local heightBox
	local widthBox

	-- Read settings file, create one if it doesn't exist
	function this.Read()
		-- Create initial settings file with defaults
		if not love.filesystem.exists('MapMaker.settings') then
			this.Write(8, 8)

		-- Read settings file
		else
			local settings = io.open('MapMaker.settings', 'r')
			local height, width
			for line in settings:lines() do
				if line:match('height:%d+') then
					this.gridH = tonumber(line:match('%d+'))
					--print(this.gridH)
					--print(height)
				elseif line:match('width:%d+') then
					this.gridW = tonumber(line:match('%d+'))
					--print(this.gridW)
				end
			end
			settings:close()
		end
		return this.gridH, this.gridW
	end

	-- Write to settings file
	function this.Write(h, w)
		local settingsFile = io.open('MapMaker.settings', 'w')
		local settingsString = string.format('height:%d\nwidth:%d', h, w)
		settingsFile:write(settingsString)
		settingsFile:close()
	end


	-- Get height, width from settings file for dialog positioning
	local valueY, valueX = this.Read()
	this.y, this.x = this.Read()
	this.y = (((this.y / 2) * 30) - (this.height / 2))
	this.x = (((this.x / 2) * 30) - (this.width / 2))

	-- Initialize text boxes and confirm button
	local heightBox = text.newTextBox(valueY, this.x + 5, this.y + 20, 67)
	local widthBox = text.newTextBox(valueX, this.x + this.width - 72, this.y + 20, 67)
	local confirmButton = btn.newButton(
		'OK', this.x + 10, this.y + this.height - 30, this.width - 20)

	-- Handle display of the dialog
	function this.Show()
		-- Get actual window height, width for UI darkening overlay
		this.winH = love.window.getHeight()
		this.winW = love.window.getWidth()

		-- UI darken overlay
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

		-- Show text boxes and button
		heightBox.Show(); widthBox.Show(); confirmButton.Show()
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
			this.Write(heightBox.value, widthBox.value)

			-- Force reload of all components. Will set grid/window dimensions
			-- and allow all UI elements to have their position/dimension values
			-- recalculated appropriately
			love.load()
		end
	end

	-- Handle text input
	function this.textinput(text)
		if heightBox.selected then
			heightBox.textinput(text)
		elseif widthBox.selected then
			widthBox.textinput(text)
		end
	end

	-- Handle key press
	function this.keypressed(key)
		if heightBox.selected then
			heightBox.keypressed(key)
		elseif widthBox.selected then
			widthBox.keypressed(key)
		end
	end

	return this
end

return MapMaker