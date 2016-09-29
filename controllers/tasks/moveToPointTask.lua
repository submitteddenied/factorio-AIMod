require 'task'
require 'util'
require('util/passable');

local accuracy = 1;
local num_projections = 6;
local max_turn_rate = 10; -- degrees
local collision_turn_rate = max_turn_rate * 2;
local feeler_width = 0.8;
local debug = false;
local sin = function (x) return math.sin(math.rad(x)) end
local cos = function (x) return math.cos(math.rad(x)) end
local log = Logger.makeLogger("MoveToPointTask");
MoveToPointTask = Task:new()

local function sign(x)
   return (x < 0 and -1) or 1
end

function MoveToPointTask:achieved (args)
  local player = args.player;
  local maxDistance = (2 * (accuracy^2))^0.5
  --TODO if (debug) delete the feeler entities!
  return util.distance(player.position, {x=self.x, y=self.y}) < maxDistance
end

function MoveToPointTask:getBearingToTarget(player, target)
  target = target or {x=self.x, y=self.y};
  -- determine quadrant
  local dX = target.x - player.position.x;
  local dY = target.y - player.position.y;
  local theta = 0;
  local opp;
  local adj;

  if(dY <= 0 and dX < 0) then -- top left
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

function MoveToPointTask:multiplyBearing(bearing, i)
  local turn_amount = collision_turn_rate - math.abs(bearing);
  if(turn_amount < 0) then
    turn_amount = collision_turn_rate;
  end
  return sign(bearing) * (1/i) * turn_amount;
end

function MoveToPointTask:clampBearing()
  self.current_bearing = self.current_bearing % 360;
end

function MoveToPointTask:tick (args)
  local player = args.player;
  local target_bearing = self:getBearingToTarget(player);
  if(not self.current_bearing) then
    self.current_bearing = target_bearing;
  end
  local turn_amount = target_bearing - self.current_bearing;
  self.current_bearing = self.current_bearing + (sign(turn_amount) * math.min(max_turn_rate, math.abs(turn_amount)));

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
  local total_steering_force = 0;
  for i, feeler in pairs(self.feelers) do
    local new_position = {x=player.position.x, y=player.position.y};
    new_position.x = new_position.x + ((i - 1) * feeler_width * x_ratio);
    new_position.y = new_position.y + ((i - 1) * feeler_width * y_ratio);
    if(not has_collision) then
      local half_feeler = (feeler_width/2);
      local collision_area = {left_top={x=new_position.x - half_feeler, y=new_position.y - half_feeler},
                              right_bottom={x=new_position.x + half_feeler, y=new_position.y + half_feeler}};
      local tile = player.surface.get_tile(new_position.x + half_feeler, new_position.y + half_feeler);
      if(not isTilePassable(player, tile)) then
        has_collision = true;
        local tile_position = {x=tile.position.x + 0.5, y=tile.position.y + 0.5};
        local tile_bearing = self:getBearingToTarget(player, tile_position);
        local relative_bearing = self.current_bearing - tile_bearing;
        log("Terrain collision detected at (" .. tile_position.x .. ", ".. tile_position.y ..") -> " .. relative_bearing, "DEBUG");
        --self.current_bearing = self.current_bearing - relative_bearing;
      end
      --tree,stone-rock,small-rock
      for z, type in pairs({{"type", "tree"}, {"name", "stone-rock"}, {"name", "small-rock"}}) do
        local params = {area=collision_area}
        params[type[1]] = type[2];
        local entities = player.surface.find_entities_filtered(params);
        if(#entities > 0) then
          --has_collision = true;
          local closest = entities[1];
          local closest_distance = util.distance(player.position, closest.position);
          for j, entity in pairs(entities) do
            local entity_bearing = self:getBearingToTarget(player, entity.position);
            local relative_bearing = entity_bearing - self.current_bearing;
            log("Entity collision detected at (" .. entity.position.x .. ", ".. entity.position.y ..") -> " .. relative_bearing, "INFO");
            total_steering_force = total_steering_force + self:multiplyBearing(relative_bearing, i);
          end
        end
      end
    end
    if(debug) then
      feeler.teleport(new_position);
    end
  end
  self.current_bearing = self.current_bearing - total_steering_force;
  if(true or total_steering_force > 0) then
    log("Applying steering force of " .. total_steering_force, "INFO");
  end
  self:clampBearing();
  local direction = self:getDirection(self.current_bearing);
  if(direction) then
    log("Bearing: " .. self.current_bearing .. " -> " .. direction, "DEBUG");

    player.walking_state = {walking = true, direction = defines.direction[direction]}
  else
    log("Bearing: " .. self.current_bearing .. " -> nil", "WARN");
  end
end
