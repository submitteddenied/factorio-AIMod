require 'task'
require 'util'
require 'moveToPointTask'
require 'mineResourceTask'

GatherResourceTask = Task:new{goalSet=false}
local range = 1000;

function GatherResourceTask:achieved (args)
  return self.goalSet;
end

function GatherResourceTask:tick (args)
  local player = args.player;
  player.print("Finding some " .. self.type .. " to go gather")
  local resources = player.surface.find_entities_filtered{area = 
    {{player.position.x - range, player.position.y - range}, {player.position.x + range, player.position.y + range}}, 
    name= self.type}

  local closest;
  local d = range;
  for i, resource in ipairs(resources) do
    if(util.distance(resource.position, player.position) < d) then
      closest = resource;
      d = util.distance(resource.position, player.position);
    end
  end

  if(closest) then
    args.machine:pushNext({MoveToPointTask:new(closest.position), MineResourceTask:new{type = self.type, qty = self.qty}})

    self.goalSet = true;
  end
end
