EnumFacing = {}

mt = {__newindex = function (t, k, v)
	error("enum cannot be changed")
end}

EnumFacing.east = {}
EnumFacing.south = {}
EnumFacing.west = {}
EnumFacing.north = {}
EnumFacing.east.d=vector.new(1,0,0)
EnumFacing.east.l=EnumFacing.north
EnumFacing.east.r=EnumFacing.south
EnumFacing.east.name="east"
EnumFacing.south.d=vector.new(0,0,1)
EnumFacing.south.l=EnumFacing.east
EnumFacing.south.r=EnumFacing.west
EnumFacing.south.name="south"
EnumFacing.west.d=vector.new(-1,0,0)
EnumFacing.west.l=EnumFacing.south
EnumFacing.west.r=EnumFacing.north
EnumFacing.west.name="west"
EnumFacing.north.d=vector.new(0,0,-1)
EnumFacing.north.l=EnumFacing.west
EnumFacing.north.r=EnumFacing.east
EnumFacing.north.name="north"
setmetatable(EnumFacing.east, mt)
setmetatable(EnumFacing.south, mt)
setmetatable(EnumFacing.west, mt)
setmetatable(EnumFacing.north, mt)
setmetatable(EnumFacing, mt)

return EnumFacing