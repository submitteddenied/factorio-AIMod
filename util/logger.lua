Logger = {
  LEVEL= "DEBUG",
  LEVELS = {
    "DEBUG",
    "INFO",
    "WARN",
    "ERROR"
  }
}

local levelsToIndex = {}
for key,val in pairs( Logger.LEVELS ) do levelsToIndex[ val ] = key end

-- DEBUG, INFO, WARN, ERROR
local path = "output.log";


function Logger.log(message)
  game.write_file(path, message .. "\n", true);
end

function Logger.logAtLevel(level, message)
  if(levelsToIndex[Logger.LEVEL] <= levelsToIndex[level]) then
    Logger.log(message)
  end
end

function Logger.makeLogger(class)
  return function(msg, level)
    Logger.logAtLevel(level, class .. "> " .. level .. " - " .. msg)
  end
end
