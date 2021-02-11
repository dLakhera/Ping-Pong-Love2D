--Paddle class to encapsulate the variables that define Paddle



Paddle = Class{}

function Paddle:init(x,y,width,height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height

	--self.dx = math.random(2) == 1 and 100 or -100
	self.dy = 0
end

function  Paddle:update(dt)
	
	if self.dy<0 then
		self.y = math.max(0, self.y + self.dy*dt)
		--self.y = self.y + self.dy*dt
	else 
		self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy*dt)
	end
	-- body
end

function Paddle:render()
	love.graphics.rectangle('fill',self.x,self.y,self.width,self.height)
	-- body
end