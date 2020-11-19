require "class"
paddle=class()
function paddle:init(x,y,width,height)
    self.x=x
    self.y=y
    self.width=width
    self.height=height
    self.dy=600
    self.score=0
end
function paddle:down(dt)
    self.y=math.min(virtual_height-20,self.y+paddle_speed*dt)
end
function paddle:up(dt)
    self.y=math.max(0,self.y-paddle_speed*dt)
end
function paddle:reset()
    self.y=virtual_height/2
    self.width=5
    self.height=20
end
function paddle:render()
    love.graphics.rectangle('fill',self.x,self.y,self.width,self.height)
end