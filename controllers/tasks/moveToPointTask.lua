require 'task'
require 'util'
require('util/passable');

local accuracy = 0.15;
local num_projections = 5;
local max_turn_rate = 5; -- degrees
local feeler_width = 0.8;
local debug = true;
local sin = function (x) return math.sin(math.rad(x)) end
local cos = function (x) return math.cos(math.rad(x)) end
local log = Logger.makeLogger("MoveToPointTask");
MoveToPointTask = Task:new()

function MoveToPointTask:achieved (args)
  local player = args.player;
  local maxDistance = (2 * (accuracy^2))^0.5
  --TODO if (debug) delete the feeler entities!
  return util.distance(player.position, {x=self.x, y=self.y}) < maxDistance
end

function MoveToPointTask:getBearingToTarget(player)
  -- determine quadrant
  local dX = self.x - player.position.x;
  local dY = self.y - player.position.y;
  local theta = 0;
  local opp;
  local adj;

  if(dY <= 0 and dx < 0) then -- top left
    opp = dY;
    adj = dX;
    theta = math.deg(math.atan(-dY / -dX));
    return theta + 270;
  elseif(dX >= 0 and dY < 0) then -- top right
    theta = math.deg(math.atan(dX / -dY));
    return theta;
  elseif(dX > 0 and dY >= 0) then -- bottom right
    theta = math.deg(math.atan(dY / dX));
    return theta + 90;
  elseif(dX <= 0 and dY > 0) then -- bottom left
    theta = math.deg(math.atan(-dX / dY));
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
  local target_bearing = self:getBearingToTarget(player);
  if(not self.current_bearing) then
    self.current_bearing = 0;
  end
  if(not self.feelers) then
    self.feelers = {};
    for i=1, num_projections do
      if(debug) then
        local feeler = player.surface.create_entity{name="pathing-feeler", position=player.position};
        self.feelers[#self.feelers + 1] = feeler;
      else
        self.feelers[#self.feelers + 1] = true;
      end
    end
  end
  local x_ratio = 0;
  local y_ratio = 0;
  if(self.current_bearing <= 90) then
    x_ratio = sin(self.current_bearing);
    y_ratio = -cos(self.current_bearing);
  elseif(self.current_bearing <= 180) then
    x_ratio = sin(180 - self.current_bearing);
    y_ratio = cos(180 - self.current_bearing);
  elseif(self.current_bearing <= 270) then
    x_ratio =  -sin(self.current_bearing - 180);
    y_ratio = cos(self.current_bearing - 180);
  elseif(self.current_bearing <= 360) then
    x_ratio =  -sin(360 - self.current_bearing);
    y_ratio = -cos(360 - self.current_bearing);
  end
  local has_collision = false;
  for i, feeler in pairs(self.feelers) do
    local new_position = {x=player.position.x, y=player.position.y};
    new_position.x = new_position.x + (i * feeler_width * x_ratio);
    new_position.y = new_position.y + (i * feeler_width * y_ratio);
    if(not has_collision) then
      local collision_area = {left_top={x=new_position.x - (feeler_width/2), y=new_position.y - (feeler_width/2)},
                              right_bottom={x=new_position.x + (feeler_width/2), y=new_position.y + (feeler_width/2)}};
      local tile = player.surface.get_tile(new_position.x, new_position.y);
      if(not isTilePassable(player, tile)) then
        has_collision = true;
        local tile_position = {x=tile.position.x + 0.5, y=tile.position.y + 0.5};

      end
    end
    if(debug) then
      feeler.teleport(new_position);
    end
  end
  --TODO: Handle going from 359.9deg -> 0deg
  if(self.current_bearing < target_bearing) then
    self.current_bearing = self.current_bearing + math.min(max_turn_rate, target_bearing - self.current_bearing);
  elseif(self.current_bearing > target_bearing) then
    self.current_bearing = self.current_bearing - math.min(max_turn_rate, self.current_bearing - target_bearing);
  end
  local direction = self:getDirection(self.current_bearing);
  if(direction) then
    log("Bearing: " .. self.current_bearing .. " -> " .. direction, "DEBUG");

    player.walking_state = {walking = true, direction = defines.direction[direction]}
  else
    log("Bearing: " .. self.current_bearing .. " -> nil", "WARN");
  end
end
