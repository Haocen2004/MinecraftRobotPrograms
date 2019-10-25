local SpiralMiner = {}
local cm = require("./ChainMine")

local rX, rY = 0, 0 --relative pos

function SpiralMiner.main()
	while (true) do
		SpiralMiner.updateDirection()
		SpiralMiner.digForward()
		SpiralMiner.checkInv()
		cm.chainMine()
		SpiralMiner.checkFuel()
	end
end


function SpiralMiner.checkFuel()
	local hasFuel = true;
	while (turtle.getFuelLimit() - turtle.getFuelLevel() >= 80 and hasFuel)
	do
		hasFuel = false;
		if (turtle.refuel(1)) then
			hasFuel = true
		else
			for i=1,16 do
				if (turtle.refuel(1)) then
					hasFuel = true
					break
				end
			end
		end
	end
	if (turtle.getFuelLevel() < (math.abs(rX) + math.abs(rY))+150) then
		SpiralMiner.goOrigin()
	end
end

function SpiralMiner.checkInv()
	for (i=1,16) do
		if (turtle.getItemCount == 0) then
			return true
		end
	end
	if (not SpiralMiner.dumpToBox()) then
		SpiralMiner.goOrigin()
	end
	return false
end

function SpiralMiner.dumpToBox()
	-- TODO
end

function SpiralMiner.goOrigin()
	-- TODO
end

function SpiralMiner.updateDirection()
	-- TODO
end

function SpiralMiner.digForward()
	while not turtle.forward()
	do
		turtle.dig()
		turtle.digUp()
	end
end

ChainMine.chainMine()
