-- @namespace MapMaker
-- @class SettingsDialog: Create a dialog window for setting grid height/width
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
	local textbox_height
	local textbox_width

	-- Read settings file, create one if it doesn't exist
	function this.Read()
		-- Create initial settings file with defaults
		if not love.filesystem.exists('MapMaker.settings') then
			this.Write(8, 8)
			this.Read()
		-- Read settings file
		else
			local height, width
			for line in love.filesystem.lines('MapMaker.settings') do
				if line:match('height:%d+') then
					this.gridH = tonumber(line:match('%d+'))
				elseif line:match('width:%d+') then
					this.gridW = tonumber(line:match('%d+'))
				end
			end
		end
		return this.gridH, this.gridW
	end

	-- Write to settings file
	function this.Write(h, w)
		local settingsString = string.format('height:%d\nwidth:%d', h, w)
		local settings, errorstr = love.filesystem.newFile('MapMaker.settings')
		settings:open('w')
		settings:write(settingsString)
		settings:close()
	end


	-- Get height, width from settings file for dialog positioning
	local valueY, valueX = this.Read()
	this.y, this.x = this.Read()
	this.y = (((this.y / 2) * 30) - (this.height / 2))
	this.x = (((this.x / 2) * 30) - (this.width / 2))

	-- Initialize text boxes and confirm button
	local textbox_height = text.newTextBox(valueY, this.x + 5, this.y + 20, 67)
	local textbox_width = text.newTextBox(valueX, this.x + this.width - 72, this.y + 20, 67)
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
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.rectangle('fill', this.x, this.y, this.width, this.height)
		love.graphics.setColor(200, 200, 200, 255)
		love.graphics.rectangle('fill', this.x+1, this.y+1, this.width-2, this.height-2)
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.print('Height', this.x + 15, this.y + 1)
		love.graphics.print('Width', this.x + 89, this.y + 1)

		-- Show text boxes and button
		textbox_height.Show(); textbox_width.Show(); confirmButton.Show()
	end



	-- Select text boxes with tabs
	function this.TabSelect()
		if textbox_height.selected then
			textbox_height.selected = false
			textbox_width.selected = true
		else
			textbox_height.selected = true
			textbox_width.selected = false
		end
	end

	-- Handle mouse press
	function this.mousepressed(x, y, button)
		textbox_height.mousepressed(x, y, button)
		textbox_width.mousepressed(x, y, button)
		confirmButton.mousepressed(x, y, button)
	end

	-- Handle mouse release
	function this.mousereleased(x, y, button)
		confirmButton.mousereleased(x, y, button)
		if confirmButton.clicked then
			if tonumber(textbox_height.value) >= 8 and tonumber(textbox_height.value) <= 25
			and tonumber(textbox_width.value) >= 8 and tonumber(textbox_width.value) <= 25 then
				this.settingsChosen = true
				confirmButton.clicked = false
				this.Write(textbox_height.value, textbox_width.value)

				-- Force reload of all components. Will set grid/window dimensions
				-- and allow all UI elements to have their position/dimension values
				-- recalculated appropriately
				love.load()
			else
				confirmButton.clicked = false
				local buttons = {'OK'}
				local alert = love.window.showMessageBox(
					'Alert',
					'Grid height and width must be between 8 and 25.',
					buttons
				)
			end
		end
	end

	-- Handle text input
	function this.textinput(text)
		if textbox_height.selected then
			textbox_height.textinput(text)
		elseif textbox_width.selected then
			textbox_width.textinput(text)
		end
	end

	-- Handle key press
	function this.keypressed(key)
		if key == 'tab' then
			this.TabSelect()
		elseif key == 'return' then
			-- Simulate confirm button click
			this.mousereleased(confirmButton.x + 1, confirmButton.y + 1, 'l')
		elseif key == 'escape' then
			this.settingsChosen = true
		end
		
		if textbox_height.selected then
			textbox_height.keypressed(key)
		elseif textbox_width.selected then
			textbox_width.keypressed(key)
		end
	end

	return this
end

return MapMaker