-- @namespace MapMaker
-- @class MapExporter: 
-- Export the drawn map to .map file. MapExporter handles the primary
-- logic behind making sure a map contains the essentials to be read
-- by the robot, whereas MapChecker will verify that the actual path
-- itself is able to be followed by the robot.
local MapMaker = {}; function MapMaker.newMapExporter()
	
	-- Constructor
	local this = {}

	local mapChecker = require 'mapchecker'

	-- Export map after running it through MapChecker and checking
	-- for required details (start point, finish point)
	function this.ExportMap(map, h, w, startY, startX, startSet, finishSet)
		local mapBuilder, allowExport
		if startSet and finishSet and map[startY][startX] ~= '.' then
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
			local check = mapChecker.newMapChecker(h, w, startY, startX)
			if check.CheckMap(map) then
				allowExport = true
			else
				allowExport = false
				local buttons = {'OK'}
				local alert = love.window.showMessageBox(
					'Alert',
					[[MapChecker could not find a valid direction path.
Please make sure there is a complete path from start to
finish.

Note: paths can not cross the same cell more than once.]],
					buttons
				)
			end
		elseif startSet and finishSet and map[startY][startX] == '.' then
			local buttons = {'OK'}
			local alert = love.window.showMessageBox(
				'Alert',
				'You need to set a start direction before the map can be exported.',
				buttons
			)
		elseif startSet and not finishSet and map[startY][startX] == '.' then
			local buttons = {'OK'}
			local alert = love.window.showMessageBox(
				'Alert',
				'You need to set a start direction and a finish before the map can be exported.',
				buttons
			)
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

	return this
end

return MapMaker