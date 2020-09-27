Score = Class{}

function Score:init(x, y, score) 

    self.x = x
    self.y = y
    self.score = score

end


function Score:update(dt)



end


function Score:render()

        love.graphics.setFont(scoreFont)
        love.graphics.print(self.score, self.x, self.y)

end

