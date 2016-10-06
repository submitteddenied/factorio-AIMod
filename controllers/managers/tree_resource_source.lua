require 'resource_source';

require 'controllers/tasks/mine_entity_task'

TreeResourceSource = ResourceSource:new();

function TreeResourceSource:compute_types()
  local products = {};
  if(not self.entity.valid) then
    self.types = {};
    return;
  end
  for j, product in ipairs(self.entity.prototype.mineable_properties.products) do
    local amount = product.amount;
    if(product.amount == nil) then
      --TODO: It would be more conservative (but less "correct") to use the amount_min
      local delta = product.amount_max - product.amount_min;
      amount = product.amount_min + (delta * product.probability);
    end
    products[#products + 1] = {type=product.name, qty=amount}
  end
  self.types = products;
end

-- {type=type, qty=#, player=player, machine=GoalMachine}
function TreeResourceSource:gather(opts)
  opts.machine:pushSingle(MineEntityTask:new{entity=self.entity});
end
