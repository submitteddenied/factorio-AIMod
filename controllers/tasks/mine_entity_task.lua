require 'task'
require 'util'

require 'controllers/tasks/moveToPointTask'

local range = 4; -- Approx player reach range
MineEntityTask = Task:new()

function MineEntityTask:achieved (args)
  return not self.entity.valid;
end

function MineEntityTask:tick (args)
  local player = args.player;
  local reachable = player.can_reach_entity(self.entity)
  if(reachable) then
    local y = self.entity.position.y + self.entity.prototype.collision_box.left_top.y;
    player.update_selected_entity({x=self.entity.position.x, y=y});
    player.mining_state = { mining = true, position = {x=self.entity.position.x, y=y} }
  else
    args.machine:pushSingle(MoveToPointTask:new{x=self.entity.position.x, y=self.entity.position.y});
  end
end
