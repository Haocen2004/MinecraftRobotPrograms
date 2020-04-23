local ChainMine = {}
local AdvancedTurtle = require("/MinecraftRobotPrograms/Miner/AdvancedTurtle")

local oreList = {
	["minecraft:coal_ore"] = false,
	["minecraft:iron_ore"] = false,
	["minecraft:gold_ore"] = false,
	["minecraft:diamond_ore"] = true,
	["minecraft:redstone_ore:0"] = false,
	["minecraft:redstone_ore"] = false,
	["minecraft:lapis_ore"] = false,
	["minecraft:emerald_ore"] = false,
	["mekanism:osmium_ore"] = false,
	["mekanism:copper_ore"] = false,
	["mekanism:tin_ore"] = false,
	["silents_mechanisms:copper_ore"] = false,
	["silents_mechanisms:tin_ore"] = false,
	["silents_mechanisms:silver_ore"] = false,
	["silents_mechanisms:lead_ore"] = false,
	["silents_mechanisms:nickel_ore"] = false,
	["silents_mechanisms:platinum_ore"] = false,
	["silents_mechanisms:zinc_ore"] = false,
	["silents_mechanisms:bismuth_ore"] = false,
	["silents_mechanisms:bauxite_ore"] = false,
	["silents_mechanisms:uranium_ore"] = false,
}

function ChainMine.isOre (success, dat)
	if (not success) then
		return false
	end
	local oreStr = dat.name
	if (oreList[oreStr] == nil) then
		return false
	end

	if (oreList[oreStr]) then
		local f = fs.open("ValuableOres.dat", "a")
		f.write(dat.name)
		f.write("@")
		local pos = AdvancedTurtle.getAbsolute()
		f.write("("..pos.x..", "..pos.y..", "..pos.z..")\n")
		f.close()
	end

	return (not oreList[oreStr])
end

function ChainMine.chainMine()
	if (ChainMine.isOre(turtle.inspectUp())) then
		AdvancedTurtle.forceUp(15)
		ChainMine.chainMine()
		AdvancedTurtle.forceDown(15)
	end
	if (ChainMine.isOre(turtle.inspectDown())) then
		AdvancedTurtle.forceDown(15)
		ChainMine.chainMine()
		AdvancedTurtle.forceUp(15)
	end
	if (ChainMine.isOre(turtle.inspect())) then
		AdvancedTurtle.forceForward(15)
		ChainMine.chainMine()
		AdvancedTurtle.forceBack(15)
	end
	AdvancedTurtle.turnLeft()
	if (ChainMine.isOre(turtle.inspect())) then
		AdvancedTurtle.forceForward(15)
		ChainMine.chainMine()
		AdvancedTurtle.forceBack(15)
	end
	AdvancedTurtle.turnLeft()
	if (ChainMine.isOre(turtle.inspect())) then
		AdvancedTurtle.forceForward(15)
		ChainMine.chainMine()
		AdvancedTurtle.forceBack(15)
	end
	AdvancedTurtle.turnLeft()
	if (ChainMine.isOre(turtle.inspect())) then
		AdvancedTurtle.forceForward(15)
		ChainMine.chainMine()
		AdvancedTurtle.forceBack(15)
	end
	AdvancedTurtle.turnLeft()
end

return ChainMine
