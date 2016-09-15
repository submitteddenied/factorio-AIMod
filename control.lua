require 'util'
require 'dataloader'
require 'controllers/tasks/gatherResourcesTask'
require 'controllers/tasks/craftRecipeTask'
require 'controllers/goalMachine'

local done = false;
local goalMachine = GoalMachine:new()

--craft iron axe
goalMachine:pushStart({
  CraftRecipeTask:new{recipe = "iron-axe", qty = 2},
  GatherResourceTask:new{type = "iron-ore", qty = 10},
  GatherResourceTask:new{type = "coal", qty = 10},
  GatherResourceTask:new{type = "stone", qty = 10},
  GatherResourceTask:new{type = "copper-ore", qty = 10}
})

-- start 229.7, 146.1

script.on_event(defines.events.on_tick, function(event)
  local player = game.players[1];

  if(not goalMachine:achieved{ player=player }) then
    goalMachine:tick{ player=player }
  elseif(not done) then
    done = true
    player.print("Completed goals")
  end
end)
