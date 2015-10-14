io.stdout:setvbuf('no')
love.window.setTitle('Map Maker')
font = love.graphics.newFont('SourceCodePro-Regular.ttf', 14)
icon = love.graphics.newImage('icon.png')
iconData = icon:getData()
love.window.setIcon(iconData)

local settingsDialog = require 'settingsdialog'
local text           = require 'textbox'
local button         = require 'button'
local event          = require 'clickhandler'

local mapChecker  = require 'mapchecker'
local mapExporter = require 'mapexporter'

local cellSize = 30

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

local canvas_grid
local canvas_activeCells

function love.load()
	love.graphics.setFont(font)

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

	-- Bottom buttons
	button_export = button.newButton(
		'Export', 0, toCell(h), toCell(w) / 2)
	button_clear = button.newButton(
		'Clear', toCell(w) / 2 + 1, toCell(h), toCell(w)/2)
	button_settings = button.newButton(
		'Settings', 0, toCell(h) + 26, toCell(w))

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

				-- Select first text box
				settings.TabSelect()
			end
		))

	-- Set window size for the grid and bottom buttons
	love.window.setMode(w * cellSize, h * cellSize + 51)

	-- Build empty map
	map = {}
	for y = 1, h do
		map[y] = {}
		for x = 1, w do
			map[y][x] = '.'
		end
	end

	-- Prepare background grid canvas and draw background grid to it
	canvas_grid = love.graphics.newCanvas(toCell(w), toCell(h))
	love.graphics.setCanvas(canvas_grid)
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
	love.graphics.setCanvas()

	-- Prepare the canvas for active direction marker cells
	canvas_activeCells = love.graphics.newCanvas(toCell(w), toCell(h))
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

	-- Print coords on screen
	local mouseX, mouseY = love.mouse.getPosition()
	if toMapCoord(mouseX) > w then mouseX = w
		else mouseX = toMapCoord(mouseX) end
	if toMapCoord(mouseY) > h then mouseY = h
		else mouseY = toMapCoord(mouseY) end
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print(mouseY..','..mouseX, 3, toCell(h) - 20)

end

-- Make number fit a map coord (1-index)
function toMapCoord(number)
	return math.floor((number / cellSize) + 1)
end

-- Make number fit a grid coord (0-index)
function toGridCoord(number)
	return math.floor((number / cellSize))
end

-- Make a coord fit a cell
function toCell(number)
	return number * cellSize
end

-- Check if direction cell overwrites finish cell, overwrite it if so
-- Requires numbers to be map coordinates
function checkCell(x, y)
	if x == finishX
		and y == finishY
			then finishSet = false 
			finishY = 0; finishX = 0 end
end

-- Center a character within a grid cell, set its background color
-- Takes in map coords but they need to be grid coords, so subtract 1
function cellText(text, y, x)
	if startX == x and startY == y and startSet then 
		love.graphics.setColor(0, 255, 0, 255)
	else
		love.graphics.setColor(223, 229, 123, 255)
	end
	love.graphics.rectangle(
		'fill', toCell(x - 1), toCell(y - 1), cellSize, cellSize)
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print(text, toCell(x - 1) + 10, toCell(y - 1) + 5 )
end

-- Update the activeCells canvas
function updateCells()
	love.graphics.setCanvas(canvas_activeCells)
		canvas_activeCells:clear()

		-- Draw chosen start coord cell
		if startSet then
			love.graphics.setColor(0, 255, 0, 255)
			love.graphics.rectangle('fill', 
				toCell(toGridCoord(clickX)),
				toCell(toGridCoord(clickY)),
				cellSize, cellSize)
		end

		-- Draw movement marker cells
		for y = 1, #map do
			for x = 1, #map[y] do
				if     map[y][x] == '^' then cellText('^', y, x)
				elseif map[y][x] == '>' then cellText('>', y, x)
				elseif map[y][x] == 'v' then cellText('v', y, x)
				elseif map[y][x] == '<' then cellText('<', y, x)
				elseif map[y][x] == '*' then cellText('*', y, x)
				end
			end
		end

	love.graphics.setCanvas()
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
			else clickX = x; clickY = y end

			startX = toMapCoord(clickX)
			startY = toMapCoord(clickY)

			if not button_export.active and not button_settings.active
				and not button_clear.active then startSet = true
					updateCells() end
		end
	end

	-- Right click
	if button == 'r' then
		-- Clicked out of bounds
		if x > w * cellSize 
			or y > h * cellSize then

		-- Clicked grid
		else rclickX = x; rclickY = y end

		-- Clicked the start cell, remove it
		if toMapCoord(x) == startX
			and toMapCoord(y) == startY
				then startSet = false end

		-- Clicked the finish cell, remove it
		if toMapCoord(x) == finishX
			and toMapCoord(y) == finishY
				then finishSet = false end

		-- Clicked any cell, remove it
		map[toMapCoord(rclickY)][toMapCoord(rclickX)] = '.'
		updateCells()
	end
end

-- Mouse released event listener
function love.mousereleased(x, y, button)
	if settingsSet then
		button_export.mousereleased(x, y, button, clickHandler_export)
		button_settings.mousereleased(x, y, button, clickHandler_settings)
		button_clear.mousereleased(x, y, button, clickHandler_clear)
	end
	if not settingsSet then
		settings.mousereleased(x, y, button)
	end
end

-- Key press event listener
function love.keypressed(key)
	-- Handle map move direction input keys
	if settingsSet then
		local x, y = love.mouse.getPosition()
		local validPos = true
		if toMapCoord(x) > w then validPos = false
			else x = toMapCoord(x) end
		if toMapCoord(y) > h then validPos = false
			else y = toMapCoord(y) end
		if validPos then
			if     key == 'w' then map[y][x] = '^';	checkCell(x, y)
			elseif key == 'd' then map[y][x] = '>'; checkCell(x, y)
			elseif key == 's' then map[y][x] = 'v'; checkCell(x, y)
			elseif key == 'a' then map[y][x] = '<'; checkCell(x, y)
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
			updateCells()
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