local SpiralMiner = {}
local CM = require("/MinecraftRobotPrograms/Miner/ChainMine")
-- local AT = require("/MinecraftRobotPrograms/Miner/AdvancedTurtle")

function SpiralMiner.main()
	while (not redstone.getInput("back") and keepRun) do
		SpiralMiner.updateDirection()

		SpiralMiner.digForward()
		CM.chainMine()
		while not turtle.up() do
			turtle.digUp()
		end
		CM.chainMine()
		turtle.down()

		SpiralMiner.checkInv()
		SpiralMiner.checkFuel()
		print("current fuel: "..turtle.getFuelLevel().."/"..turtle.getFuelLimit())
		print("spiralLength: "..spiralLength.." distance: "..distance)
	end

	if (not keepRun) then
		print(errorMsg)
	end
end

local spiralLength = 3
local distance = 1
function SpiralMiner.updateDirection()
	distance = distance + 1
	if (distance == spiralLength) then
		distance = 1
		spiralLength = spiralLength + 1
		turtle.turnLeft()
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
				if (turtle.getItemCount(i) > 0 and turtle.getItemDetail(i)~= nil and turtle.getItemDetail(i).name==fuel.coal.name) then
					turtle.select(i)
					hasFuel = true
					break
				end
			end
		end
	end

	if (turtle.getFuelLevel() < (math.abs(rX) + math.abs(rY))+150) then
		SpiralMiner.goOrigin(
			function()
				SpiralMiner.exit("Out Of Fuel")
			end
		)
	end
end

function SpiralMiner.checkInv()
	for i=1,16 do
		if (turtle.getItemCount(i) == 0) then
			return true
		end
	end
	if (not SpiralMiner.dumpToBox()) then
		SpiralMiner.goOrigin(SpiralMiner.changeBox)
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

	turtle.placeUp()

	local hasFuel = false;
	local space = 0;
	for i = 1, 16 do
		if ((not hasFuel) and turtle.getItemDetail(i).name == fuel.coal.name) then
			hasFuel = true;
		else
			turtle.select(i)
			turtle.dropUp()
			if (turtle.getItemCount(i) == 0) then
				space = space + 1
			end
		end
	end
	
	turtle.digUp()

	return space > 1
end

function SpiralMiner.changeBox()
	for i=1,16 do
		turtle.select(i)
		if (not turtle.dropUp()) then
			SpiralMiner.exit("Failed Dumping In Origin")
		end
	end
	if (not turtle.suckDown(1)) then
		SpiralMiner.exit("Out Of Box In Origin")
	end
end

function SpiralMiner.goOrigin(todo)
	-- Manage the way back (inevitably destroy some diamonds!)
	local targetDistance = (spiralLength - 1) / 2
	if (targetDistance % 2 == 0) then
		if ((targetDistance / 2) % 2 == 0) then
			targetDistance = targetDistance + 1
		else
			targetDistance = targetDistance - 1
		end
	end
	local currentDistance = distance
	while (currentDistance ~= targetDistance) do
		if (currentDistance > targetDistance) then
			turtle.back()
			currentDistance = currentDistance - 1
		else
			turtle.digForward()
			currentDistance = currentDistance + 1
		end
	end
	turtle.turnLeft()
	local targetCross = (spiralLength - 1) / 2
	if (targetCross % 2 == 1) then
		if ((targetDistance / 2) % 2 == 0) then
			targetCross = targetCross - 1
		else
			targetCross = targetCross + 1
		end
	end
	for i=1,targetCross do
		turtle.digForward()
	end

	todo()

	-- Then return to the breakpoint
	for i=1,targetCross do
		turtle.back()
	end
	turtle.turnRight()
	while (currentDistance ~= distance) do
		if (currentDistance > distance) then
			turtle.back()
			currentDistance = currentDistance - 1
		else
			turtle.forward()
			currentDistance = currentDistance + 1
		end
	end
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

function SpiralMiner.exit(msg)
	print(msg)
	os.exit()
end

SpiralMiner.main()

return SpiralMiner