require 'task'
require 'util'
require 'util/pathfinding_fringe'
require 'util/logger'
local log = Logger.makeLogger("PathfindToPointTask");

PathfindToPointTask = Task:new{pathFound = false}

local heuristicCoeff = 1;
local costCoeff = 1;
local playerMarginCoeff = 1.05;

local impassibleTiles = {
  "out-of-map",
  "deepwater",
  "deepwater-green",
  "water",
  "water-green"
};

function PathfindToPointTask:achieved(args)
  return self.pathFound;
end



function PathfindToPointTask:isPassable(player, tile)
  local onPlayerLayer = false;
  for i, tileType in ipairs(impassibleTiles) do
    if(tile.prototype.name == tileType) then
      Logger.log("Found impassible tile " .. tileType);
      onPlayerLayer = true
    end
  end
  if(onPlayerLayer) then
    return false;
  end
  return true;
end

function PathfindToPointTask:getBoundingBox(player)
  return {
    left_top={x=math.min(player.position.x, self.x), y=math.min(player.position.y, self.y)},
    right_bottom={x=math.max(player.position.x, self.x), y=math.max(player.position.y, self.y)}
  };
end

function PathfindToPointTask:contains(arr, item)
  for i, other in pairs(arr) do
    if(other == item) then
      return true;
    end
  end
  return false;
end

function PathfindToPointTask:pointCollidesWithEntities(player, point, entities, excl)
  excl = excl or {};
  local player_margin = player.character.prototype.collision_box;
  local player_margins = {
    left_top={x=player_margin.left_top.x * playerMarginCoeff, y=player_margin.left_top.y * playerMarginCoeff},
    right_bottom={x=player_margin.right_bottom.x * playerMarginCoeff, y=player_margin.right_bottom.y * playerMarginCoeff}
  };
  for i, entity in pairs(entities) do
    if(not self:contains(excl, entity)) then
      local box = entity.prototype.collision_box;
      local hitbox = {
        left_top={x=entity.position.x + box.left_top.x + player_margins.left_top.x, y=entity.position.y + box.left_top.y + player_margins.left_top.y},
        right_bottom={x=entity.position.x + box.right_bottom.x + player_margins.right_bottom.x,y=entity.position.y + box.right_bottom.y + player_margins.right_bottom.y}
      }
      log("Does " .. point.x .. "," .. point.y .. " collide with (" .. hitbox.left_top.x .. ", " .. hitbox.left_top.y .. ") to (" .. hitbox.right_bottom.x .. ", " .. hitbox.right_bottom.y .. ")", "INFO")
      if(
          point.x > (hitbox.left_top.x) and
          point.x < (hitbox.right_bottom.x) and
          point.y > (hitbox.left_top.y) and
          point.y < (hitbox.right_bottom.y)
        ) then
        log("Point " .. point.x .. "," .. point.y .. " collides with (" .. hitbox.left_top.x .. ", " .. hitbox.left_top.y .. ") to (" .. hitbox.right_bottom.x .. ", " .. hitbox.right_bottom.y .. ")", "INFO")
        return true;
      end
    end
  end
  return false;
end

--returns list of positions that represent A* shortest path to self.x, self.y
function PathfindToPointTask:pathfind(player)
  --look at all entities between player and dest and find ones that the player
  -- will collide with.
  local nodes = {}
  local player_margin = player.character.prototype.collision_box;
  local search_area = self:getBoundingBox(player);
  log("Searching (" .. search_area.left_top.x .. ", " .. search_area.left_top.y .. ") to (" .. search_area.right_bottom.x .. ", " .. search_area.right_bottom.y .. ")", "INFO")
  local trees = player.surface.find_entities_filtered{area=search_area, type="tree"};
  for i, tree in pairs(trees) do
    local box = tree.prototype.collision_box;
    --top left
    local tL = {x=tree.position.x + box.left_top.x + (player_margin.left_top.x * playerMarginCoeff),
                         y=tree.position.y + box.left_top.y + (player_margin.left_top.y * playerMarginCoeff)};
    --top right
    local tR = {x=tree.position.x + box.right_bottom.x + (player_margin.right_bottom.x * playerMarginCoeff),
                         y=tree.position.y + box.left_top.y + (player_margin.left_top.y * playerMarginCoeff)};
    --bottom left
    local bL = {x=tree.position.x + box.left_top.x + (player_margin.left_top.x * playerMarginCoeff),
                         y=tree.position.y + box.right_bottom.y + (player_margin.right_bottom.y * playerMarginCoeff)};
    --bottom right
    local bR = {x=tree.position.x + box.right_bottom.x + (player_margin.right_bottom.x * playerMarginCoeff),
                         y=tree.position.y + box.right_bottom.y + (player_margin.right_bottom.y * playerMarginCoeff)};

    for i, point in pairs({tL, tR, bL, bR}) do
      if(not self:pointCollidesWithEntities(player, point, trees, {tree})) then
        nodes[#nodes + 1] = point
      end
    end
  end
  log("Found " .. #trees .. " trees, and generated " .. #nodes .. " navigation points (expected " .. (#trees * 4) .. ")", "INFO");
  local fringe = Fringe:new();

  while(fringe:size() > 0) do

  end
  log("Error! Unable to find path!", "ERROR");
  return {};
end

function PathfindToPointTask:tick(args)
  local player = args.player;
  -- find a path to self.x, self.y

  if(not self.pathFound) then
    local dest = player.surface.get_tile(self.x, self.y)
    if(not self:isPassable(player,dest)) then
      log("Destination is not walkable terrain (" .. dest.prototype.name .. ")", "WARN")
      player.print("Destination tile is not walkable terrain (" .. dest.prototype.name .. ")");
      self.pathFound = true;
      return;
    end

    local path = self:pathfind(player);
    log("Path found!", "INFO");
    for i, position in ipairs(path) do
      Logger.log("Path step: " .. position.x .. ", " .. position.y, "DEBUG")
      path[i] = MoveToPointTask:new({x=position.x, y = position.y});
    end
    args.machine:pushNext(path);
    self.pathFound = true;
  else
    player.print("Path is already found!");
  end
end
