require 'task'
require 'util'

PlayerGatherResourcesTask = Task:new()

function PlayerGatherResourcesTask:achieved (args)
  local player = args.player;
  local completed = player.get_inventory(defines.inventory.player_main).get_item_count(self.type) >= self.qty;
  if(completed) then
    player.set_goal_description(""); --clear the goal
  end
  return completed;
end

function PlayerGatherResourcesTask:tick (args)
  local player = args.player;
  local still_to_mine = self.qty - player.get_inventory(defines.inventory.player_main).get_item_count(self.type);
  self.started = self.started or false;
  if(still_to_mine > 0) then
    player.set_goal_description("Please go and gather " .. still_to_mine .. " " .. self.type, self.started);
  end

  self.started = true;
end
