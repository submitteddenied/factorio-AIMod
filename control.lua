require 'util'
require 'dataloader'
require 'util/logger'
require 'controllers/tasks/gatherResourcesTask'
require 'controllers/tasks/craftRecipeTask'
require 'controllers/tasks/moveToPointTask'
require 'controllers/tasks/pathfindToPointTask'
require 'controllers/goalMachine'

local done = false;
local once = true;
local goalMachine = GoalMachine:new()

--craft iron axe
goalMachine:pushStart({
  CraftRecipeTask:new{recipe = "iron-axe", qty = 2},
  MoveToPointTask:new{x = 50, y = 20 }
  -- GatherResourceTask:new{type = "iron-ore", qty = 10},
  -- GatherResourceTask:new{type = "coal", qty = 10},
  -- GatherResourceTask:new{type = "stone", qty = 10},
  -- GatherResourceTask:new{type = "copper-ore", qty = 10}
  --PathfindToPointTask:new{x = 50, y = 20}
})

-- start 229.7, 146.1

script.on_event(defines.events.on_tick, function(event)
  local player = game.players[1];

  if(once) then
    once = false;
    Logger.log("player start position " .. player.position.x .. ", " .. player.position.y)
  end

  if(not goalMachine:achieved{ player=player }) then
    goalMachine:tick{ player=player }
  elseif(not done) then
    done = true
    player.print("Completed goals")
  end
end)

--[[
>>>AAANABQAAAADAwYAAAAEAAAAY29hbAMDAwoAAABjb3BwZXItb3Jl
AwMDCQAAAGNydWRlLW9pbAMDAwoAAABlbmVteS1iYXNlAwMDCAAAAGl
yb24tb3JlAwMDBQAAAHN0b25lAwMDMbU1VICEHgCAhB4AAwFa9nHa<<
<
--]]
