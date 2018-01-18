--[[
Base Modules:
 - Geometry
    - List of tiles and types
 - Buildings and their positions and directions
 - Inputs and Outputs
    - consumers of fuel/recipe ingredients
    - providers of some end product
--]]
require 'base_module'

BurnerToFurnaceModule = BaseModule:new{
  name="BurnerToFurnace",
  resource="iron-ore",
  geometry={
    {position={x=0, y=0}, resource="iron-ore"},
    {position={x=0, y=1}, resource="iron-ore"},
    {position={x=1, y=0}, resource="iron-ore"},
    {position={x=1, y=1}, resource="iron-ore"},
    {position={x=2, y=0}},
    {position={x=2, y=1}},
    {position={x=3, y=0}},
    {position={x=3, y=1}}
  },
  buildings={
    {type="burner-mining-drill", position={x=0, y=0}, direction=defines.direction.east},
    {type="stone-furnace", position={x=2, y=0}}
  },
  inputs={
    {building=1, type="coal", slot="fuel", ongoing=true},
    {building=2, type="coal", slot="fuel", ongoing=true}
  },
  outputs={
    {building=2, type="iron-plate"}
  }
};
