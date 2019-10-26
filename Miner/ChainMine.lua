local ChainMine = {}
local AdvancedTurtle = require("/MinecraftRobotPrograms/Miner/AdvancedTurtle")

local oreList = {
	["minecraft:coal_ore:0"] = false,
	["minecraft:iron_ore:0"] = false,
	["minecraft:gold_ore:0"] = false,
	["minecraft:diamond_ore:0"] = true,
	["minecraft:redstone_ore:0"] = false,
	["minecraft:lit_redstone_ore:0"] = false,
	["minecraft:lapis_ore:0"] = false,
	["minecraft:emerald_ore:0"] = false,
	["minecraft:quartz_ore:0"] = false,
	["biomsoplenty:biome_block:0"] = false,
	["ic2:resource:1"] = false,
	["ic2:resource:2"] = false,
	["ic2:resource:3"] = false,
	["ic2:resource:4"] = false,
	["biomsoplenty:gem_ore:0"] = false,
	["biomsoplenty:gem_ore:1"] = false,
	["biomsoplenty:gem_ore:2"] = false,
	["biomsoplenty:gem_ore:3"] = false,
	["biomsoplenty:gem_ore:4"] = false,
	["biomsoplenty:gem_ore:5"] = false,
	["biomsoplenty:gem_ore:6"] = false,
	["biomsoplenty:gem_ore:7"] = false,
}

function ChainMine.isOre (success, dat)
	if (not success) then
		return false
	end
	local oreStr = dat.name..":"..dat.metadata
	if (oreList[oreStr] == nil) then
		return false
	end

	-- don't consider valuable ore
	return (not oreList[oreStr])
end

function ChainMine.chainMine()
	if (ChainMine.isOre(turtle.inspectUp())) then
		AdvancedTurtle.digUp(15)
		ChainMine.chainMine()
		AdvancedTurtle.down()
	end
	if (ChainMine.isOre(turtle.inspectDown())) then
		AdvancedTurtle.digDown(15)
		ChainMine.chainMine()
		AdvancedTurtle.up()
	end
	if (ChainMine.isOre(turtle.inspect())) then
		AdvancedTurtle.digForward(15)
		ChainMine.chainMine()
		AdvancedTurtle.back()
	end
	AdvancedTurtle.turnLeft()
	if (ChainMine.isOre(turtle.inspect())) then
		AdvancedTurtle.digForward(15)
		ChainMine.chainMine()
		AdvancedTurtle.back()
	end
	AdvancedTurtle.turnLeft()
	if (ChainMine.isOre(turtle.inspect())) then
		AdvancedTurtle.digForward(15)
		ChainMine.chainMine()
		AdvancedTurtle.back()
	end
	AdvancedTurtle.turnLeft()
	if (ChainMine.isOre(turtle.inspect())) then
		AdvancedTurtle.digForward(15)
		ChainMine.chainMine()
		AdvancedTurtle.back()
	end
	AdvancedTurtle.turnLeft()
end

return ChainMine
