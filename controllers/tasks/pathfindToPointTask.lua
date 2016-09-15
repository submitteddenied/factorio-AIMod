require 'task'
require 'util'

PathfindToPointTask = Task:new()

function PathfindToPointTask:achieved(args)
end

function PathfindToPointTask:tick(args)
  local player = args.player;
  -- find a path to args.x, args.y
  
  local fringe = {{player.position}}

  while(#fringe > 0) do
    local best;
    local bestScore;
    for i, path in ipairs(fringe) do
      if(not best) then
        best = path
        bestScore = self:computeScore(path)
      else
        local score = self:computeScore(path)
        if(score > bestScore) then

        end
      end
    end
  end
end
