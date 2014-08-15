require 'level'

local level

function love.load()
    level = Level:fromString([[
RRRRRRRRRRRRRRRRRRRRRRRR
B........Q.............B
B................BBB...B
B......................B
B............BBB.......B
B......................B
B......................B
B......................B
B.........BBBB.........B
B......................B
B......................B
B......................B
B.......BBB............B
B......................B
B...BBB................B
B...........O...P......B
GGGGGGGGGGGGGGGGGGGGGGGG]])
end

function love.update(dt)
    level:update(dt)
end

function love.draw()
    level:draw()
end

