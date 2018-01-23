require 'util'
require 'dataloader'
require 'util/logger'
require 'controllers/tasks/gatherResourcesTask'
require 'controllers/tasks/playerGatherResourcesTask'
require 'controllers/tasks/playerPlaceBuildingTask'
require 'controllers/tasks/placeBuildingTask'
require 'controllers/tasks/craftRecipeTask'
require 'controllers/tasks/moveToPointTask'
require 'controllers/tasks/fuel_building_task'
require 'controllers/tasks/pathfindToPointTask'
require 'controllers/tasks/build_module_task'
require 'controllers/tasks/mine_entity_task'
require 'controllers/tasks/clear_area_task'
require 'controllers/tasks/build_building_task'
require 'controllers/modules/burner_to_furnace'
require 'controllers/modules/burner_to_burner'
require 'controllers/managers/tool_manager'
require 'controllers/managers/resource_manager'
require 'controllers/goalMachine'

local done = false;
local once = true;

global.resource_managers = {};
global.goal_machines = {};

-- start 229.7, 146.1
script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index];
  local resource_manager = ResourceManager:new();
  resource_manager:initialize(player);

  local goal_machine = GoalMachine:new();
  goal_machine:addManager(ToolManager:new());
  goal_machine:pushStart({
    BuildModuleTask:new{module=BurnerToFurnaceModule},
    BuildModuleTask:new{module=BurnerToBurnerModule },
    FuelBuildingTask:new{}

  });

  global.resource_managers[player.index] = resource_manager;
  global.goal_machines[player.index] = goal_machine;
end);

script.on_event(defines.events.on_tick, function(event)
  for i, machine in pairs(global.goal_machines) do
    local player = game.players[i];

    if(once) then
      Logger.log("player start position " .. player.position.x .. ", " .. player.position.y);
    end

    if(not machine:achieved{ player=player }) then
      machine:tick{ player=player }
    elseif(not done) then
      done = true
      player.print("Completed goals")
    end
  end

  if(once) then
    once = false;
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
