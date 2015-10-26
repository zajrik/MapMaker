-- @namespace MapMaker
-- @class ClickHandler:
-- This is pretty much just to provide a nicer syntax for declaring and passing
-- the lamba function that a button or other clickable object is meant to 
-- execute to the object itself. It could have just as easily been done storing
-- the lambda as a variable but I didn't care for how that looked.
local MapMaker = {}; function MapMaker.newClickHandler(lambda)
	
	-- Constructor
	local this = 
	{
		lambda = lambda
	}

	return this.lambda
end

return MapMaker