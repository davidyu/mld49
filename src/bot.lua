require 'vendor/AnAL'

local bot = {}

function bot.init()
  bot.x = 1
  bot.y = 1
  bot.state = 'idle'
  bot.sheet = love.graphics.newImage( "art/spritesheets/rob.png" )
  bot.anims = {}
  bot.anims[ 'mr' ] = newAnimation( bot.sheet, 64, 64, 0.5, 4 )
  bot.anim = bot.anims[ 'mr' ]
end

function bot.smoothmove()
end

function bot.fastmove()
end


return bot
