require 'util/logger'

require 'ground_resource_source'
require 'tree_resource_source'
require 'craft_resource_source'

ResourceManager = {}
function ResourceManager:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.sources = {};
  return o
end

local log = Logger.makeLogger("ResourceManager");

local range = 100;
local starting_resources = {
  "iron-ore",
  "copper-ore",
  "coal",
  "stone"
}
function ResourceManager:initialize(player)
  local search_area = {{player.position.x - range, player.position.y - range}, {player.position.x + range, player.position.y + range}};
  for source, resource in ipairs(starting_resources) do
    local entities = player.surface.find_entities_filtered{area=search_area, name=source}

    for i, entity in ipairs(entities) do
      self.sources[#self.sources + 1] = GroundResourceSource:new{entity=entity};
    end
  end
  local trees = player.surface.find_entities_filtered{area=search_area, type="tree"}
  for i, tree in ipairs(trees) do
    self.sources[#self.sources + 1] = TreeResourceSource:new{entity=tree};
  end
end

function ResourceManager:best_resource_source(player, type)
  local best_source = nil;
  for i, source in ipairs(self.sources) do
    if(source:provides_type(type)) then
      if(best_source and source.fitness > best_source.fitness) then
        best_source = source;
      end
    end
  end
  --TODO: We don't have a source for that. fallback?
  if(not best_source) then
    -- can we craft it?
    local craft_source = CraftResourceSource:new{player=player, type=type}
    if(craft_source:provides_type(type)) then
      return craft_source;
    else
      log("No known way to get " .. type, "ERROR");
    end
  else
    return best_source;
  end
end

function ResourceManager:get_resources(player, type, max_qty)
  local source = self:best_resource_source(player, type);
  if(source) then
    source:gather{qty=max_qty, player=player, machine=global.goal_machines[player.index]}
  end
end
