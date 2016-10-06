require 'resource_source';

require 'util/logger'
require 'controllers/tasks/craftRecipeTask'

local log = Logger.makeLogger("CraftResourceSource");
--must be constructed with player and type
CraftResourceSource = ResourceSource:new();

function CraftResourceSource:find_recipe(type)
  if(not self.player) then
    log("Player not provided!", "ERROR");
    return false;
  end
  -- do we have any recipes that are craftable that result in {{type}}
  log("Attempting to craft recipe ".. type, "INFO");
  for name, recipe in pairs(self.player.force.recipes) do
    if(recipe.enabled and recipe.category == "crafting") then
      for i, product in ipairs(recipe.products) do
        if(product.name == type) then
          return recipe;
        end
      end
    end
  end
  log("Recipe ".. type .. " not found", "INFO");
  return nil;
end

function CraftResourceSource:provides_type(type)
  return self:find_recipe(type) ~= nil;
end

function CraftResourceSource:gather(opts)
  local recipe = self:find_recipe(opts.type);
  opts.machine:pushSingle(CraftRecipeTask:new{recipe=recipe.name, qty=opts.qty});
end
