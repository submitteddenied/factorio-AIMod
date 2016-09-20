Manager = {}

function Manager:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Manager:tick (arg)
end
