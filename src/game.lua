-- libs
require 'vendor/AnAL'
require 'socket.http'
local gui = require 'vendor/Quickie'
local gamestate = require 'vendor/hump/gamestate'
local json = loadfile( "vendor/json.lua" )()

local fonts = {}
local game = {}
game.stats = {}

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
  -- table.foreach( response, print )

  return json:decode( response[1] )
end

function game.stats:enter( from )
  game.stats.parent = from

  local success, percentile = submitcommands( cmd.buffer )
  if success then
    game.stats.percentile = tonumber( percentile )
    game.stats.highscores = gethighscores()
    game.stats.topresult = game.stats.highscores[1]
  else
    game.stats.percentile = nil
  end
end

-- thanks to http://lua-users.org/wiki/SimpleRound
local function round(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

function game.stats:update( dt )
  gui.group.push{ grow = "down", pos = { 250, 240 } }

  love.graphics.setFont( fonts["title"] )
  local usedFewestCommands = ( table.maxn( game.stats.topresult["commands"] ) >= table.maxn( cmd.buffer ) )
  if usedFewestCommands or game.stats.percentile and game.stats.percentile > 85 then
    gui.Label{ text = "AWESOME!!!", align = "center" }
  elseif game.stats.percentile and game.stats.percentile > 65 then
    gui.Label{ text = "GREAT!!", align = "center" }
  else
    gui.Label{ text = "PASS!", align = "center" }
  end
  love.graphics.setFont( fonts["button"] )
  gui.Label{ text = "you used " .. table.maxn( cmd.buffer ) .. " commands in total.", align = "center" }

  if game.stats.percentile then
    if usedFewestCommands or game.stats.percentile > 85 then
      gui.Label{ text = "the top player on this level used " .. table.maxn( game.stats.topresult["commands"] ) .. " commands in total.", align = "center" }
    end
    gui.Label{ text = bot.name .. "'s percentile rank on this level: " .. round( game.stats.percentile, 2 ), align = "center" }
  end

  gui.group.pop()
  gui.group.push{ grow = "down", pos = { 250, 400 } }
  love.graphics.setFont( fonts["button"] )
  if gui.Button{ text = "advance [spc]", align = "center" } then
    flow.advance()
    resetlevel()
    gamestate.pop()
  end
  gui.group.pop()
end

function game.stats:keypressed( key, code )
  if key == ' ' then
    flow.advance()
    resetlevel()
    gamestate.pop()
  end
end

function game.stats:draw()
  game.stats.parent:draw()

  -- draw stats overlay

  local r, g, b, a = love.graphics.getColor()
  love.graphics.setColor( 0, 0, 0, 128 )
  love.graphics.rectangle( "fill", 0, 220, 640, 200 )
  love.graphics.setColor( r, g, b, a )

  gui.core.draw()
end

function game:init()
  -- init all modules
  flow.init()
  cmd.init()
  bot.init()
  doodad.init()
  camera:init()
  resetlevel()
  fonts = {
    ["title"] = love.graphics.newFont( "art/fonts/typeone.ttf", 60 );
    ["button"] = love.graphics.newFont( "art/fonts/BebasNeue.otf", 15 )
  }
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

    gamestate.push( game.stats )
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

function game.getbot()
  return bot
end

return game
