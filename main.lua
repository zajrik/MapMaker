io.stdout:setvbuf("no")
love.window.setTitle('Map Maker')
font = love.graphics.newFont("SourceCodePro-Regular.ttf", 14)
icon = love.graphics.newImage('icon.png')
iconData = icon:getData()
love.window.setIcon(iconData)

local settingsDialog = require 'settingsdialog'
local text = require 'textbox'
local btn = require 'button'

local cellSize = 30

local settings
local exportButton
local settingsButton

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

	finishY = 1
	finishX = 1
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
	exportButton = btn.newButton('Export', 0, toCell(h), toCell(w) / 2)
	settingsButton = btn.newButton('Settings', toCell(w) / 2 + 1, toCell(h), toCell(w)/2)

	-- Set window size for the grid and bottom buttons
	love.window.setMode(w * cellSize, h * cellSize + 25)

	-- Build empty map
	map = {}
	for y = 1, h do
		map[y] = {}
		for x = 1, w do
			map[y][x] = '.'
		end
	end
end


-- Draw all the things, constantly, forever
function love.draw()
	love.graphics.setFont(font)
	-- Draw background grid
	local count = 1
	local moveX = 0
	local moveY = 0
	for i = 1, h do
		for i = 1, w do
			if count % 2 ~= 0 then
				if i % 2 == 0 then love.graphics.setColor(240, 240, 240, 255)
				else love.graphics.setColor(255, 255, 255, 255) end
			else
				if i % 2 ~= 0 then love.graphics.setColor(240, 240, 240, 255)
				else love.graphics.setColor(255, 255, 255, 255) end
			end
			love.graphics.rectangle('fill', moveX , moveY, cellSize, cellSize)
			moveX = moveX + cellSize
		end
		count = count + 1
		moveX = 0
		moveY = moveY + cellSize
	end

	-- Draw chosen start coord cell
	if startSet then
		love.graphics.setColor(0, 255, 0, 255)
		love.graphics.rectangle('fill', 
			toCell(toGridCoord(clickX)),
			toCell(toGridCoord(clickY)),
			cellSize, cellSize)
	end

	-- Draw bottom buttons
	exportButton.Show()
	settingsButton.Show()

	-- Draw movement markers.
	for y = 1, #map do
		for x = 1, #map[y] do
			if     map[y][x] == '^' then blockText('^', y, x)
			elseif map[y][x] == '>' then blockText('>', y, x)
			elseif map[y][x] == 'v' then blockText('v', y, x)
			elseif map[y][x] == '<' then blockText('<', y, x)
			elseif map[y][x] == '*' then blockText('*', y, x)
			end
		end
	end

	-- Layer settings dialog on top, centered on grid vertically/horizontally
	if settings.settingsChosen then
		settingsSet = true
	end
	if not settingsSet then
		settings.Show()
	end

	-- Print coords on screen
	local mouseX, mouseY = love.mouse.getPosition()
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print(toMapCoord(mouseY)..','..toMapCoord(mouseX), 3, toCell(h)-20)

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

-- Center a character within a grid cell, set its background color
-- Takes in map coords but they need to be grid coords, so subtract 1
function blockText(text, y, x)
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

-- Export the map
function ExportMap()
	local mapBuilder, allowExport
	if startSet and finishSet then
		mapBuilder = ''
		mapBuilder = mapBuilder..string.format(
			'! h:%d; w:%d; sx:%d; sy:%d\n',
			h, w, startY, startX)
		for y = 1, #map do
			for x = 1, #map[y] do
				if x ~= #map[y] then
					mapBuilder = mapBuilder..map[y][x]..','
				elseif x == #map[y] and y == #map then
					mapBuilder = mapBuilder..map[y][x]
				elseif x == #map[y] then
					mapBuilder = mapBuilder..map[y][x]..'\n'
				end
			end
		end
		allowExport = true
	elseif startSet and not finishSet then
		local buttons = {'OK'}
		local alert = love.window.showMessageBox(
			'Alert', 
			'You need to set a finish before the map can be exported.',
			buttons
		)
		allowExport = false
	elseif not startSet and finishSet then
		local buttons = {'OK'}
		local alert = love.window.showMessageBox(
			'Alert', 
			'You need to set a starting point before the map can be exported.',
			buttons
		)
		allowExport = false
	elseif not startSet and not finishSet then
		local buttons = {'OK'}
		local alert = love.window.showMessageBox(
			'Alert', 
			'You need to set a start and finish before the map can be exported.',
			buttons
		)
		allowExport = false
	end
	if allowExport then
		local generatedMap = io.open('generatedMap.map', 'w')
		generatedMap:write(mapBuilder)
		generatedMap:close()
	end
end



-- Mouse pressed event listener
function love.mousepressed(x, y, button)
	settings.mousepressed(x, y, button)
	-- Left click
	if button == 'l' then
		if settingsSet then
			-- Send out valid mouse events to component objects
			exportButton.mousepressed(x, y, button)
			settingsButton.mousepressed(x, y, button)

            -- Clicked out of bounds
			if x > w * cellSize
				or y > h * cellSize then

			-- Clicked grid
			else clickX = x; clickY = y end

			startX = toMapCoord(clickX)
			startY = toMapCoord(clickY)

			if not exportButton.active and not settingsButton.active
				then startSet = true end

			-- Debug msg
			-- if startSet then
			-- 	print(string.format(
			-- 		'map[%d][%d]',toMapCoord(y), 
			-- 			toMapCoord(x)))
			-- end
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

		-- Clicked the finish sell, remove it
		if toMapCoord(x) == finishX
			and toMapCoord(y) == finishY
				then finishSet = false end

		-- Clicked any cell, remove it
		map[toMapCoord(rclickY)][toMapCoord(rclickX)] = '.'
	end
end

-- Mouse released event listener
function love.mousereleased(x, y, button)
	if settingsSet then
		exportButton.mousereleased(x, y, button)
		settingsButton.mousereleased(x, y, button)
		if exportButton.clicked then
			ExportMap()
			exportButton.clicked = false
		end
		if settingsButton.clicked then
			settings.settingsChosen = false
			settingsSet = false
			settingsButton.clicked = false

			-- Select first text box
			settings.TabSelect()
		end
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
		if key == 'w' then
			map[toMapCoord(y)][toMapCoord(x)] = '^'
		elseif key == 'd' then
			map[toMapCoord(y)][toMapCoord(x)] = '>'
		elseif key == 's' then
			map[toMapCoord(y)][toMapCoord(x)] = 'v'
		elseif key == 'a' then
			map[toMapCoord(y)][toMapCoord(x)] = '<'
		elseif key == 'x' then
			if finishSet then
				map[finishY][finishX] = '.'
				print(finishY..', '..finishX)
				map[toMapCoord(y)][toMapCoord(x)] = '*'
				print(toMapCoord(y)..', '..toMapCoord(x))
				finishY = toMapCoord(y)
				finishX = toMapCoord(x)			
			else
				map[toMapCoord(y)][toMapCoord(x)] = '*'
				finishY = toMapCoord(y)
				finishX = toMapCoord(x)
				finishSet = true
			end
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

