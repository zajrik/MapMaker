-- @namespace MapMaker
-- @class MapChecker: Check map for valid path
local MapMaker = {}; function MapMaker.newMapChecker(mapHeight, mapWidth, startX, startY)
	
	-- Constructor
	local this = 
	{
		mapHeight = mapHeight,
		mapWidth = mapWidth,
		startX = startX,
		startY = startY
	}

	-- Direction enum
	local Direction = 
	{
		NORTH = 1,
		EAST  = 2,
		SOUTH = 3,
		WEST  = 4,
		HOME  = 5
	}

	-- Start at start point, follow path, return true/false for valid/invalid map
	function this.CheckMap(map)

		local x, y
		local startDirection, next
		local foundEnd = false

		-- Get start direction from start coordinate
		x = tonumber(this.startX); y = tonumber(this.startY)
		if     map[x][y] == '^' then startDirection = Direction.NORTH
		elseif map[x][y] == '>' then startDirection = Direction.EAST
		elseif map[x][y] == 'v' then startDirection = Direction.SOUTH
		elseif map[x][y] == '<' then startDirection = Direction.WEST
		elseif map[x][y] == '.' then return false
		end

		next = startDirection

		-- Follow map path, return false if invalid path
		local limiter = (this.mapHeight * this.mapWidth)
		local counter = 0
		repeat
			if     counter > limiter then return false end
			if     next == Direction.NORTH then x = x - 1
			elseif next == Direction.EAST  then y = y + 1
			elseif next == Direction.SOUTH then x = x + 1
			elseif next == Direction.WEST  then y = y - 1
			end

			if     map[x][y] == '^' then next = Direction.NORTH
			elseif map[x][y] == '>' then next = Direction.EAST
			elseif map[x][y] == 'v' then next = Direction.SOUTH
			elseif map[x][y] == '<' then next = Direction.WEST
			elseif map[x][y] == '*' then next = Direction.HOME
				if this.startX == x and this.startY == y then
					return false
				else
					foundEnd = true
				end
			elseif map[x][y] == '.' then return false
			else end

			counter = counter + 1
		until foundEnd

		if not foundEnd then return false
		else return true end
	end

	return this
end

return MapMaker