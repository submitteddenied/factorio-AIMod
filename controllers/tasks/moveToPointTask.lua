require 'task'
require 'util'

local accuracy = 0.15
MoveToPointTask = Task:new()

function MoveToPointTask:achieved (args)
  local player = args.player;
  local maxDistance = (2 * (accuracy^2))^0.5
  return util.distance(player.position, {x=self.x, y=self.y}) < maxDistance
end

function MoveToPointTask:getBearing(player)
  local dX = self.x - player.position.x;
  local dY = (-self.y) - (-player.position.y);

  return math.deg(math.atan(dX, dY));
end

function MoveToPointTask:getDirection(bearing)
  if(bearing < 22.5) then
    return "north"
  end
  local bucket_dir = (bearing - 22.5) % 45
  local dir_list = {
    "northeast",
    "east",
    "southeast",
    "south",
    "southwest",
    "west",
    "northwest",
    "north"
  }
  return dir_list[bucket_dir + 1]
end

function MoveToPointTask:tick (args)
  local player = args.player;
  local bearing = self:getBearing(player);
  player.print(bearing)
  local direction = self:getDirection(bearing);

  player.walking_state = {walking = true, direction = defines.direction[direction]}
end
