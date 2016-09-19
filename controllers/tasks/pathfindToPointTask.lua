require 'task'
require 'util'
require '../util/pathfinding_fringe'
require '../util/logger'

PathfindToPointTask = Task:new{pathFound = false}

local heuristicCoeff = 1;
local costCoeff = 1;

function PathfindToPointTask:achieved(args)
  return self.pathFound;
end

function PathfindToPointTask:computeTileScore(tile)
  local tileCost = (1 / tile.prototype.walking_speed_modifier);
  local heuristic = util.distance(tile.position, {x= self.x, y = self.y});

  return {tile = tileCost * costCoeff, heuristic = heuristic * heuristicCoeff};
end

function PathfindToPointTask:visit(x, y)
  if(not self.closed) then
    self.closed = {}
  end
  if(not self.closed[x]) then
    self.closed[x] = {}
  end
  self.closed[x][y] = true;
end

function PathfindToPointTask:visited(x, y)
  return self.closed and self.closed[x] and self.closed[x][y];
end

local impassibleTiles = {
  "out-of-map",
  "deepwater",
  "deepwater-green",
  "water",
  "water-green"
}

local playerCollision
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
  

  local entities = player.surface.find_entities_filtered{position=tile.position}
  --TODO: and not blocked by trees/rocks/structures
  if(#entities > 0) then
    return false;
  end
  return true;
end

function PathfindToPointTask:pathfind(player)
  local fringe = Fringe:new();
  local startTile = player.surface.get_tile(player.position.x, player.position.y);
  local startScore = self:computeTileScore(startTile);
  startScore.total = 0 + startScore.tile;
  fringe:add({path = {startTile}, score = startScore})
  local i = 0
  while(fringe:size() > 0) do
    i = i + 1;
    local bestSolution = fringe:pop();
    -- explore by adding neighbors to fringe
    local bestPath = bestSolution.path;
    local leafTile = bestPath[#bestPath];
    Logger.log("PF> Exploring from " .. leafTile.position.x .. ", " .. leafTile.position.y .. " - score: " .. bestSolution.score.total + bestSolution.score.heuristic)
    Logger.log("PF> Current path length ".. #bestPath)
    if(self.x == leafTile.position.x and self.y == leafTile.position.y) then
      --we found the destination!
      return bestPath;
    end
    if(not self:visited(leafTile.position.x, leafTile.position.y)) then
      self:visit(leafTile.position.x, leafTile.position.y);
      for i = -1, 1 do
        for j = -1, 1 do
          local nextCoord = {x = leafTile.position.x + i, y=leafTile.position.y + j};
          if(not self:visited(nextCoord.x, nextCoord.y)) then
            local nextTile = player.surface.get_tile(nextCoord.x, nextCoord.y);
            if(self:isPassable(player, nextTile)) then
              local newPath = {};
              local idx = 1;
              while(bestPath[idx] ~= nil) do
                newPath[idx] = bestPath[idx];
                idx = idx + 1;
              end
              newPath[idx] = nextTile;
              tileScore = self:computeTileScore(nextTile);
              tileScore.total = bestSolution.score.total + tileScore.tile;
              fringe:add({path = newPath, score = tileScore});
            end
          end
        end
      end
    end
  end
  Logger.log("PF> Error! Unable to find path!");
  player.print("Unable to find path :(");
end

function PathfindToPointTask:tick(args)
  local player = args.player;
  -- find a path to self.x, self.y

  if(not self.pathFound) then
    local dest = player.surface.get_tile(self.x, self.y)
    if(not self:isPassable(player,dest)) then
      Logger.log("PF> Destination is not walkable terrain (" .. dest.prototype.name .. ")")
      self.pathFound = true;
    end
    local path = self:pathfind(player);
    Logger.log("PF> Path found!");
    for i, tile in ipairs(path) do
      Logger.log("PF> Path step: " .. tile.position.x .. ", " .. tile.position.y .. " (" .. tile.prototype.name .. ")")
      path[i] = MoveToPointTask:new({x=tile.position.x + 0.5, y = tile.position.y + 0.5});
    end
    args.machine:pushNext(path);
    self.pathFound = true;
  else
    player.print("Path is already found!");
  end
end
