ResourceSource = {}
--[[
ResourceSource has:
 - type of Resource
 - qty available
 - position (area?)
 - fitness (ease of collection?)
]]

-- {entity=entity}
function ResourceSource:new(o)
  o = o or {};
  setmetatable(o, self);
  self.__index = self;
  return o;
end

function ResourceSource:provides_type(type)
  if(not self.types) then
    self:compute_types();
  end
  for i, t in ipairs(self.types) do
    if(t.type == type) then
      return true;
    end
  end
  return false;
end

function ResourceSource:is_valid()
  return self.entity.valid;
end
