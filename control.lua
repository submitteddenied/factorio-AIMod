require 'util'
require 'dataloader'
require 'util/logger'
require 'controllers/tasks/gatherResourcesTask'
require 'controllers/tasks/playerGatherResourcesTask'
require 'controllers/tasks/playerPlaceBuildingTask'
require 'controllers/tasks/craftRecipeTask'
require 'controllers/tasks/moveToPointTask'
require 'controllers/tasks/pathfindToPointTask'
require 'controllers/tasks/build_module_task'
require 'controllers/modules/burner_to_furnace'
require 'controllers/modules/burner_to_burner'
require 'controllers/managers/tool_manager'
require 'controllers/goalMachine'

local done = false;
local once = true;
local goalMachine = GoalMachine:new()
--Logger.LEVEL = "DEBUG";

goalMachine:addManager(ToolManager:new());
--craft iron axe
goalMachine:pushStart({
  BuildModuleTask:new{module=BurnerToFurnaceModule},
  BuildModuleTask:new{module=BurnerToBurnerModule}

})

-- start 229.7, 146.1

script.on_event(defines.events.on_tick, function(event)
  local player = game.players[1];

  if(once) then
    once = false;
    Logger.log("player start position " .. player.position.x .. ", " .. player.position.y);
  end

  if(not goalMachine:achieved{ player=player }) then
    goalMachine:tick{ player=player }
  elseif(not done) then
    done = true
    player.print("Completed goals")
  end
end)

-- peninsula
--[[
>>>AAANABQAAAADAwYAAAAEAAAAY29hbAMDAwoAAABjb3BwZXItb3Jl
AwMDCQAAAGNydWRlLW9pbAMDAwoAAABlbmVteS1iYXNlAwMDCAAAAGl
yb24tb3JlAwMDBQAAAHN0b25lAwMDMbU1VICEHgCAhB4AAwFa9nHa<<
<
--]]

--peninsula with s-bend
--[[
>>>AAANABQAAAADAwYAAAAEAAAAY29hbAMDAwoAAABjb3BwZXItb3Jl
AwMDCQAAAGNydWRlLW9pbAMDAwoAAABlbmVteS1iYXNlAwMDCAAAAGl
yb24tb3JlAwMDBQAAAHN0b25lAwMDNqeYAYCEHgCAhB4AAwANu1Dz<<
<
--]]
