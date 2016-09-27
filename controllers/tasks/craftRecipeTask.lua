require 'task'
require 'util'
require 'controllers/tasks/playerGatherResourcesTask'

CraftRecipeTask = Task:new{goalSet=false}

function CraftRecipeTask:achieved (args)
  return self.started and args.player.crafting_queue_size == 0;
end

function CraftRecipeTask:tick (args)
  local player = args.player;

  if(not self.started) then
    local recipe = player.force.recipes[self.recipe]

    if((not recipe) or (not recipe.enabled)) then
      player.print("I don't know how to craft " .. self.recipe)
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
        args.machine:pushSingle(PlayerGatherResourcesTask:new{type=requirement.name, qty=requirement.qty});
      end
    end

    local numEnqueued = player.begin_crafting{count= self.qty, recipe=recipe}
    if(numEnqueued > 0) then
      self.started = true
    end
  end
end
