require 'task'
require 'util'
require 'controllers/tasks/gatherResourcesTask'
--[[
  CraftRecipeTask
  Causes the player to craft the given recipe.
   - recipe: string; The name of the recipe to craft
   - qty: number; The quantity of the given recipe to craft
]]
CraftRecipeTask = Task:new{goalSet=false}

function CraftRecipeTask:achieved (args)
  return self.started and args.player.crafting_queue_size == 0;
end

function CraftRecipeTask:tick (args)
  local player = args.player;

  if(not self.started) then
    local recipe = player.force.recipes[self.recipe]

    if((not recipe) or (not recipe.enabled)) then
      local reason;
      if(not recipe) then
        reason = "there is no such recipe";
      else
        reason = "the recipe is not enabled (needs tech?)"
      end
      log("Unable to craft " .. self.recipe .. ", " .. reason, "ERROR")
      return
    end

    if(player.get_craftable_count(recipe.name) < self.qty) then
      --figure out what ingredients are needed
      local required = {};
      local inv = player.get_inventory(defines.inventory.player_main);
      for i, ingredient in pairs(recipe.ingredients) do
        if(ingredient.type ~= "item") then
          log("Not sure how to get " .. ingredient.name .. " - it's not an item!", "WARN");
        end
        local inventory_qty = inv.get_item_count(ingredient.name);
        local required_qty = (ingredient.amount * self.qty) - inventory_qty;
        if(required_qty > 0) then
          required[#required + 1] = {name=ingredient.name, qty=required_qty};
        end
      end
      --enqueue a gatherResourcesTask for each of them
      for i, requirement in pairs(required) do
        args.machine:pushSingle(GatherResourceTask:new{type=requirement.name, qty=requirement.qty});
      end
      return;
    end

    local numEnqueued = player.begin_crafting{count= self.qty, recipe=recipe}
    if(numEnqueued > 0) then
      self.started = true
    end
  end
end
