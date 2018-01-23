require 'task'
require 'util'
require 'controllers/tasks/placeBuildingTask'
require 'controllers/tasks/clear_area_task'

--[[
  BuildBuildingTask makes sure the area is clear and then starts the place buidling
  task.
   - type: string; The kind of building to build
   - building: table; (Optional) The buidling table in the module to connect
                      the placed entity with
   - position: {x=number,y=number}; the location to build the building
   - direction: defines.direction; The orientation for the building
]]--
BuildBuildingTask = Task:new{enqueued=false}

function BuildBuildingTask:achieved (args)
  return self.enqueued
end

function BuildBuildingTask:toString()
  return "BuildBuildingTask - type: " .. self.type .. " position: (" .. self.position.x .. ", " .. self.position.y .. ")";
end

-- self.position, self.type, self.direction
function BuildBuildingTask:tick (args)
  local player = args.player;
  local prototype = game.entity_prototypes[self.type];
  local area = {
    left_top={x=self.position.x + prototype.selection_box.left_top.x - 1, y=self.position.y + prototype.selection_box.left_top.y - 1},
    right_bottom={x=self.position.x + prototype.selection_box.right_bottom.x + 1, y=self.position.y + prototype.selection_box.right_bottom.y + 1}
  };
  args.machine:pushStart({
    ClearAreaTask:new{area=area},
    PlaceBuildingTask:new{type=self.type, position=self.position, {building=self.building}, {direction=self.direction}}
  });
  self.enqueued = true;
end
