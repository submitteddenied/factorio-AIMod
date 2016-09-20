script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  player.insert{name="iron-plate", count=8}
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
  player.insert{name="burner-mining-drill", count = 1}
  player.insert{name="stone-furnace", count = 1}
  player.force.chart(player.surface, {{player.position.x - 200, player.position.y - 200}, {player.position.x + 200, player.position.y + 200}})
end)

script.on_event(defines.events.on_player_respawned, function(event)
  local player = game.players[event.player_index]
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
end)

script.on_event(defines.events.on_rocket_launched, function(event)
  local force = event.rocket.force
  if event.rocket.get_item_count("satellite") > 0 then
    if global.satellite_sent == nil then
      global.satellite_sent = {}
    end
    if global.satellite_sent[force.name] == nil then
      game.set_game_state{game_finished=true, player_won=true, can_continue=true}
      global.satellite_sent[force.name] = 1
    else
      global.satellite_sent[force.name] = global.satellite_sent[force.name] + 1
    end
    for index, player in pairs(force.players) do
      if player.gui.left.rocket_score == nil then
        local frame = player.gui.left.add{name = "rocket_score", type = "frame", direction = "horizontal", caption={"score"}}
        frame.add{name="rocket_count_label", type = "label", caption={"", {"rockets-sent"}, ":"}}
        frame.add{name="rocket_count", type = "label", caption=tostring(global.satellite_sent[force.name])}
      else
        player.gui.left.rocket_score.rocket_count.caption = tostring(global.satellite_sent[force.name])
      end
    end
  else
    if(#game.player > 1) then
      for index, player in pairs(force.players) do
        player.print({"gui-rocket-silo.rocket-launched-without-satellite"})
      end
    end
  end
end)
