require 'resource_source';

require 'controllers/tasks/moveToPointTask'
require 'controllers/tasks/mineResourceTask'

GroundResourceSource = ResourceSource:new();

function GroundResourceSource:compute_types()
  self.types = {
    {type=self.entity.name}
  };
end

-- {type=type, qty=#, player=player, machine=GoalMachine}
function GroundResourceSource:gather(opts)
  opts.machine:pushStart({
    MoveToPointTask:new(self.entity.position),
    MineResourceTask:new{target=self.entity, qty=opts.qty}
  });
end
