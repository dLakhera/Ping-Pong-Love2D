--[[
    GD50 2018
    Pong Remake

    pong-2
    "The Rectangle Update"

    -- Main Program --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Originally programmed by Atari in 1972. Features two
    paddles, controlled by players, with the goal of getting
    the ball past your opponent's edge. First to 10 points wins.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on 
    modern systems.
]]

-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'push'

Class = require 'class'

require 'Paddle'
require 'Ball'


WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 150

--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]
function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')


    math.randomseed(os.time()) 
    -- more "retro-looking" font object we can use for any text
    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf',32)
    -- set LÖVE2D's active font to the smallFont obect
    love.graphics.setFont(smallFont)

    -- initialize window with virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = true,
        resizable = false,
        vsync = true
    })

    sounds = {
    	['paddle_hit'] = love.audio.newSource('sounds/paddle_hit','static'),
    	['wall_hit'] = love.audio.newSource('sounds/wall_hit','static'),
    	['score'] = love.audio.newSource('sounds/score','static')
    }

    love.window.setTitle('dFs')
    player1Score = 0
    player2Score = 0

    winnningPlayer = 1
    player1 = Paddle(10,30,5,20)
    player2 = Paddle(VIRTUAL_WIDTH-10,VIRTUAL_HEIGHT-30,5,20)


    ball = Ball(VIRTUAL_WIDTH/2 - 2,VIRTUAL_HEIGHT/2 - 2, 4, 4)

    gameState = 'start'
end

--[[
    Keyboard handling, called by LÖVE2D each frame; 
    passes in the key we pressed so we can access.
]]


function love.update(dt)

	if love.keyboard.isDown('w') then
		-- player1Y = math.max( 0 , player1Y + -PADDLE_SPEED*dt)
		player1.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('s') then
		-- player1Y = math.min(VIRTUAL_HEIGHT - 20, player1Y + PADDLE_SPEED*dt)
		player1.dy = PADDLE_SPEED	
	else
		player1.dy = 0
	end

	if love.keyboard.isDown('up') then
		-- player2Y = math.max( 0 , player2Y + -PADDLE_SPEED*dt)
		player2.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('down') then
		-- player2Y = math.min(VIRTUAL_HEIGHT - 20,player2Y + PADDLE_SPEED*dt)
		player2.dy = PADDLE_SPEED
	else 
		player2.dy =0
	end

	if gameState == 'play' then

-- collision check for ball and paddles
		if ball:collides(player1) then
			ball.dx = -ball.dx * 1.10
			ball.x = player1.x + 5

			if ball.dy<0 then 
				ball.dy = -math.random(10,150)
			else
				ball.dy = math.random(10,150)
			end
			
			sounds['paddle_hit']:play()
		end

		if ball:collides(player2) then
			ball.dx = -ball.dx * 1.10
			ball.x = player2.x - 4

			if ball.dy<0 then 
				ball.dy = -math.random(10,150)
			else
				ball.dy = math.random(10,150)
			end

			sounds['paddle_hit']:play()

		end
-----------------

-- collision check for ceiling and floor
		if ball.y <= 0 then 
			ball.y = 0
			ball.dy = -ball.dy

			sounds['wall_hit']:play()
		end

		if ball.y >= VIRTUAL_HEIGHT - 4 then
			ball.y = VIRTUAL_HEIGHT - 4
			ball.dy = -ball.dy

			sounds['wall_hit']:play()
		end
-- check if game ends

		if ball.x < 0 then 
			player2Score = player2Score + 1

			sounds['score']:play()
			if player2Score == 10 then
				winnningPlayer = 2 
				gameState = 'done'
			else
				ball:reset()
				gameState = 'start'
			end
		end

		if ball.x >= VIRTUAL_WIDTH then
			player1Score = player1Score + 1

			sounds['score']:play()
			if player1Score == 10 then
				winnningPlayer = 1 
				gameState = 'done'
			else
				ball:reset()
				gameState = 'start'
			end
		end
		

		ball:update(dt)
	end

	player2:update(dt)
	player1:update(dt)
	-- body
end


function love.keypressed(key)
    -- keys can be accessed by string name
    if key == 'escape' then
        -- function LÖVE gives us to terminate application
        love.event.quit()

    elseif key == 'enter' or key == 'return' then
    	if gameState == 'start' then
    		gameState = 'play'
    	elseif gameState == 'play' then
    		ball:reset()
    		gameState = 'start'
    	elseif gameState == 'done' then
    		-- gameState = 'start'
    		player1Score = 0
    		player2Score = 0
    		ball:reset()
    		gameState = 'start'
		end
    end
end


function love.draw()
    -- begin rendering at virtual resolution
    push:apply('start')

    -- clear the screen with a specific color; in this case, a color similar
    -- to some versions of the original Pong
    love.graphics.clear(40, 45, 52, 0)

    -- draw welcome text toward the top of the screen
	love.graphics.setColor(40,45,255,255)
    love.graphics.setFont(smallFont)
    if gameState == 'start' then
	    love.graphics.printf('Pong!', 0, 20, VIRTUAL_WIDTH, 'center')
	    love.graphics.printf('Press Enter <_| to start!', 0, 30, VIRTUAL_WIDTH, 'center')
		
	elseif gameState == 'play' then
		love.graphics.printf('Play pong!', 0, 20, VIRTUAL_WIDTH, 'center')

	elseif gameState == 'done' then
		love.graphics.printf('The player ' .. tostring(winnningPlayer) .. ' wins!!', 0, 30, VIRTUAL_WIDTH, 'center')		
    end

    love.graphics.setFont(scoreFont)
	love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)

    player2:render()
    
    player1:render()
    
    ball:render()
    -- end rendering at virtual resolution

    displayFPS()
    push:apply('end')
end


function  displayFPS()
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0,255,0,255)
	-- love.graphics.print('Player 1: ' .. tostring(player1Score),10,20 )
	-- love.graphics.print('Player 2: ' .. tostring(player2Score), VIRTUAL_WIDTH-45, 20)
	love.graphics.setFont(smallFont)
	love.graphics.printf('***Madhu\'s Game***',0,10,VIRTUAL_WIDTH,'center')
	love.graphics.setFont(smallFont)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()),10,10)
	-- body
end