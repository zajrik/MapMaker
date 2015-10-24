-- @namespace MapMaker
-- @class MapExporter: 
-- Export the drawn map to .map file. MapExporter handles the primary
-- logic behind making sure a map contains the essentials to be read
-- by the robot, whereas PathChecker will verify that the actual path
-- itself is able to be followed by the robot.
local MapMaker = {}; function MapMaker.newMapExporter()
	
	-- Constructor
	local this = 
	{
		validMap = false,
		errorCode,
		errorCodes
	}

	local pathChecker = require 'pathchecker'

	errorCodes =
	{
		[[PathChecker could not find a valid direction path.
Please make sure there is a complete path from start to
finish.

Note: paths can not cross the same cell more than once.]],
		'You need to set a start direction before the map can be exported.',
		'You need to set a start direction and a finish before the map can be exported.',
		'You need to set a finish before the map can be exported.',
		'You need to set a starting point before the map can be exported.',
		'You need to set a start and finish before the map can be exported.'
	}

	-- To be called every time a change to the map is made.
	function this.LiveChecker(map, h, w, startY, startX, startSet, finishSet)
		if startSet and finishSet and map[startY][startX] ~= '.' then
			local check = pathChecker.newPathChecker(h, w, startY, startX)
			if check.CheckPath(map) then
				this.validMap = true; errorCode = 0
			else errorCode = 1 end
		elseif startSet and finishSet and map[startY][startX] == '.' then
			errorCode = 2
		elseif startSet and not finishSet and map[startY][startX] == '.' then
			errorCode = 3
		elseif startSet and not finishSet then
			errorCode = 4
		elseif not startSet and finishSet then
			errorCode = 5
		elseif not startSet and not finishSet then
			errorCode = 6
		end
		if errorCode > 0 then this.validMap = false end
	end

	-- Export map after running it through PathChecker and checking
	-- for required details (start point, finish point, start direction)
	function this.ExportMap(map, h, w, startY, startX, startSet, finishSet)
		-- Run live checker a final time, just to be safe
		this.LiveChecker(map, h, w, startY, startX, startSet, finishSet)

		if this.validMap then
			-- Build map string
			local mapBuilder = ''
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

			-- Create directory for generated map
			if not love.filesystem.exists('/map') then
				love.filesystem.createDirectory('map') end

			-- Write map string to file
			local generatedMap, errorstr = 
				love.filesystem.newFile('/map/generatedMap.map')
			generatedMap:open('w')
			generatedMap:write(mapBuilder)
			generatedMap:close()

			-- Handle map write result
			if not errorstr then
				local buttons = {'OK', 'Cancel'}
				local result = love.window.showMessageBox(
					'Alert',
					'Map was created successfully.\nPress OK to navigate to the map file.',
					buttons
				)
				if result == 1 then
					love.system.openURL(
						'file://'..love.filesystem.getSaveDirectory()..'/map')
				end
			else
				local alert = love.window.showMessageBox(
					'Alert',
					'There was a problem creating the map file.\nPlease try again.'
				)
			end

		-- Just in case something makes it past the export
		-- button lockout, display the last error message
		else
			local alert = love.window.showMessageBox(
				'Alert',
				errorCodes[errorCode]
			)
		end
	end

	return this
end

return MapMaker