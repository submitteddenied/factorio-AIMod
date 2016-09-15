Task = {}

function Task:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Task:achieved (arg)
  return false
end

function Task:tick (arg)
end
