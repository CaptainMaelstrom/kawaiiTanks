
gamera = require 'scripts/libs/gamera'
middleclass = require 'scripts/libs/middleclass'
tween = require 'scripts/libs/tween'
require 'scripts/helpers'
require 'scripts/aliases'
require 'scripts/states'
require 'scripts/mechs'

function love.load()
	states = {}
	flags = {}
	lg.setBackgroundColor(180,230,255)
	wx,wy,ww,wh = -800,-200,2400,1000
	gtime = 0
	joysticks = lj.getJoysticks()
	
	players = {Corgi(wx+ww/2, wy+wh/2,joysticks[1])}
	
	cam = {
		era = gamera.new(wx,wy,ww,wh),
		cx = players[1].x,
		cy	= players[1].y,
		lcx = players[1].x,
		lcy = players[1].y,
		lastMove = 0,
		scale = 1
	}
	
	callbacks.set()
	
	grounds = {
		{100,200,150,150},
		{450,450,100,100},
		{800,700,700,50},
		{-300,-50,100,600},
		{1200,-150,100,600}
	}
	platforms = {
		{100,350,600,12}, 
		{350,550,200,12},
		{-700,700,900,12},
		{-750,400,125,12},
		{-500,100,125,12},
		{1300,400,125,12}
	}
	
	layers = {}
	makeBGLayers()
	
end

function love.update(dt)
	flags[1] = "fps: " .. tostring(love.timer.getFPS())
	gtime = gtime+dt
	mx,my = lmo.getPosition()
	
	-- update players
	for i,p in ipairs(players) do
		p:update(dt)
		if p.x > wx+ww then p.x = wx+ww end
		if p.x < wx then p.x = wx end
		if p.y > wy+wh+100 then p.y = wy end
	end

	updateCamera(dt)
	tween.update(dt)
end

function love.draw()
	cam.era:draw(function(l,t,w,h)
		drawBG()
		drawColl()
		
		-- draw players
		for i,p in ipairs(players) do
			p:draw()
		end
	end)
	
	--debug
	lg.setColor(white)
	for i,f in ipairs(flags) do
		lg.print(tostring(flags[i]),20,18*i)
	end
end


--auxiliary functions


function updateCamera(dt)
	cam.cx,cam.cy = players[1].x,players[1].y
	if cam.lcx~=cam.cx or cam.lcy~=cam.cy then
		cam.lastMove = 0
		if cam.scale > 0.6 then
			cam.scale = cam.scale - (cam.scale/4)*dt
		end
	else
		cam.lastMove = cam.lastMove+dt
		if cam.lastMove > 2 then		--it's been longer than 3 seconds since the character stopped moving
			if cam.scale < 1.5 then
				cam.scale = cam.scale + cam.scale/10*dt
			end
		end
	end
	cam.lcx = cam.cx
	cam.lcy = cam.cy
	cam.era:setScale(0.5)
	cam.era:setPosition(cam.cx,cam.cy-50)
end

function drawBG()
	local cx,cy = cam.era:getPosition()
	lg.draw(layers[5],800-cx/8,80,0,1,1)
	lg.draw(layers[5],980-cx/8,50,0,1,1)
	lg.draw(layers[3],80-cx/3,-150,0,1,1)
	lg.draw(layers[3],200-cx/2,30,0,1,1)
	lg.setColor(40,185,95)
	lg.rectangle('fill',-800,sh/2,2400,500)
end

function drawColl()
	lg.setColor(110,90,20)
	for i,r in ipairs(platforms) do
		lg.rectangle('fill',r[1],r[2],r[3],r[4])
	end
	
	for i,r in ipairs(grounds) do
		local lw = math.min(math.ceil(r[3]/20),math.ceil(r[4]/20))+1
		lg.setColor(210,210,255)
		lg.radiusRectangle('fill',r[1],r[2],r[3],r[4],12)
		lg.setLineWidth(lw)
		lg.setColor(215,155,180)
		lg.radiusRectangle('line',r[1],r[2],r[3],r[4],12)
	end
end

function drawWBorder()
	lg.setLineWidth(2)
	lg.setColor(black)
	lg.rectangle('line',wx+10,wy+10,ww-20,wh-20)
end

function makeBGLayers()
	layers[5] = lg.newCanvas(128,1024)
	layers[4] = lg.newCanvas(256,1024)
	layers[3] = lg.newCanvas(256,1024)
	
	lg.setLineWidth(8)
	lg.setCanvas(layers[5])
		lg.setColor(100,255,155)
		lg.radiusRectangle('fill',14,28,80,800,30)
		lg.setColor(40,185,95)
		lg.radiusRectangle('line',14,28,80,800,30)
	lg.setCanvas(layers[3])
		lg.setColor(100,255,155)
		lg.radiusRectangle('fill',28,28,200,800,90)
		lg.setColor(40,185,95)
		lg.radiusRectangle('line',28,28,200,800,90)
	lg.setCanvas()
end






