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

	local _text    = require 'textbox'
	local _button  = require 'button'
	local _event   = require 'clickhandler'
	local _tooltip = require 'tooltip'

	local textbox_height
	local textbox_width
	local button_confirm

	local tooltip_confirm

	local clickHandler_confirm

	-- Read settings file, create one if it doesn't exist
	function this.Read()
		-- Create initial settings file with defaults
		if not love.filesystem.exists('MapMakerSettings.lua') then
			this.Write(8, 8)
			return 8, 8

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
		local settingsFile, _ = love.filesystem.newFile('MapMakerSettings.lua')
		settingsFile:open('w')
		settingsFile:write(settingsString)
		settingsFile:close()
	end


	-- Get height, width from settings file for dialog positioning
	local valueY, valueX = this.Read()
	this.y, this.x = this.Read()
	this.y = math.floor(((this.y / 2) * 30) - (this.height / 2))
	this.x = math.floor(((this.x / 2) * 30) - (this.width / 2))

	-- Initialize dialog components
	textbox_height = _text.newTextBox(valueY, this.x + 5, this.y + 20, 67)
	textbox_width  = _text.newTextBox(
		valueX, this.x + this.width - 72, this.y + 20, 67)

	button_confirm = _button.newButton(
		'OK', this.x + 10, this.y + this.height - 30, this.width - 20)

	tooltip_confirm = _tooltip.newTooltip(button_confirm)

	clickHandler_confirm =
		_event.newClickHandler((
			function()
				this.settingsChosen = true
				this.Write(textbox_height.value, textbox_width.value)

				-- Don't clear the grid if values weren't changed
				if tonumber(textbox_height.value) == this.currentH
					and tonumber(textbox_width.value) == this.currentW then

				else love.load() end
			end
		))

	-- Add textboxes to textbox table
	local textboxes =
	{
		textbox_height,
		textbox_width
	}

	-- Check the textbox values in real time
	local function LiveChecker()
		-- Enforce non-empty values
		button_confirm.enabled =
			not (textbox_height.value == '' or textbox_width.value == '')
		tooltip_confirm.SetText((not button_confirm.enabled) and
			'Grid height and width must not be empty.' or nil)
		if not button_confirm.enabled then return end

		-- Enforce min/max values
		button_confirm.enabled = (tonumber(textbox_height.value) >= 8
			and tonumber(textbox_height.value) <= 25
			and tonumber(textbox_width.value) >= 8
			and tonumber(textbox_width.value) <= 25)
		tooltip_confirm.SetText((not button_confirm.enabled) and
			'Grid height and width must be between 8 and 25.' or nil)
	end

	-- Update timer
	function this.update(dt)
		for i = 1, #textboxes do textboxes[i].update(dt) end
		tooltip_confirm.update(dt)
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
		love.graphics.print('Height', this.x + 15, this.y + 3)
		love.graphics.print('Width', this.x + 89, this.y + 3)

		-- Show text boxes and button
		for i = 1, #textboxes do textboxes[i].Show() end
		button_confirm.Show()

		tooltip_confirm.Add()
		LiveChecker()
	end



	-- Select text boxes with tab key
	function this.TabSelect()
		local select = 0
		for i = 1, #textboxes do
			if textboxes[i].selected then
				select = i; break
			end
		end
		if select == 0 then textboxes[1].selected = true
		else
			select = select + 1
			if select > #textboxes then select = 1 end
			for i = 1, #textboxes do
				textboxes[i].selected = false
			end
			textboxes[select].selected = true
		end
	end

	-- Handle mouse press
	function this.mousepressed(x, y, button)
		for i = 1, #textboxes do textboxes[i].mousepressed(x, y, button) end
		button_confirm.mousepressed(x, y, button)
	end

	-- Handle mouse release
	function this.mousereleased(x, y, button)
		button_confirm.mousereleased(x, y, button, clickHandler_confirm)
	end

	-- Handle text input
	function this.textinput(text)
		for i = 1, #textboxes do
			if textboxes[i].selected then
				textboxes[i].textinput(text); break end
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
			for i = 1, #textboxes do
				textboxes[i].value = textboxes[i].oldValue end
		end

		for i = 1, #textboxes do
			if textboxes[i].selected then
				textboxes[i].keypressed(key); break end
		end
	end

	return this
end

return MapMaker
