local SpiralMiner = {}
local CM = require("/MinecraftRobotPrograms/Miner/ChainMine")
-- local AT = require("/MinecraftRobotPrograms/Miner/AdvancedTurtle")

function SpiralMiner.main()
	while (not redstone.getInput("back")) do
		SpiralMiner.checkInv()
		-- SpiralMiner.updateDirection()
		SpiralMiner.digForward()
		CM.chainMine()
		turtle.digUp()
		SpiralMiner.checkFuel()
		print("current fuel: "..turtle.getFuelLevel().."/"..turtle.getFuelLimit())
	end
end

local fuel = {
	coal = {
		name = "minecraft:coal",
		value = 80
	}
}
function SpiralMiner.checkFuel()
	local hasFuel = true;
	while (turtle.getFuelLimit() - turtle.getFuelLevel() >= fuel.coal.value and hasFuel) do
		local coalRequired = math.floor((turtle.getFuelLimit() - turtle.getFuelLevel())/80)
		if (coalRequired > 64) then
			coalRequired = 64
		end
		hasFuel = false;

		if (turtle.refuel(coalRequired)) then
			hasFuel = true
		else
			for i=1,16 do
				if (turtle.getItemCount(i) > 0 and turtle.getItemDetail(i).name==fuel.coal.name) then
					turtle.select(i)
					hasFuel = true
					break
				end
			end
		end
	end

	-- if (turtle.getFuelLevel() < (math.abs(rX) + math.abs(rY))+150) then
	-- 	SpiralMiner.goOrigin()
	-- end
end

function SpiralMiner.checkInv()
	for i=1,16 do
		if (turtle.getItemCount(i) == 0) then
			return true
		end
	end
	if (not SpiralMiner.dumpToBox()) then
		SpiralMiner.goOrigin()
	end
	return false
end

local BoxItem = {
	count = 1,
	name = "ic2:te",
	damage = 111
}
function SpiralMiner.dumpToBox()
	local hasBox = false;
	for i=1,16 do
		local item = turtle.getItemDetail(i)
		if (item ~= nil and item.name == BoxItem.name and item.count == 1 and item.damage == BoxItem.damage) then
			turtle.select(i)
			hasBox = true
			break
		end
	end
	if (not hasBox) then
		return false
	end
	turtle.turnLeft()
	turtle.turnLeft()
	if (not turtle.place()) then
		turtle.turnLeft()
		turtle.turnLeft()
		return false
	end

	local hasFuel = false;
	local isFullBox = true;
	for i = 1, 16 do
		if ((not hasFuel) and turtle.getItemDetail(i).name == fuel.coal.name) then
			hasFuel = true;
		else
			turtle.select(i)
			turtle.drop()
			if (turtle.getItemCount(i) == 0) then
				isFullBox = false
			end
		end
	end
	
	turtle.dig()
	turtle.turnLeft()
	turtle.turnLeft()

	return (not isFullBox)
end

function SpiralMiner.goOrigin()
	os.exit()
	-- TODO
end

function SpiralMiner.updateDirection()
	-- TODO
end

function SpiralMiner.digForward()
	while not turtle.forward() do
		turtle.dig()
	end
end

function SpiralMiner.digUp()
	while not turtle.up() do
		turtle.digUp()
	end
end

SpiralMiner.main()

return SpiralMiner