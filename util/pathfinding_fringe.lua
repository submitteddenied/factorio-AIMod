Fringe = {};
function Fringe:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

--sorted insert
function Fringe:add(path)
  if(not self.list) then
    self.list = {value = path}
    self.count = 1
  else
    local prev
    local curr = self.list;
    -- insert the lowest score at the start of the list
    while(curr and curr.value.score.total + curr.value.score.heuristic < path.score.total + path.score.heuristic) do
      prev = curr
      curr = curr.next
    end
    if(not prev) then -- there is something in the list, but the new item should be first
      self.list = {value = path, next = self.list }
    else
      prev.next = {value = path, next = curr}
    end
    self.count = self.count + 1
  end
end

function Fringe:pop()
  local head = self.list;
  if(self.list) then
    self.list = self.list.next;
    self.count = self.count - 1
  end

  return head.value;
end

function Fringe:size()
  return self.count or 0;
end
