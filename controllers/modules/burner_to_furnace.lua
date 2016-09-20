--[[
Base Modules:
 - Geometry
    - List of tiles and types
 - Buildings and their positions and directions
 - Inputs and Outputs
    - consumers of fuel/recipe ingredients
    - providers of some end product
--]]

BurnerToFurnaceModule = {
  name="BurnerToFurnace",
  resource="coal",
  geometry={
    {position={x=0, y=0}, resource="coal"},
    {position={x=0, y=1}, resource="coal"},
    {position={x=1, y=0}, resource="coal"},
    {position={x=1, y=1}, resource="coal"},
    {position={x=2, y=0}},
    {position={x=2, y=1}},
    {position={x=3, y=0}},
    {position={x=3, y=1}}
  },
  buildings={
    {type="burner-mining-drill", position={x=1, y=1}, direction=defines.direction.east},
    {type="stone-furnace", position={x=3, y=1}}
  },
  inputs={
    {building=1, type="coal", ongoing=true},
    {building=2, type="coal", ongoing=true},
    {building=2, type="iron-ore", ongoing=true}
  },
  outputs={
    {building=2, type="iron-plate"}
  }
};
