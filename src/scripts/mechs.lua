--mechs

-- x walk
--  run
--  crouch
-- x drop platform
--  shield
--  shoot
--  shoot2
--  dash
--  cycleWeapon
--  cycleItem
--  useItem
--  melee
--  interact
-- x jump
--  aiming


Corgi = class('Corgi')

function Corgi:initialize(xx, yy, joystickv)
	self.x, self.y = xx, yy	--xx,yy is the point of Corgi's feet
	self.vx, self.vy = 0,0
	self.hitbox = {xx-30,yy-100,60,100}
	self.facing = 1
	
	--class constants
	self.ACCX = 1550
	self.MAXVELY = 1600
	self.MAXVELX = 500
	self.GRAVITY = 1100
	self.FRICTION = 0.85
	
	self.input = InputHandler(self,joystickv)
	
	self.jump = function(self) self.vy = -900 end
	
	if joystickv then
		callbacks.register('gamepadpressed', function(joystick,button) if (button=='a'  or button=='dpup') and self.grounded then self:jump() end end)
	else
		callbacks.register('keypressed',function(key,isrepeat) if (key==' ' or key=='w') and self.grounded then self:jump() end end)
	end
end

function Corgi:update(dt)
	--determine accelerations and velocities
	self.input:update(dt)
	-- if self.grounded then
		self.vy = love.math.clamp(-self.MAXVELY,self.vy + self.GRAVITY*dt, self.MAXVELY)
		if self.input.right then self.vx = love.math.clamp(-self.MAXVELX*self.input.right/100,self.vx+(self.input.right)/100*self.ACCX*dt,self.MAXVELX*self.input.right/100) end
		if self.input.left then self.vx = love.math.clamp(-self.MAXVELX*self.input.left/100,self.vx-(self.input.left/100)*self.ACCX*dt,self.MAXVELX*self.input.left/100) end
		if not self.input.left and not self.input.right then self.vx = self.vx*self.FRICTION end
	-- else
		-- self.vy = lm.clamp(-800,self.vy+450*dt,800)
	-- end
	
	--apply velocities
	self.x, self.y = self.x + self.vx*dt, self.y + self.vy*dt
	self.hitbox = {self.x-30,self.y-100,60,100}
	
	--check collisions (and fix character position if collision detected)
	self:checkCollisions(dt)
end

function Corgi:draw()
	local clr = {180,180,250}
	lg.setColor(0,0,255)
	lg.rectangle('line',self.x-30,self.y-100,60,100)
	
	-- draw order: left leg, left arm, right leg, chassis, right arm, head
	lg.setColor(color.lightness(clr,-70))
	lg.draw(img.leg,self.x+self.facing*12,self.y-25,0,													self.facing*0.20,0.20,512/2,512/2)
	lg.draw(img.arm,self.x+self.facing*36,self.y-90-math.sin((gtime+.05)*10)*1,0,		self.facing*0.20,0.20,512/2,512/2)
	lg.setColor(clr)
	lg.draw(img.leg,self.x-self.facing*12,self.y-25,0,													self.facing*0.20,0.20,512/2,512/2)
	lg.setColor(color.lightness(clr,-40))
	lg.draw(img.chassis,self.x-self.facing*8,self.y-80-math.sin(gtime*10)*1,0,				self.facing*0.20,0.20,512/2,512/2)
	lg.setColor(clr)
	lg.draw(img.arm,self.x-self.facing*30,self.y-85-math.sin((gtime+.05)*10+.5)*1,0,	self.facing*0.20,0.20,512/2,512/2)
	lg.setColor(white)
	lg.draw(img.corgi,self.x,self.y-130-math.sin((gtime-.06)*10+1)*2,0,						self.facing*0.25,0.25,512/2,512/2)

	
	lg.setColor(white)
	lg.setPointSize(5)
	lg.point(self.x,self.y)
end

function Corgi:checkCollisions(dt)
	local ox,oy,dx,dy = self.x - self.vx*dt,self.y - self.vy*dt,0,0
	self.grounded = nil
	for i,r in ipairs(grounds) do
		if boxBox(self.hitbox,r) then
			if (ox+30) <= r[1] then
				dx = (self.x+30) - r[1]
				dy = (dx/(self.vx*dt))*self.vy*dt
				self.x = self.x - dx
				self.vx = 0
			elseif (ox-30) >= (r[1]+r[3]) then
				dx = (self.x-30) - (r[1]+r[3])
				dy = (dx/(self.vx*dt))*self.vy*dt
				self.x = self.x - dx
				self.vx = 0
			elseif oy <= r[2] then
				dy = self.y-r[2]
				dx = (dy/(self.vy*dt))*self.vx*dt
				self.y = self.y - dy
				self.vy = 0
				self.grounded = true
			elseif (oy-100) >= (r[2]+r[4]) then
				dy = (self.y-100) - (r[2]+r[4])
				dx = (dy/(self.vy*dt))*self.vx*dt
				self.y = self.y - dy
				self.vy = 0
			end
			self.hitbox = {self.x-30,self.y-100,60,100}
		end
	end
	
	--platforms
	for i,r in ipairs(platforms) do
		if boxBox(self.hitbox,r) then
			if not self.input.down and (self.y-self.vy*dt) <= r[2] then 
				self.y = r[2]
				self.hitbox = {self.x-30,self.y-100,60,100}
				self.vy = 0
				self.grounded = true
			end
		end
	end
end


--auxilliary classes

InputHandler = class('InputHandler')

function InputHandler:initialize(owner, joystick)
	self.owner = owner
	self.jstick = joystick
end

function InputHandler:update(dt)
	self.right,self.left,self.down = nil,nil,nil
	if self.jstick then		--either using a gamepad or the keyboard/mouse
		if self.jstick:getAxis(1) > 0.15 then
			self.right = self.jstick:getAxis(1)*100 self.owner.facing = 1
		elseif self.jstick:getAxis(1) < -0.15 then
			self.left = -self.jstick:getAxis(1)*100 self.owner.facing = -1
		end
		if self.jstick:isGamepadDown('dpleft') and not self.jstick:isGamepadDown('dpright') then self.left = 100 self.owner.facing = -1 end
		if self.jstick:isGamepadDown('dpright') and not self.jstick:isGamepadDown('dpleft') then self.right = 100 self.owner.facing = 1 end
		if self.jstick:isGamepadDown('dpdown') then self.down = true end
	else
		if lk.isDown('a') and not lk.isDown('d') then self.left = 100 self.owner.facing = -1 end
		if lk.isDown('d') and not lk.isDown('a') then self.right = 100 self.owner.facing = 1 end
		if lk.isDown('s') then self.down = true end
	end
end








