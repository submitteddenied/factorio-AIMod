require 'task'
require 'util'

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
      player.print("I can't craft " .. self.qty .. " of " .. self.recipe)
      return
    end

    local numEnqueued = player.begin_crafting{count= self.qty, recipe=recipe}
    if(numEnqueued > 0) then
      self.started = true
    end
  end
end
