require 'resource_source';

require 'controllers/tasks/moveToPointTask'
require 'controllers/tasks/mineResourceTask'
require 'controllers/tasks/collect_module_output_task'
--[[
  ModuleResourceSource
  Provides the interface between a module (piece of a factory) and the resource
  manager
   - module: Module; the module that this resource source represents
]]
ModuleResourceSource = ResourceSource:new();

function ModuleResourceSource:compute_types()
  --for each output of self.module, add the type
  local products = {};
  for i, output in ipairs(self.module.outputs) do
    products[#products + 1] = {type=output.type}
  end
  self.types = products;
end

-- {type=type, qty=#, player=player, machine=GoalMachine}
function ModuleResourceSource:gather(opts)
  -- is there any of "type" available?
  local tasks = {};
  if(not this.module:hasOutputAvailable(opts.type)) then
    tasks = this.module:generateTasksForOutput(opts.type, opts.qty)
  end
  tasks[#tasks + 1] = CollectModuleOutputTask:new{module=this.module, qty=opts.qty};
  opts.machine:pushStart(tasks);
end
