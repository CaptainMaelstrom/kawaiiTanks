------------------------------------------------------State functions

function pushState(state)
	table.insert(states,state)
	state:setCallbacks()
end

function switchState(state)	--switches with the state on top of the stack
	popState()
	pushState(state)
end

function popState()
	states[#states]:destroy()
	table.remove(states,#states)
	
	if next(states) then
		states[#states]:setCallbacks()
	end
end

function updateStates(dt)
	for i,s in ipairs(states) do
		s:update(dt)
	end
end

function drawStates()
	for i,s in ipairs(states) do
		s:draw()
	end
end

-------------------------------------------------------State Classes
--[[
There are two ways to implement the actual classes:
1.) You can have a superclass that has the needed functions and members defined and then make subclasses that inherit/override those members and functions
2.) You can make StateClasses and just make sure they always have the appropriate members/methods.

Regardless, if you create an instance of a class, and intend to use it with the state functions and global states table, make sure it has members:
alwaysUpdate = true/false
alwaysDraw = true/false

and make sure it has methods:

update
draw
setCallbacks
destroy

I prefer the second method, so my state classes might look like:
]]

TitleState = class('TitleState')

function TitleState:initialize()
	self.alwaysUpdate = false
	self.alwaysDraw = true
end

function TitleState:update(dt)
	
end

function TitleState:draw()
	
end

function TitleState:destroy()
	
end

function TitleState:setCallbacks()
	
end

-----------------------------------

PlayState = class('PlayState')

function PlayState:initialize()
	self.alwaysUpdate = false
	self.alwaysDraw = true
end

function PlayState:update(dt)
	
end

function PlayState:draw()
	
end

function PlayState:destroy()
	
end

function PlayState:setCallbacks()

end
