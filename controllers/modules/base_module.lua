require 'controllers/tasks/fuel_building_task'
require 'controllers/tasks/wait_for_output_task'

BaseModule = {}

function BaseModule:new(o)
  o = o or {};
  setmetatable(o, self);
  self.__index = self;
  return o;
end

--TODO When building a module, keep track of the completed buildings (at least
-- the inputs and outputs?)
function BaseModule:outputsForProduct(product)
  local result = {};
  for i, output in ipairs(self.outputs) do
    local building = self.buildings[output.building];
    local entity = building.entity;
    if(entity and entity.valid) then
      result[#result + 1] = entity;
    end
  end
  return result;
end

function BaseModule:hasOutputAvailable(product)
  for i, entity in ipairs(self:outputsForProduct(product)) do
    local inv = entity.get_output_inventory();
    if(inv.get_item_count(product) > 0) then
      return true;
    end
  end

  return false;
end

function BaseModule:generateTasksForOutput(product, qty)
  local tasks = {};
  --make sure that all inputs are satisfied
  for i, input in ipairs(self.inputs) do
    local building = self.buildings[input.building];
    local entity = building.entity;
    if(entity and entity.valid) then
      if(input.slot == "fuel") then
        local inv = entity.get_inventory(defines.inventory.fuel)
        if(inv.is_empty()) then
          tasks[#tasks + 1] = FuelBuildingTask:new{building=entity}
        end
      end
    end
  end

  --maybe wait? until the output building has output available
  local outputs = self:outputsForProduct(product);
  tasks[#tasks + 1] = WaitForOutputTask:new{buildings=outputs, qty=qty}

  return tasks;
end
