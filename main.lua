--[[
	S→C
		0:ping
		1:you quited

		9:system message
		10:user say
	C→S
		0:ping
		1:My name
		2:I want quit
		10:my message
]]
local utf8=require"utf8"
local enet=require"enet"

local gc=love.graphics
local Timer=love.timer.getTime

local int=math.floor
local sub,find=string.sub,string.find
local ins,rem=table.insert,table.remove
local byte=string.byte

local host=enet.host_create()
host:connect("localhost:626")

gc.setFont(gc.setNewFont("font.ttf",20))
love.keyboard.setKeyRepeat(true)

local color={
	red={.8,0,0},
	yellow={.7,.7,0},
	blue={0,0,.8},
	black={0,0,0},
	lightGrey={.8,.8,.8},
}
local input,mesList="",{}
local drag=0
local newMes--if there is a new messasge
local texts={}
local mesHead=""
local connected=false
local name,quitTime
local needDraw

local function pushMes(mes)
	mesList[#mesList+1]=mes
end
local function pushText(t,clr)
	ins(texts,{clr,t})
	if drag>0 then
		drag=drag+1
		newMes=true
	end
	needDraw=true
end
local function clearText()
	texts={}
	needDraw=true
	collectgarbage()
end
local command={
	cls=clearText,
	quit=function()
		pushMes("\002")
		quitTime=Timer()
	end
}
function love.wheelmoved(_,y)
	y=int(y+.5)
	if y~=0 then
		drag=drag+y
		if drag>#texts-10 then drag=#texts-10 end
		if drag<0 then drag=0 end
		if drag==0 then newMes=false end
	end
	needDraw=true
end
function love.keypressed(t)
	if t=="backspace"then
		local offset=utf8.offset(input,-1)
		if offset then
			input=sub(input,1,offset-1)
			needDraw=true
		end
	elseif t=="return"then
		if connected and #input>0 then
			if byte(input)==47 then
				local code=command[sub(input,2)]
				if code then code()end
			elseif name then
				pushMes("\010"..input)
			else
				name=input
				mesHead=name..":"
				pushMes("\001"..input)
			end
			input=""
		end
	elseif t=="up"then
		if drag<#texts-10 then
			drag=drag+1
			needDraw=true
		end
	elseif t=="down"then
		if drag>0 then
			drag=drag-1
			if drag==0 then newMes=false end
			needDraw=true
		end
	end
end
function love.textinput(t)
	input=input..t
	while utf8.len(input)>64 do
		love.keypressed("backspace")
	end
	needDraw=true
end

function love.run()
	local PUMP,POLL=love.event.pump,love.event.poll
	local WAIT=love.timer.sleep
	local event
	pushText("Connecting...",color.red)
	return function()
		PUMP()
		for e,a,b in POLL()do
			if e=="quit"then
				if connected then
					pushMes("\002")
					quitTime=Timer()
				else
					return 1
				end
			elseif love[e]then
				love[e](a,b)
			end
		end
		if needDraw then
			gc.clear(1,1,1)
			local M=#texts-drag
			local _=1
			::L::if _<=10 and M>0 then
				local h=525-50*_
				gc.printf(texts[M],15,h,750)
				gc.setColor(color.black)
				gc.line(0,h,799,h)
				_=_+1
				M=M-1
				goto L
			end

			gc.setColor(color.black)
			gc.rectangle("fill",0,525,800,3)--Dividing line
			gc.printf(mesHead..input,15,530,760)--Input

			if #texts-drag>10 then--Up arrow
				gc.print("V",775,560,nil,nil,-1)
			end
			if drag>0 then--Down arrow
				if newMes then gc.setColor(color.yellow)end
				gc.print("V",775,560)
			end

			if M>10 then--Scroll Bar
				local h=525*10/M
				gc.setColor(color.lightGrey)
				gc.rectangle("fill",785,(525-h)*(1-drag/(M-10)),15,h)
			end
			gc.present()
			needDraw=false
		end

		::L::event=host:service()
		if event then
			if event.type=="receive"then
				local data=event.data
				local head=byte(data,1)
				data=sub(data,2)
				if head==0 then
					event.peer:send("\000P")
				elseif head==1 then
					event.peer:disconnect()
				elseif head==9 then
					pushText(data,color.red)
				elseif head==10 then
					if name then
						local p,e=find(data,name..":")
						if p==1 then
							data=sub(data,e+1)
							pushText(data,color.blue)
						else
							pushText(data,color.black)
						end
					else
						pushText(data,color.black)
					end
				end
				if mesList[1]then
					event.peer:send(rem(mesList,1))
				end
			elseif event.type=="connect"then
				clearText()
				pushText("[Connected]",color.red)
				mesHead="Input your nickname:"
				connected=true
			elseif event.type=="disconnect"then
				return 1
			end
			goto L
		end
		WAIT(.0626)
		if quitTime and Timer()-quitTime>1 then
			return 1
		end
	end
end