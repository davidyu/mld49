local flow = {}

local utils = require 'utils'

local function nextLevel()
  for i, level in ipairs( flow.seq ) do
    if level == flow.map then
      return flow.seq[ i + 1 ]
    end
  end
  return nil
end

function flow.init()
  flow.seq = {}

  table.insert( flow.seq, "art/levels/intro" )
  table.insert( flow.seq, "art/levels/square" )
  table.insert( flow.seq, "art/levels/short" )
  table.insert( flow.seq, "art/levels/long" )
  table.insert( flow.seq, "art/levels/end" )

  flow.map = utils.buildMap( flow.seq[ 1 ] )
end

function flow.advance()
  if flow.map.name ~= "art/levels/end" and nextLevel() ~= nil then
    flow.map = nextLevel()
  end
end

return flow
