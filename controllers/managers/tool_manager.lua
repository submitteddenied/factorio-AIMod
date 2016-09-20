require 'manager'

require 'controllers/tasks/playerGatherResourcesTask'
require 'controllers/tasks/craftRecipeTask'
require 'util/logger'

ToolManager = Manager:new()
local REPLACE_FACTOR = 0.5;
local log = Logger.makeLogger("ToolManager");

function ToolManager:tick(args)
  local player = args.player;

  if(self.task == nil) then
    local tools = player.character.get_inventory(defines.inventory.player_tools).get_contents();
    local axe_stack = player.character.get_inventory(defines.inventory.player_tools).find_item_stack("iron-axe");

    if(axe_stack == nil or
      ((axe_stack.count - 1) * axe_stack.prototype.durability) + axe_stack.durability < axe_stack.prototype.durability * REPLACE_FACTOR) then
      -- enqueue the task to make more
      local durability = 0;
      if(axe_stack ~= nil) then
        durability = ((axe_stack.count - 1) * axe_stack.prototype.durability) + axe_stack.durability;
        log("Axe durability: " .. durability, "DEBUG");
      else
        log("There are no axes", "INFO");
      end
      self.task = CraftRecipeTask:new{recipe = "iron-axe", qty = 1};
      args.machine:pushStart({
        PlayerGatherResourcesTask:new{type="iron-plate", qty=4},
        self.task
      });
    end
  else
    if(self.task:achieved(args)) then
      self.task = nil;
    end
  end
end
