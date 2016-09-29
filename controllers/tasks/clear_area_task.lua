require 'task'
require 'util'

require 'controllers/tasks/mine_entity_task'

local range = 4; -- Approx player reach range
ClearAreaTask = Task:new()

function ClearAreaTask:achieved (args)
  return (self.entity_list ~= nil and #self.entity_list == 0)
end

function ClearAreaTask:toString()
  return "ClearAreaTask";
end

function ClearAreaTask:tick (args)
  local player = args.player;
  self.entity_list = player.surface.find_entities_filtered{area=self.area, type="tree"}
  table.sort(self.entity_list, function(a, b)
    return util.distance(player.position, a.position) < util.distance(player.position, b.position);
  end)
  if(#self.entity_list > 0) then
    args.machine:pushSingle(MineEntityTask:new{entity = self.entity_list[1]});
  end

end
