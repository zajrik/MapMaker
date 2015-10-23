io.stdout:setvbuf('no')
love.window.setTitle('Map Maker')

font_regular = love.graphics.newFont(14)
font_small   = love.graphics.newFont(10)

icon = love.graphics.newImage('icon.png')
iconData = icon:getData()

love.window.setIcon(iconData)
love.graphics.setFont(font_regular)

local settingsDialog = require 'settingsdialog'
local button         = require 'button'
local event          = require 'clickhandler'

local mapChecker  = require 'mapchecker'
local mapExporter = require 'mapexporter'

local winX, winY, display

local h, w
local cellSize = 30

local canvas_grid
local canvas_activeCells

local button_export
local button_clear
local button_settings

local clickHandler_export
local clickHandler_clear
local clickHandler_settings

local settings
local settingsSet

local startY, startX, startSet
local finishY, finishX, finishSet

local clickY, clickX
local rclickY, rclickX

local exportClick

local map

function love.load()
	settingsSet = true

	startY = 0
	startX = 0
	startSet = false

	finishY = 0
	finishX = 0
	finishSet = false

	clickY = 0
	clickX = 0

	rclickY = 0
	rclickX = 0

	exportClick = false

	settings = settingsDialog.newSettingsDialog()

	-- Get height, width from settings file
	h, w = settings.Read()

	settings.currentH, settings.currentW = h, w

	-- Preserve window position
	winX, winY, display = love.window.getPosition()

	-- Set window size for the grid and bottom buttons
	love.window.setMode(w * cellSize, (h * cellSize) + 52,
		{display = display, x = winX, y = winY})

	-- Bottom buttons
	button_export = button.newButton(
		'Export', 0, ToCell(h) + 1, ToCell(w) / 2, {enabled = false})
	button_clear = button.newButton(
		'Clear', (ToCell(w) / 2) + 1, ToCell(h) + 1, (ToCell(w) / 2) - 1)
	button_settings = button.newButton(
		'Settings', 0, ToCell(h) + 27, ToCell(w))

	-- Button click handlers
	clickHandler_export = 
		event.newClickHandler((
			function()
				local exporter = mapExporter.newMapExporter()
				exporter.ExportMap(
					map, h, w, startY, startX, startSet, finishSet)
			end
		))
	clickHandler_clear = 
		event.newClickHandler((
			function()
				love.load()
			end
		))
	clickHandler_settings = 
		event.newClickHandler((
			function()
				settings.settingsChosen = false
				settingsSet = false
				settings.TabSelect()
			end
		))

	-- Build empty map
	map = {}
	for y = 1, h do
		map[y] = {}
		for x = 1, w do
			map[y][x] = '.'
		end
	end

	-- Prepare background grid canvas and draw background grid to it
	canvas_grid = love.graphics.newCanvas(ToCell(w), ToCell(h))
	canvas_grid:renderTo(function()
		local nextX, nextY = 0, 0
		for y = 1, h do
			for x = 1, w do
				if y % 2 ~= 0 then
					if x % 2 == 0 then love.graphics.setColor(230, 230, 230, 255)
					else love.graphics.setColor(255, 255, 255, 255) end
				else
					if x % 2 ~= 0 then love.graphics.setColor(230, 230, 230, 255)
					else love.graphics.setColor(255, 255, 255, 255) end
				end
				love.graphics.rectangle('fill', nextX , nextY, cellSize, cellSize)
				nextX = nextX + cellSize
			end
			nextX, nextY = 0, (nextY + cellSize)
		end
	end)

	-- Prepare the canvas for active direction marker cells
	canvas_activeCells = love.graphics.newCanvas(ToCell(w), ToCell(h))
end


-- Draw all the things, constantly, forever
function love.draw()

	-- Draw background grid canvas
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(canvas_grid, 0, 0)

	-- Draw active direction cells canvas
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(canvas_activeCells, 0, 0)

	-- Draw bottom buttons
	button_export.Show()
	button_settings.Show()
	button_clear.Show()

	-- Layer settings dialog on top, centered vertically/horizontally
	if settings.settingsChosen then
		settingsSet = true
	end
	if not settingsSet then
		settings.Show()
	end

	-- Print coords on screen in small font
	love.graphics.setFont(font_small)
	local mouseX, mouseY = love.mouse.getPosition()
	if ToMapCoord(mouseX) > w then mouseX = w
	else mouseX = ToMapCoord(mouseX) end
	if ToMapCoord(mouseY) > h then mouseY = h
	else mouseY = ToMapCoord(mouseY) end
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print(mouseY..','..mouseX, 2, ToCell(h) - 14)
	love.graphics.setFont(font_regular)

end

-- Make number fit a map coord (1-index)
function ToMapCoord(number)
	return math.floor((number / cellSize) + 1)
end

-- Make number fit a grid coord (0-index)
function ToGridCoord(number)
	return math.floor((number / cellSize))
