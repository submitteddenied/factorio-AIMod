require 'tasks/task';
GoalMachine = Task:new()

function GoalMachine:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function GoalMachine:achieved(arg)
  return self.goals == nil
end

function GoalMachine:tick(arg)
  if(self.goals ~= nil) then
    if(self.goals.current:achieved{player=arg.player, machine=self}) then
      self.goals = self.goals.next;
    else
      self.goals.current:tick{player=arg.player, machine=self};
    end
  end
end

function GoalMachine:pushSingle(goal)
  self.goals = { current = goal, next = self.goals };
end

function GoalMachine:pushSingleNext(goal)
  self.goals.next = { current = goal, next = self.goals.next };
end

function GoalMachine:enqueueGoal(goal)
  self:enqueueGoalItem({current = goal});
end

function GoalMachine:pushStart(goals)
  local count = #goals;
  for i, goal in ipairs(goals) do
    self:pushSingle(goals[(count + 1) - i]);
  end
end

function GoalMachine:pushNext(goals)
  local count = #goals;
  for i, goal in ipairs(goals) do
    self:pushSingleNext(goals[(count + 1) - i]);
  end
end

function GoalMachine:enqueueGoals(goals)
  local g;
  local s;
  for i, goal in ipairs(goals) do
    if(g) then
      g.next = { current = goal };
      g = g.next
    else
      g = { current = goal };
      s = g;
    end
  end

  self:enqueueGoalItem(s);
end


function GoalMachine:enqueueGoalItem(item)
  local g = self.goals;
  while(g.next ~= nil) do
    g = g.next;
  end
  -- g is last
  g.next = item;
end
