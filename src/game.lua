-- libs
require 'vendor/AnAL'
require 'socket.http'
gamestate = require 'vendor/hump/gamestate'

local game = {}

-- modules
local map = nil
local bot = require 'bot'
local cmd = require 'cmd'
local doodad = require 'doodad'
local flow = require 'flow'
local camera = require 'camera'

local function resetlevel()
  map = flow.map

  bot.x = map.start.x
  bot.y = map.start.y

  camera:setbounds( 0, 0, map.tilewidth * map.width, map.tileheight * map.height )

  cmd.init()
end

function game:keypressed( key )
  local command = cmd.toCommand( key )
  cmd.process( command )
end

-- true if won, false otherwise
local function won( bot, map )
  if bot.x == map.dest.x and bot.y == map.dest.y then
    return true
  else
    return false
  end
end

local function toJSONArray( array )
  local arr = "["
  for i, elem in ipairs( array, elem ) do
    arr = arr .. [["]] .. elem .. [["]]
    if i < table.maxn( array ) then
      arr = arr .. ","
    end
  end
  arr = arr .. "]"
  return arr
end

local function submitcommands( commands )
  local request = [[player=]]..bot.name..[[&level=]]..map.name:gsub( "art/levels/", "" )..[[&commands=]]..toJSONArray( commands )
  local response = {}
  local res, code, _ = socket.http.request ( {
    url = "http://168.62.40.105:7000/submitscore";
    method = "POST";
    headers = { [ "Content-Type" ] = "application/x-www-form-urlencoded";
                [ "Content-Length" ] = #request;
              };
    source = ltn12.source.string( request );
    sink = ltn12.sink.table( response );
  } )

  return res and true, table.remove( response ) or false, 0
end

local function gethighscores()
  local response = {}
  local res, code, _ = socket.http.request ( {
    url = "http://168.62.40.105:7000/gethighscores/"..map.name:gsub( "art/levels/", "" );
    sink = ltn12.sink.table( response );
  } )

  -- debug
  table.foreach( response, print )
end

function game:enter()
  -- init all modules
  flow.init()
  cmd.init()
  bot.init( "desktop" )
  doodad.init()
  camera:init()
  resetlevel()
end

function game:update( dt )

  -- update anims
  bot.anim:update( dt )
  table.foreach( doodad.anims, function( _, anim ) anim:update( dt ) end )

  -- execute commands
  cmd.execute( bot )

  -- sanitize position
  if bot.x < 1         then bot.x = 1 end
  if bot.x > map.width then bot.x = map.width end

  if bot.y < 1          then bot.y = 1 end
  if bot.y > map.height then bot.y = map.height end

  -- update camera
  camera:update( bot, map )

  -- check for win condition
  if won( bot, map ) then
    -- play brief celebratory overlay
    -- submit commands to server

    local success, percentile = submitcommands( cmd.buffer )
    if success then
      print( percentile )
    end

    gethighscores()

    flow.advance()
    resetlevel()
  end
end

function game:draw()
  camera:set()

  -- draw map
  for y = 1, map.height do
    for x = 1, map.width do
      if love.graphics.drawq ~= nil then
        love.graphics.drawq( map.tileset, map.tiles[ ( y - 1 ) * map.width + x ], ( x - 1 ) * map.tilewidth, ( y - 1 ) * map.tileheight )
      else
        love.graphics.draw( map.tileset, map.tiles[ ( y - 1 ) * map.width + x ], ( x - 1 ) * map.tilewidth, ( y - 1 ) * map.tileheight )
      end
    end
  end

  -- draw doodads
  if ( map.dest.x and map.dest.y ) then
    doodad.destanim:draw( ( map.dest.x - 1 ) * map.tilewidth, ( map.dest.y - 1 ) * map.tileheight )
  end

  -- draw bot
  bot.anim:draw( ( bot.x - 1 ) * map.tilewidth, ( bot.y - 1 ) * map.tileheight )

  camera:unset()
end

return game
