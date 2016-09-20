require 'task'
require 'util'

PlayerPlaceBuildingTask = Task:new()

function PlayerPlaceBuildingTask:achieved (args)
  local player = args.player;
  if(self.placed) then
    player.set_goal_description(""); --clear the goal
    return true;
  else
    return false;
  end
end

function PlayerPlaceBuildingTask:tick (args)
  local player = args.player;

  local entities = player.surface.find_entities_filtered{position=self.position}
  self.placed = false;
  for i, entity in pairs(entities) do
    if(entity.prototype.name == self.type and entity.direction == self.direction) then
      self.placed = true;
    end
  end
  self.started = self.started or false;
  if(not self.placed) then
    local player_pos = "(" .. player.character.position.x .. ", " .. player.character.position.y .. ")"
    player.set_goal_description("Please put a " .. self.type .. " at " .. self.position.x .. ", " .. self.position.y .. " " .. player_pos, self.started);
  end

  self.started = true;
end
