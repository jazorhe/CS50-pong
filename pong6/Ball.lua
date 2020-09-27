Ball = Class{}


function Ball:init(x, y, width, height)

    self.startX = x
    self.startY = y
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.dx = math.random(2) == 1 and -100 or 100
    self.dy = math.random(-50, 50)

end



function Ball:update(dt)

    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

end

function Ball:reset()

    self.x = self.startX
    self.y = self.startY
    self.dx = math.random(2) == 1 and -100 or 100
    self.dy = math.random(-50, 50)

end


function Ball:render()

    love.graphics.rectangle('fill', self.x, self.y, 4, 4)

end