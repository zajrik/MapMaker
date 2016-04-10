io.stdout:setvbuf('no')
love.window.setTitle('Map Maker')

local debug = false
local debug_update = 0
local debug_mem = 0
local debug_fps = 0

local font_regular = love.graphics.newFont(14)
local font_small   = love.graphics.newFont(10)

local icon = love.graphics.newImage('icon.png')
local iconData = icon:getData()

love.window.setIcon(iconData)
love.graphics.setFont(font_regular)

local colors =
{
	white = {255, 255, 255},
	gray  = {230, 230, 230},
	black = {0,   0,   0  }
}

local _settingsDialog = require 'settingsdialog'
local _button         = require 'button'
local _event          = require 'clickhandler'
local _tooltip        = require 'tooltip'

local _mapEditor   = require 'mapeditor'
local _mapExporter = require 'mapexporter'

local winX, winY, display

local h, w
local cellSize = 30

local canvas_grid

local button_export
local button_clear
local button_settings

local clickHandler_export
local clickHandler_clear
local clickHandler_settings

local tooltip_export

local editor
local exporter
local settings

local programMode
local mode =
{
	EDITOR   = 1,
	SETTINGS = 2
}

-- Set the current mode of the program
local function SetMode(m)
	programMode = m
end

-- Return current mode of the program
local function InMode(m)
	return programMode == m
end

-- Make number fit a map coord (1-index)
local function ToMapCoord(number)
	return math.floor((number / cellSize) + 1)
end

-- Make a coord fit a cell
local function ToCell(number)
	return number * cellSize
end

-- Ensure a number stays inside min/max boundaries
local function InRange(num, min, max)
	return math.max(min, math.min(num, max))
end

-- Run the exporter live checker and update tooltips
local function CheckMap()
	exporter.LiveChecker(
		editor.map, h, w, editor.startY,
		editor.startX, editor.startSet, editor.finishSet)
	button_export.enabled = exporter.validMap
	tooltip_export.SetText(
		exporter.validMap and nil or exporter.errorMessages[exporter.errorCode])
end

function love.load()
	SetMode(mode.EDITOR)

	settings = _settingsDialog.newSettingsDialog()

	-- Get height, width from settings file
	h, w = settings.Read()
	settings.currentH, settings.currentW = h, w

	-- Preserve window position
	winX, winY, display = love.window.getPosition()

	-- Set window size for the grid and bottom buttons
	love.window.setMode(w * cellSize, (h * cellSize) + 52,
		{display = display, x = winX, y = winY})

	-- Create map editor and exporter instances
	editor   = _mapEditor.newMapEditor(h, w)
	exporter = _mapExporter.newMapExporter()

	--  Create button instances
	button_export = _button.newButton(
		'Export', 0, ToCell(h) + 1, ToCell(w) / 2, false)
	button_clear = _button.newButton(
		'Clear', (ToCell(w) / 2) + 1, ToCell(h) + 1, (ToCell(w) / 2) - 1)
	button_settings = _button.newButton(
		'Settings', 0, ToCell(h) + 27, ToCell(w))

	-- Create button click handlers
	clickHandler_export =
		_event.newClickHandler((
			function()
				exporter.ExportMap(
					editor.map, h, w, editor.startY,
					editor.startX, editor.startSet, editor.finishSet)
			end
		))
	clickHandler_clear =
		_event.newClickHandler((
			function()
				love.load()
			end
		))
	clickHandler_settings =
		_event.newClickHandler((
			function()
				SetMode(mode.SETTINGS)
				settings.settingsChosen = false
				settings.TabSelect()
			end
		))

	-- Initialize tooltips
	tooltip_export = _tooltip.newTooltip(button_export)

	-- Prepare background grid canvas and draw background grid to it
	canvas_grid = love.graphics.newCanvas(ToCell(w), ToCell(h))
	canvas_grid:renderTo(function()
		local nextX, nextY = 0, 0
		for y = 1, h do
			for x = 1, w do
				if y % 2 ~= 0 then
					love.graphics.setColor(x % 2 == 0 and
						colors.gray or colors.white)
				else
					love.graphics.setColor(x % 2 == 0 and
						colors.white or colors.gray)
				end
				love.graphics.rectangle(
					'fill', nextX , nextY, cellSize, cellSize)
				nextX = nextX + cellSize
			end
			nextX, nextY = 0, (nextY + cellSize)
		end
	end)

	CheckMap()
