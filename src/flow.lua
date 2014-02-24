local flow = {}

local utils = require 'utils'

function flow.currentindex()
  for i, level in ipairs( flow.seq ) do
    if level == flow.map.name then
      return i
    end
  end
  return nil
end

local function nextLevel()
  for i, level in ipairs( flow.seq ) do
    if level == flow.map.name then
      return flow.seq[ i + 1 ]
    end
  end
  return nil
end

function flow.reset()
  flow.map = utils.buildMap( flow.seq[ 1 ] )
end

function flow.init()
  flow.seq = {}

  -- specify list of levels
  table.insert( flow.seq, "art/levels/intro" )
  table.insert( flow.seq, "art/levels/square" )
  table.insert( flow.seq, "art/levels/short" )
  table.insert( flow.seq, "art/levels/staircase" )
  table.insert( flow.seq, "art/levels/seashell" )
  table.insert( flow.seq, "art/levels/long" )
  table.insert( flow.seq, "art/levels/intermediate" )
  table.insert( flow.seq, "art/levels/end" )

  flow.map = utils.buildMap( flow.seq[ 1 ] )
end

function flow.advance()
  if flow.map.name ~= "art/levels/end" and nextLevel() ~= nil then
    flow.map = utils.buildMap( nextLevel() )
    return true
  else
    return false
  end
end

return flow
