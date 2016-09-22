require('util/logger');

local impassibleTiles = {
  "out-of-map",
  "deepwater",
  "deepwater-green",
  "water",
  "water-green"
};

local log = Logger.makeLogger("util/passable");

function isTilePassable(player, tile)
  local onPlayerLayer = false;
  for i, tileType in ipairs(impassibleTiles) do
    if(tile.prototype.name == tileType) then
      log("Found impassible tile " .. tileType, "DEBUG");
      onPlayerLayer = true;
      break;
    end
  end
  if(onPlayerLayer) then
    return false;
  end
  return true;
end