end

-- Update timer
function love.update(dt)
	settings.update(dt)
	tooltip_export.update(dt)
	exporter.update(dt)

	debug_update = (debug and debug_update + dt or 1)
end

-- Draw all the things, constantly, forever
function love.draw()

	-- Draw background grid canvas
	love.graphics.setColor(colors.white)
	love.graphics.draw(canvas_grid, 0, 0)

	-- Draw editor content
	editor.draw()

	-- Draw bottom buttons
	button_export.draw()
	button_settings.draw()
	button_clear.draw()

	-- Add tooltips to view
	if InMode(mode.EDITOR) then tooltip_export.Add() end

	-- Layer settings dialog on top, centered vertically/horizontally on grid
	if settings.settingsChosen then SetMode(mode.EDITOR) end
	if InMode(mode.SETTINGS) then settings.Show() end

	-- Allow exporter to draw toasts
	exporter.draw()

	-- Draw debug info
	if debug then
		-- Draw coordinates in bottom-left corner
		love.graphics.setFont(font_small)
		local mouseX, mouseY = love.mouse.getPosition()
		mouseX = InRange(ToMapCoord(mouseX), 1, w)
		mouseY = InRange(ToMapCoord(mouseY), 1, h)
		love.graphics.setColor(colors.black)
		love.graphics.print(mouseY..','..mouseX, 2, ToCell(h) - 14)

		-- Draw memory usage, fps
		love.graphics.print(
			'Lua Memory Usage: '..string.format('%d',debug_mem)..' KB', 5, 3)
		love.graphics.print('FPS: '..debug_fps, 5, 13)
		love.graphics.setFont(font_regular)

		-- Update debug information
		if debug_update >= 1 then
			debug_mem = collectgarbage('count')
			debug_fps = love.timer.getFPS()
			debug_update = 0
		end
	end

end

-- Mouse pressed event listener
function love.mousepressed(x, y, button)
	-- Convert button int (love 0.10.0+) to MouseConstant
	if     button == 1 then button = 'l'
	elseif button == 2 then button = 'r' end

	-- Pass mouse events to exporter for toast alerts
	exporter.mousepressed(x, y, button)

	-- Handle left click
	if button == 'l' and not exporter.alertClick then
		-- Pass mouse presses to settings dialog
		settings.mousepressed(x, y, button)

		if InMode(mode.EDITOR) then
			-- Pass clicks to map editor
			editor.mousepressed(x, y, button)
			CheckMap()

			-- Send out valid mouse events to buttons
			button_export.mousepressed(x, y, button)
			button_settings.mousepressed(x, y, button)
			button_clear.mousepressed(x, y, button)
		end
	end

	-- Handle right click
	if button == 'r' and not exporter.alertClick then
		if InMode(mode.EDITOR) then
			-- Pass clicks to map editor
			editor.mousepressed(x, y, button)
			CheckMap()
		end
	end
end

-- Mouse released event listener
function love.mousereleased(x, y, button)
	-- Convert button int (love 0.10.0+) to MouseConstant
	if     button == 1 then button = 'l'
	elseif button == 2 then button = 'r' end

	-- Pass mouse events to exporter for toast alerts
	exporter.mousereleased(x, y, button)

	if button == 'l' and not exporter.alertClick then
		if InMode(mode.EDITOR) then
			button_export.mousereleased(x, y, button, clickHandler_export)
			button_settings.mousereleased(x, y, button, clickHandler_settings)
			button_clear.mousereleased(x, y, button, clickHandler_clear)
		elseif InMode(mode.SETTINGS) then
			settings.mousereleased(x, y, button)
		end
	end
end

-- Key press event listener
function love.keypressed(key)
	if InMode(mode.EDITOR) then
		-- Pass keys to map editor
		editor.keypressed(key)
		CheckMap()

	elseif InMode(mode.SETTINGS) then
		-- Pass keys to settings dialog
		settings.keypressed(key)
	end

	-- Activate debug info
	if love.keyboard.isDown('lctrl') and key == 'g' then
		debug = not debug end
end

-- Handle text input
function love.textinput(text)
	if InMode(mode.SETTINGS) then
		settings.textinput(text)
	end
end
