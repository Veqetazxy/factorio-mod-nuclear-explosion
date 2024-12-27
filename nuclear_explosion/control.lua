local reactors = {}

local function find_nuclear_reactors()
  for _, surface in pairs(game.surfaces) do 
    for _, reactor in pairs(surface.find_entities_filtered{name = "nuclear-reactor"}) do 
      if reactor == entity then
        return -- Reactor already in the list
      end
      table.insert(reactors, reactor) 
    end 
  end
end

local function add_reactor(entity)
  if entity and entity.name == "nuclear-reactor" then
    for _, reactor in pairs(reactors) do
      if reactor == entity then
        return -- Reactor already in the list
      end
    end
    table.insert(reactors, entity)
  end
end

local function remove_reactor(entity)
  if entity and entity.name == "nuclear-reactor" then
    for i, reactor in pairs(reactors) do
      if reactor == entity then
        table.remove(reactors, i)
        break
      end
    end
  end
end

script.on_init(function()
  find_nuclear_reactors()
end)

script.on_configuration_changed(function(data)
  reactors = {} -- Leere Reaktorenliste, um sicherzustellen, dass wir keine Duplikate haben.
  find_nuclear_reactors()
end)

script.on_event(defines.events.on_built_entity, function(event)
  if event.entity then
    add_reactor(event.entity)
  end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
  if event.entity then
    add_reactor(event.entity)
  end
end)

script.on_event(defines.events.on_entity_died, function(event)
  if event.entity then
    remove_reactor(event.entity)
  end
end)

script.on_event(defines.events.on_tick, function(event)
  for i = #reactors, 1, -1 do
    local reactor = reactors[i]
    if reactor.valid then
      if reactor.temperature >= 1000 then
        reactor.surface.create_entity{
          name = "atomic-rocket",
          position = reactor.position,
          force = reactor.force,
          target = reactor.position,
          speed = 0.1
        }
        reactor.destroy()
        table.remove(reactors, i)
      end
    else
      table.remove(reactors, i)
    end
  end
end)
