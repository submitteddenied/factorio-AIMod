require 'task'
require 'util'

PlaceBuildingTask = Task:new()

function PlaceBuildingTask:achieved (args)
  local player = args.player;
  if(self.placed) then
    player.set_goal_description(""); --clear the goal
    return true;
  else
    return false;
  end
end

function PlaceBuildingTask:tick (args)
  local player = args.player;

  local entities = player.surface.find_entities_filtered{position=self.position}
  self.placed = false;
  for i, entity in pairs(entities) do
    --TODO verify that there's space to place the building and possibly clear out trees etc
    if(entity.prototype.name == self.type and entity.direction == self.direction) then
      self.placed = true;
    end
  end
  self.started = self.started or false;
  if(not self.placed) then
    --TODO AI place the building
  end

  self.started = true;
end