end

-- Make a coord fit a cell
function ToCell(number)
	return number * cellSize
end

-- Check if direction cell overwrites finish cell, overwrite it if so
-- Requires numbers to be map coordinates
function CheckCell(y, x)
	if y == finishY and x == finishX then
		finishSet = false; finishY = 0; finishX = 0 end
end

-- Center a character within a grid cell, set its background color
-- Takes in map coords but they need to be grid coords, so subtract 1
function CellText(text, y, x)
	if startX == x and startY == y and startSet then 
		love.graphics.setColor(0, 255, 0, 255)
	else
		love.graphics.setColor(223, 229, 123, 255)
	end
	love.graphics.rectangle(
		'fill', ToCell(x - 1), ToCell(y - 1), cellSize, cellSize)
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print(text, ToCell(x - 1) + 10, ToCell(y - 1) + 5)
end

-- Update the activeCells canvas
function UpdateCells()

	canvas_activeCells:renderTo(function()
		canvas_activeCells:clear()
		-- Draw chosen start coord cell
		if startSet then
			love.graphics.setColor(0, 255, 0, 255)
			love.graphics.rectangle('fill', 
				ToCell(ToGridCoord(clickX)),
				ToCell(ToGridCoord(clickY)),
				cellSize, cellSize)
		end

		-- Draw movement marker cells
		for y = 1, #map do
			for x = 1, #map[y] do
				if     map[y][x] == '^' then CellText('^', y, x)
				elseif map[y][x] == '>' then CellText('>', y, x)
				elseif map[y][x] == 'v' then CellText('v', y, x)
				elseif map[y][x] == '<' then CellText('<', y, x)
				elseif map[y][x] == '*' then CellText('*', y, x)
				end
			end
		end
	end)

end

-- Update timer
function love.update(dt)
	settings.update(dt)
end

-- Mouse pressed event listener
function love.mousepressed(x, y, button)
	-- Left click
	if button == 'l' then
		-- Pass mouse presses to settings dialog
		settings.mousepressed(x, y, button)
		if settingsSet then
			-- Send out valid mouse events to component objects
			button_export.mousepressed(x, y, button)
			button_settings.mousepressed(x, y, button)
			button_clear.mousepressed(x, y, button)

			-- Clicked out of bounds
			if x > w * cellSize
				or y > h * cellSize then

			-- Clicked grid
			else clickX = x; clickY = y 
				startX = ToMapCoord(clickX)
				startY = ToMapCoord(clickY)
				startSet = true; UpdateCells()
			end
		end
	end

	-- Right click
	if button == 'r' then
		if settingsSet then
			-- Clicked out of bounds
			if x > w * cellSize 
				or y > h * cellSize then

			-- Clicked grid
			else rclickX = x; rclickY = y
				-- Clicked the start cell, remove it
				if ToMapCoord(x) == startX
					and ToMapCoord(y) == startY
						then startSet = false end

				-- Clicked the finish cell, remove it
				if ToMapCoord(x) == finishX
					and ToMapCoord(y) == finishY
						then finishSet = false end

				-- Clicked any cell, remove it
				map[ToMapCoord(rclickY)][ToMapCoord(rclickX)] = '.'
				UpdateCells()
			end
		end
	end
end

-- Mouse released event listener
function love.mousereleased(x, y, button)
	if button == 'l' then
		if settingsSet then
			button_export.mousereleased(x, y, button, clickHandler_export)
			button_settings.mousereleased(x, y, button, clickHandler_settings)
			button_clear.mousereleased(x, y, button, clickHandler_clear)
		end
		if not settingsSet then
			settings.mousereleased(x, y, button)
		end
	end
end

-- Key press event listener
function love.keypressed(key)
	-- Handle map move direction input keys
	if settingsSet then
		local x, y = love.mouse.getPosition()
		local validPos = true

		if ToMapCoord(x) > w then validPos = false
		else x = ToMapCoord(x) end

		if ToMapCoord(y) > h then validPos = false
		else y = ToMapCoord(y) end
		
		if validPos then
			if     key == 'w' then map[y][x] = '^'; CheckCell(y, x)
			elseif key == 'd' then map[y][x] = '>'; CheckCell(y, x)
			elseif key == 's' then map[y][x] = 'v'; CheckCell(y, x)
			elseif key == 'a' then map[y][x] = '<'; CheckCell(y, x)
			elseif key == 'x' then
				if finishSet then
					map[finishY][finishX] = '.'
					map[y][x] = '*'
					finishY = y
					finishX = x
				else
					map[y][x] = '*'
					finishY = y
					finishX = x
					finishSet = true
				end
			end
			UpdateCells()
		end
	end

	-- Send keys to settings dialog
	if not settingsSet then
		settings.keypressed(key)
	end
end

-- Handle text input
function love.textinput(text)
	if not settingsSet then
		settings.textinput(text)
	end
end
