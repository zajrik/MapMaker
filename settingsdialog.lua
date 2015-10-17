-- @namespace MapMaker
-- @class SettingsDialog: Create a dialog window for setting grid height/width
local MapMaker = {}; function MapMaker.newSettingsDialog()
	
	-- Constructor
	local this = 
	{
		width = 150,
		height = 76,
		x = 0,
		y = 0,
		settingsChosen,
		currentH,
		currentW
	}

	local text   = require 'textbox'
	local button = require 'button'
	local event  = require 'clickhandler'

	local textbox_height
	local textbox_width
	local button_confirm

	local clickHandler_confirm

	-- Read settings file, create one if it doesn't exist
	function this.Read()
		-- Create initial settings file with defaults
		if not love.filesystem.exists('MapMakerSettings.lua') then
			this.Write(8, 8)
			this.Read()
		-- Read settings file
		else
			local settingsLoader = love.filesystem.load('MapMakerSettings.lua')
			local settings = (settingsLoader)()
			return settings.height, settings.width
		end
		
	end

	-- Write to settings file
	function this.Write(h, w)
		local settingsString = string.format(
			'return \n{\n\theight = %d,\n\twidth = %d\n}', h, w)
		local settingsFile, errorstr = love.filesystem.newFile('MapMakerSettings.lua')
		settingsFile:open('w')
		settingsFile:write(settingsString)
		settingsFile:close()
	end


	-- Get height, width from settings file for dialog positioning
	local valueY, valueX = this.Read()
	this.y, this.x = this.Read()
	this.y = (((this.y / 2) * 30) - (this.height / 2))
	this.x = (((this.x / 2) * 30) - (this.width / 2))

	-- Initialize text boxes, confirm button, confirm button click handler
	textbox_height = text.newTextBox(valueY, this.x + 5, this.y + 20, 67)
	textbox_width  = text.newTextBox(valueX, this.x + this.width - 72, this.y + 20, 67)
	button_confirm = button.newButton(
		'OK', this.x + 10, this.y + this.height - 30, this.width - 20)

	clickHandler_confirm = 
		event.newClickHandler((
			function()
				-- Enforce non-empty values
				if textbox_height.value == '' or
					textbox_width.value == '' then
						local alert = love.window.showMessageBox(
							'Alert',
							'You must set a value.'
						)
						return
				end

				-- Enforce min/max values
				if  tonumber(textbox_height.value) >= 8 
				and tonumber(textbox_height.value) <= 25
				and tonumber(textbox_width.value)  >= 8 
				and tonumber(textbox_width.value)  <= 25 then
					this.settingsChosen = true
					this.Write(textbox_height.value, textbox_width.value)

					-- Don't clear the grid if values weren't changed
					if textbox_height.value == this.currentH 
						and textbox_width.value == this.currentW then

					else love.load() end
				else
					local alert = love.window.showMessageBox(
						'Alert',
						'Grid height and width must be between 8 and 25.'
					)
				end
			end
		))

	-- Update timer
	function this.update(dt)
		textbox_height.update(dt)
		textbox_width.update(dt)
	end

	-- Handle display of the dialog
	function this.Show()
		-- Get actual window height, width for UI darkening overlay
		local winH = love.window.getHeight()
		local winW = love.window.getWidth()

		-- UI darken overlay
		love.graphics.setColor(0, 0, 0, 200)
		love.graphics.rectangle('fill', 0, 0, winW, winH)

		-- Draw diaglog box
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.rectangle('fill', this.x, this.y, this.width, this.height)
		love.graphics.setColor(200, 200, 200, 255)
		love.graphics.rectangle(
			'fill', this.x + 1, this.y + 1, this.width - 2, this.height - 2)
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.print('Height', this.x + 15, this.y + 1)
		love.graphics.print('Width', this.x + 89, this.y + 1)

		-- Show text boxes and button
		textbox_height.Show(); textbox_width.Show(); button_confirm.Show()
	end



	-- Select text boxes with tab key
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
		button_confirm.mousepressed(x, y, button)
	end

	-- Handle mouse release
	function this.mousereleased(x, y, button)
		button_confirm.mousereleased(x, y, button, clickHandler_confirm)
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
			this.mousereleased(button_confirm.x + 1, button_confirm.y + 1, 'l')
		elseif key == 'escape' then
			this.settingsChosen = true
			textbox_height.value = textbox_height.oldValue
			textbox_width.value = textbox_width.oldValue
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