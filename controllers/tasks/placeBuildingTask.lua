require 'task'
require 'util'
require 'util/inventories'
require 'util/collision'
require 'controllers/tasks/moveToPointTask'

--[[
  PlaceBuildingTask moves to a location within range of building stuff and
  places the item from your inventory on the ground.
  Obstacles are not cleared in order to build the entity.
   - type: string; The kind of building to build
   - building: table; (Optional) The buidling table in the module to connect
                      the placed entity with
   - position: {x=number,y=number}; the location to build the building
   - direction: defines.direction; The orientation for the building
]]--
PlaceBuildingTask = Task:new()
local player_build_distance = 6; --see base/prototypes/entity/demo-entity.lua (player prototype)

function PlaceBuildingTask:achieved (args)
  return self.placed ~= nil;
end

function PlaceBuildingTask:toString()
  return "PlaceBuildingTask - type: " .. self.type .. " position: (" .. self.position.x .. ", " .. self.position.y .. ")";
end

function PlaceBuildingTask:tick (args)
  local player = args.player;
  local prototype = game.entity_prototypes[self.type];
  if(util.distance(player.position, self.position) > player_build_distance or
          overlappingBoundingBox(player.position, game.entity_prototypes["player"].collision_box, self.position, prototype.collision_box)) then
    args.machine:pushSingle(MoveToPointTask:new{x=self.position.x, y=self.position.y + prototype.collision_box.left_top.y - 2})
  else
    if(player.surface.can_place_entity{name=self.type, position=self.position, direction=self.direction, force=player.force}) then
      local inventories = Inventories.get_all_inventories(player);
      for i, inv in ipairs(inventories) do
        if(inv.get_item_count(self.type) > 0) then
          local removed = inv.remove({name=self.type, count=1});
          if(removed == 1) then
            --is the player's "active item" inventory (defines.inventory.item_active) the one in the mouse?
            local entity = player.surface.create_entity{
              name=self.type,
              position=self.position,
              direction=self.direction,
              force=player.force
            };
            self.placed = entity;
            if(self.building ~= nil) then
              self.building.entity = entity;
            end
            break;
          end
        end
      end
    else
      player.print("Unable to place building")
    end
  end
end
