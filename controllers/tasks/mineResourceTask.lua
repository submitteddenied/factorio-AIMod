require 'task'
require 'util'

local range = 4; -- Approx player reach range
MineResourceTask = Task:new()

function MineResourceTask:achieved (args)
  local player = args.player;
  return player.get_inventory(defines.inventory.player_main).get_item_count(self.type) >= self.qty
end

function MineResourceTask:tick (args)
  local player = args.player;
  if(not self.target) then
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

    self.target = closest;
  end

  if(self.target) then
    local reachable = player.can_reach_entity(self.target)
    if(reachable) then
      player.update_selected_entity(self.target.position)
      player.mining_state = { mining = true, position = self.target.position }
    else
      player.print("I can't reach any " .. self.type)
    end
  else
    player.print("I can't see any " .. self.type)
  end
end
