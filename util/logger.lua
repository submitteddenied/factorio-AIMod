Logger = {}

local path = "output.log";

function Logger.log(message)
  game.write_file(path, message .. "\n", true);
end
