require 'vendor/AnAL'

local bot = {}

function bot.init()
  bot.x = 1
  bot.y = 1
  bot.state = 'idle'
  bot.anims = {}
  bot.anims[ 'mr' ] = newAnimation( love.graphics.newImage( "art/spritesheets/rob.png" ), 64, 64, 0.5, 4 )
  bot.anims[ 'ml' ] = newAnimation( love.graphics.newImage( "art/spritesheets/rob_l.png" ), 64, 64, 0.5, 4 )
  bot.anim = bot.anims[ 'mr' ]
end

function bot.updateAnim( dx, dy )
  if dx > 0 then bot.anim = bot.anims[ 'mr' ]
  elseif dx < 0 then bot.anim = bot.anims[ 'ml' ] end
end

return bot
