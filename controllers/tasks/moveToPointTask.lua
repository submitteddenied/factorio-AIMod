require 'task'
require 'util'

local accuracy = 0.15
local log = Logger.makeLogger("MoveToPointTask");
MoveToPointTask = Task:new()

function MoveToPointTask:achieved (args)
  local player = args.player;
  local maxDistance = (2 * (accuracy^2))^0.5
  return util.distance(player.position, {x=self.x, y=self.y}) < maxDistance
end

function MoveToPointTask:getBearing(player)
  -- determine quadrant
  local dX = player.position.x - self.x;
  local dY = player.position.y - self.y;
  local theta = 0;
  local opp;
  local adj;

  if(dX > 0 and dY >= 0) then -- top left
    opp = dY;
    adj = dX;
    theta = math.deg(math.atan(dY / dX));
    return theta + 270;
  elseif(dX < 0 and dY >= 0) then -- top right
    theta = math.deg(math.atan(-dX / dY));
    return theta;
  elseif(dX <= 0 and dY < 0) then -- bottom right
    theta = math.deg(math.atan(-dY / -dX));
    return theta + 90;
  elseif(dX >= 0 and dY < 0) then -- bottom left
    theta = math.deg(math.atan(dX / -dY));
    return theta + 180;
  end
  log("Didn't match any quadrants?!", "WARN");

  return theta; --north ¯\_(ツ)_/¯
end

function MoveToPointTask:getDirection(bearing)
  if(bearing < 22.5) then
    return "north"
  end
  local bucket_dir = math.floor((bearing - 22.5) / 45);
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
  local direction = self:getDirection(bearing);
  log("Bearing: " .. bearing .. " -> " .. direction, "DEBUG");

  player.walking_state = {walking = true, direction = defines.direction[direction]}
end
