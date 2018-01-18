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

BurnerToBurnerModule = BaseModule:new{
  name="BurnerToBurner",
  resource="coal",
  geometry={
    {position={x=0, y=0}, resource="coal"},
    {position={x=0, y=1}, resource="coal"},
    {position={x=1, y=0}, resource="coal"},
    {position={x=1, y=1}, resource="coal"},
    {position={x=2, y=0}, resource="coal"},
    {position={x=2, y=1}, resource="coal"},
    {position={x=3, y=0}, resource="coal"},
    {position={x=3, y=1}, resource="coal"}
  },
  buildings={
    {type="burner-mining-drill", position={x=0, y=0}, direction=defines.direction.east},
    {type="burner-mining-drill", position={x=2, y=0}}
  },
  inputs={
    {building=1, type="coal", slot="fuel", ongoing=false}
  },
  outputs={
    {building=1, type="coal"},
    {building=2, type="coal"}
  }
};
