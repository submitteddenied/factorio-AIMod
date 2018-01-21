local goals = {
  coal = {name = "coal", tick = getCoal, param = 50, next = "done"},
  done = {name = "done", tick = done}
};

local currentGoal = goals.done;

function run(player)
  if(goals[currentGoal].tick(player, goals[currentGoal])) then
    currentGoal = goals[currentGoal].next
  end
end

function getCoal(player, goal)
  coals = player.surface.find_entities_filtered{area = 
    {{player.position.x - range, player.position.y - range}, {player.position.x + range, player.position.y + range}}, 
    name= "iron-ore"}

  local closest;
  local d = range;
  for i, iron in ipairs(irons) do
    if(util.distance(iron.position, player.position) < d) then
      closest = iron;
      d = util.distance(iron.position, player.position);
    end
  end

  if(closest) then
    player.print("Closest at " .. closest.position.x .. "," .. closest.position.y .. " distance:" .. d);
  end
end
