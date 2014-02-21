local utils = {}

function utils.buildMap( path )
  assert( love.filesystem.exists( path .. ".lua" ),
          "the level " .. path .. "does not exist!" )
  local mapdata = love.filesystem.load( path .. ".lua" )() -- executable output from tmx2lua
  local map = {}
  map.width = mapdata.width
  map.height = mapdata.height
  map.tilewidth = mapdata.tilewidth
  map.tileheight = mapdata.tileheight
  map.tileset = love.graphics.newImage( mapdata.tilesets[1].image.source )
  for i, tilelayer in ipairs( mapdata.tilelayers ) do
    if i == 1 then
      map.tiles = {}
      local tilesetwidth = mapdata.tilesets[1].image.width / mapdata.tilesets[1].tilewidth
      for j, tile in ipairs( tilelayer.tiles ) do
        local tx = ( tilelayer.tiles[j].id % tilesetwidth ) * map.tilewidth
        local ty = math.floor( tilelayer.tiles[j].id / tilesetwidth ) * map.tileheight
        map.tiles[j] = love.graphics.newQuad( tx, ty, mapdata.tilewidth, mapdata.tileheight, mapdata.tilesets[1].image.width, mapdata.tilesets[1].image.height )
      end
    end
  end
  return map
end

return utils
