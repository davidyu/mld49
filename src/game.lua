-- libs
require 'vendor/AnAL'
require 'socket.http'

local gui = require 'vendor/Quickie'
local gamestate = require 'vendor/hump/gamestate'
local json = require 'vendor/json'
local fonts = {}
local serverdisable = false

-- gamestates
local game = {}
game.stats = {}
game.help = {}

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

  local screenw, screenh = love.window.getDimensions()
  camera:setbounds( -map.tilewidth, -map.tileheight, map.tilewidth * ( map.width + 1 ) - screenw, map.tileheight * ( map.height + 1 ) - screenh )

  camera:centerbot( bot, map )

  cmd.init()
end

local function nextlevel()
  flow.advance()

  -- check if we're done
  if table.maxn( flow.seq ) == flow.currentindex() then
    gamestate.switch( menu.credits )
  end
end

function game:keypressed( key )
  local command = cmd.toCommand( key )
  cmd.process( command )
  if key == '/' and ( love.keyboard.isDown( 'lshift' ) or love.keyboard.isDown( 'rshift' ) ) then
    gamestate.push( game.help )
  end
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
  if serverdisable then
    return false, 0
  end
  local request = [[player=]]..bot.name..[[&level=]]..map.name:gsub( "art/levels/", "" )..[[&commands=]]..toJSONArray( commands )
  local response = {}
  local res, code, _ = socket.http.request ( {
    url = "http://sonargame.cloudapp.net:7000/submitscore";
    method = "POST";
    headers = { [ "Content-Type" ] = "application/x-www-form-urlencoded";
                [ "Content-Length" ] = #request;
              };
    source = ltn12.source.string( request );
    sink = ltn12.sink.table( response );
    create = function()
        local req_sock = socket.tcp()
        req_sock:settimeout( 200 )
        return req_sock
    end
  } )

  return res and true, table.remove( response ) or false, 0
end

local function gethighscores()
  if serverdisable then
    return nil
  end
  local response = {}
  local res, code, _ = socket.http.request ( {
    url = "http://sonargame.cloudapp.net:7000/gethighscores/"..map.name:gsub( "art/levels/", "" );
    sink = ltn12.sink.table( response );
    create = function()
        local req_sock = socket.tcp()
        req_sock:settimeout( 200 )
        return req_sock
    end
  } )

  -- debug
  -- table.foreach( response, print )
  return json:decode( table.concat( response ) )
end

function game.stats:enter( from )
  game.stats.parent = from

  local success, percentile = submitcommands( cmd.buffer )
  if success then
    game.stats.percentile = tonumber( percentile )
    game.stats.highscores = gethighscores()
    if game.stats.highscores ~= nil then
      game.stats.topresult = game.stats.highscores[1]
    else
      game.stats.topresult = nil
    end
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

  if game.stats.topresult ~= nil then
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
  else
    gui.Label{ text = "PASS!", align = "center" }
  end

  gui.group.pop()
  gui.group.push{ grow = "down", pos = { 250, 400 } }
  love.graphics.setFont( fonts["button"] )
  if gui.Button{ text = "advance [spc]", align = "center" } then
    gamestate.pop() -- pop doesn't prevent code from executing
    nextlevel()
    resetlevel()
  end
  gui.group.pop()
end

function game.stats:keypressed( key, code )
  if key == ' ' then
    gamestate.pop()
    nextlevel()
    resetlevel()
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

function game.help:enter( from )
  game.help.parent = from
  game.help.overlayimg = love.graphics.newImage( "art/overlays/helpscreen.png" )
end

function game.help:update( dt )
  gui.group.push{ grow = "down", pos = { 275, 475 } }
  love.graphics.setFont( fonts["button"] )
  if gui.Button{ text = "got it [spc]", align = "center" } then
    gamestate.pop()
  end
  gui.group.pop()
end

function game.help:draw()
  self.parent:draw()
  love.graphics.draw( self.overlayimg, 170, 150 )
  gui.core.draw()
end

function game.help:keypressed( key )
  if key == 'escape' or key == ' ' then
    gamestate.pop()
  end
end

