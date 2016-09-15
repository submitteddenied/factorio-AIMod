require 'task'
require 'util'

local accuracy = 0.2
MoveToPointTask = Task:new()

function MoveToPointTask:achieved (args)
  local player = args.player;
  local maxDistance = (2 * (accuracy^2))^0.5
  return util.distance(player.position, {x=self.x, y=self.y}) < maxDistance
end

function MoveToPointTask:tick (args)
  local player = args.player;
  local xDir = ""
  local yDir = ""
  if(player.position.x - accuracy > self.x) then
    xDir = "west"
  elseif(player.position.x + accuracy < self.x) then
    xDir = "east"
  end

  if(player.position.y - accuracy > self.y) then
    yDir = "north"
  elseif(player.position.y + accuracy < self.y) then
    yDir = "south"
  end

  if(yDir .. xDir ~= "") then
    --player.print("Walking " .. yDir .. xDir)
    player.walking_state = {walking = true, direction = defines.direction[yDir .. xDir]}
  end
end
