require 'task'
require 'util'
require 'util/logger'
require 'controllers/tasks/playerPlaceBuildingTask'

BuildModuleTask = Task:new()
local log = Logger.makeLogger("BuildModuleTask");

function BuildModuleTask:achieved (args)
  return self.goal_set;
end

local range = 100;
local impassibleTiles = {
  "out-of-map",
  "deepwater",
  "deepwater-green",
  "water",
  "water-green"
};

function BuildModuleTask:canBuildAtPosition(player, position)
  --for each item in the geometry, verify
  --  a) it's not water (unless it should be)
  --  b) it has the resource it needs (if it need one)
  for i, item in pairs(self.module.geometry) do
    local offset = item.position;
    local offsetPosition = {x=position.x + offset.x, y=position.y + offset.y};
    local tile = player.surface.get_tile(offsetPosition.x, offsetPosition.y);
    for i, tileName in pairs(impassibleTiles) do
      if(tile.prototype.name == tileName) then
        if(i == 1) then return false end
        if(item.tile and item.tile == "water") then
          --continue
        else
          return false;
        end
      end
    end
    if(item.resource ~= nil) then
      local entities = player.surface.find_entities_filtered{position=offsetPosition}
      local foundResource = false;
      for i, entity in pairs(entities) do
        if(entity.prototype.name == item.resource) then
          foundResource = true;
          break;
        end
      end
      if(not foundResource) then
        return false;
      end
    end
  end
  return true;
end

function BuildModuleTask:tick (args)
  local player = args.player;
  if(self.module.resource ~= nil) then
    local resources = player.surface.find_entities_filtered{area =
      {{player.position.x - range, player.position.y - range}, {player.position.x + range, player.position.y + range}},
      name=self.module.resource}
    for i, resource in pairs(resources) do
      local position = resource.position;
      if(self:canBuildAtPosition(player, position)) then
        --lets do it!
        log("Building " .. self.module.name .. " at " .. position.x .. ", " .. position.y, "INFO");
        local tasks = {};
        for i, building in pairs(self.module.buildings) do
          local building_position = {x=position.x + building.position.x, y=position.y + building.position.y};
          tasks[#tasks + 1] = PlayerPlaceBuildingTask:new{type=building.type,
                                                      position=building_position,
                                                      direction=building.direction or defines.direction.north}

        end
        args.machine:pushNext(tasks);
        self.goal_set = true;
        return
      end
    end
    log("Cannot build " .. self.module.name, "WARN");
  end
end