function game:init()
  -- init all modules
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

  -- execute commands
  local oldx, oldy = bot.x, bot.y
  cmd.execute( bot )

  local botmoved = bot.x ~= oldx or bot.y ~= oldy
  bot.updateAnim( bot.x - oldx, bot.y - oldy )

  -- sanitize position
  if bot.x < 1         then bot.x = 1 end
  if bot.x > map.width then bot.x = map.width end

  if bot.y < 1          then bot.y = 1 end
  if bot.y > map.height then bot.y = map.height end

  if map.isWall[ bot.x + ( bot.y - 1 )* map.width ] then
    bot.x, bot.y = oldx, oldy
  end

  -- update camera
  if botmoved then
    camera:centerbot( bot, map )
  end

  local margin = 30
  if love.mouse.getX() - margin <= 0 then
    camera:pan( 'left' )
  elseif love.mouse.getX() + margin >= 640 then
    camera:pan( 'right' )
  elseif love.mouse.getY() - margin <= 0 then
    camera:pan( 'up' )
  elseif love.mouse.getY() + margin >= 640 then
    camera:pan( 'down' )
  end

  -- update anims
  bot.anim:update( dt )
  table.foreach( doodad.anims, function( _, anim ) anim:update( dt ) end )

  -- check for win condition
  if won( bot, map ) then
    -- play brief celebratory overlay
    -- submit commands to server

    gamestate.push( game.stats )
  end
end

function game:drawoverlays()
  -- camera rec overlay - WTF such manual work
  if cmd.isrecording() then
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor( 0, 0, 0, 128 )
    love.graphics.rectangle( "fill", 545, 5, 80, 28 )

    love.graphics.setColor( 255, 0, 0, 255 )
    love.graphics.circle( "fill", 560, 17, 5, 10 )

    love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.setFont( fonts["button"] )
    love.graphics.print( "REC < " .. cmd.rkey .. " >", 570, 10 )

    love.graphics.setColor( r, g, b, a )
  end

  -- available recordings
  local keys = cmd.recordkeys()
  if table.getn( keys ) > 0 then
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor( 0, 0, 0, 128 )

    love.graphics.rectangle( "fill", 545, 40, 80, 20 * ( table.getn( keys ) + 1 ) )

    love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.setFont( fonts["button"] )
    love.graphics.print( "RECORDS:", 555, 45 )

    for i, key in ipairs( keys ) do
      love.graphics.print( "< " .. key .. " >", 555, 45 + i * 20 )
    end

    love.graphics.setColor( r, g, b, a )
  end

  -- action multiplier
  if cmd.repeatrate > 0 then
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor( 0, 0, 0, 128 )
    love.graphics.rectangle( "fill", 5, 5, 200, 28 )

    love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.setFont( fonts["button"] )
    love.graphics.print( "ACTION MULTIPLIER: " .. cmd.repeatrate .. "X", 15, 10 )

    love.graphics.setColor( r, g, b, a )
  end
end

function game:enter()
  resetlevel()
end

function game:draw()
  camera:set()

  -- draw map
  for y = 1, map.height do
    for x = 1, map.width do
      love.graphics.draw( map.tileset, map.tiles[ ( y - 1 ) * map.width + x ], ( x - 1 ) * map.tilewidth, ( y - 1 ) * map.tileheight )
    end
  end

  -- draw map grid helper overlay

  -- vertical helpers
  if not map.hideborderindicators then
    for y = 1, map.height do
      love.graphics.setColor( 255, 255, 255, 255 )
      love.graphics.setFont( fonts["button"] )
      love.graphics.print( y - 1, -map.tilewidth / 4, ( y - 0.6 ) * map.tileheight )
      love.graphics.print( y - 1,  map.tilewidth * ( map.width + 0.25 ), ( y - 0.6 ) * map.tileheight )
    end
  end

  -- horizontal helpers
  if not map.hideborderindicators then
    for x = 1, map.width do
      love.graphics.setColor( 255, 255, 255, 255 )
      love.graphics.setFont( fonts["button"] )
      love.graphics.print( x - 1, ( x - 0.6 ) * map.tilewidth, -map.tileheight / 2  )
      love.graphics.print( x - 1, ( x - 0.6 ) * map.tilewidth,  map.tileheight * ( map.height + 0.25 ) )
    end
  end

  -- in-map helpers
  for y = 1, map.height do
    for x = 1, map.width do
      if map.indicators[ ( y - 1 ) * map.width + x ] == 'x' then
        love.graphics.print( x - 1 + map.indicatorxoffset, ( x - 0.6 ) * map.tilewidth, ( y - 0.5 ) * map.tileheight  )
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

  game:drawoverlays()
end

function game.getbot()
  return bot
end

return game
