require 'task'
require 'util'

require 'util/inventories'
require 'moveToPointTask'
require 'mineResourceTask'

--[[
  GatherResourceTask
  Causes the player to do whatever they need to do to get a given resource in a
  particular quantity
   - type: string; The thing the player needs
   - qty: number; the amount of the thing
]]
GatherResourceTask = Task:new{goalSet=false}
local range = 1000;

function GatherResourceTask:achieved (args)
  --does the player have at least self.qty of self.type in their inventory?
  local inv_count = Inventories.total_craftable_count(args.player, self.type);
  return inv_count < self.qty;
end

function GatherResourceTask:tick (args)
  -- should use the player's resource manager to do the gathering!
  local player = args.player;
  global.resource_managers[player.index]:get_resources(args.player, self.type, self.qty);
end
