pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--main
function _init()
 t=0
 
 dirx={-1,1,0,0}
 diry={0,0,-1,1}
 
 slime_ani={64}
 slime_hp={}
 slime_atk={}
 slime_mov={2}
 
 debug={}
 
	menu_init()
end

function menu_init()
	_upd=update_menu
	_drw=draw_menu
end

function game_start()
 c_ani={48,49,50,51}
 cx=7
 cy=7
 
 slimes={}
 
 for x=0,15 do
 	for y=0,15 do
 		for i=1,#slime_ani do
 			if mget(x,y)==slime_ani[i] then
 			 addslime(i,x,y)
 			 mset(x,y,1)
			 end
			end
		end
 end
 
 ani_t=0
 slctd=nil
 mvdist=0
 locstore={}
 
	_upd=update_game
	_drw=draw_game
end
-->8
--update
function _update60()
 t+=1
 _upd()
 if (#debug>4) debug={}
end

function update_menu()
	if (btn(❎)) game_start()
end

function update_game()
 if slctd then 
	 c_ani={32,33,34,35}
 else
	 c_ani={48,49,50,51}
	end
	
	for i=0,3 do
		if btnp(i) then
		 movecursor(i)
		end
	end
	
	if btnp(❎) then
		local is_slime=getslime(cx,cy)	
		if not slctd and is_slime then
	 	slctd=is_slime
	 	locstore[1],locstore[2]=
	 	 slctd.x,slctd.y
		 mvdist=slctd.mr
--  elseif slctd then
--		 _upd=update_slime
		end
	end
	
	if btnp(🅾️) then
		--endturn/menu
		if slctd then
			if mvdist<slctd.mr then
			 slctd.x,slctd.y=
			  locstore[1],locstore[2]
		  cx,cy=slctd.x,slctd.y
			 mvdist=slctd.mr
		 else
		  slctd=nil
		  _upd=update_game
		 end
		end
	end
end

function update_slime()
 ani_t=min(ani_t+0.05,1)
 slctd.mov(slctd,ani_t)
 
 if ani_t==1 then
 	_upd=update_game --⬅️aiturn goes here
 end
end
-->8
--draw
function _draw()
 _drw()
 color(8)
	foreach(debug,print)
end

function draw_menu()
 cls()
	print("press ❎ to start",31,63,7)
end

function draw_game()
	cls()
	map()
	for s in all(slimes) do
		drawspr(animate(s.ani),
		        s.x*8+s.ox,s.y*8+s.oy,
		        s.flp)
	end
	drawspr(
	 animate(c_ani),
	 cx*8,
	 cy*8,false)
end

function drawspr(_spr,_x,_y,_flip)
	palt(0,false)
	palt(6,true)
	spr(_spr,_x,_y,1,1,_flip)
	pal()
end

function animate(ani)
	return ani[flr(t/15)%#ani+1]
end
-->8
--utility
function iswalkable(x,y,mode)
 if (mode==nil) mode=""
 
 if inbounds(x,y) then
  local tle=mget(x,y)
  if fget(tle,0)==false then
   if mode=="checkslime" then
    local slime=getslime(x,y)
    return slime==false or slime!=slctd
   end
   return true
  end
 end
 return false
end

function inbounds(x,y)
 return not (x<0 or y<0 or x>15 or y>15)
end
-->8
--slimes
function addslime(typ,_x,_y)
	local s={
	 x=_x,
	 y=_y,
	 ox=0,
	 oy=0,
	 flp=false,
	 mr=slime_mov[typ],
	 mov=nil,
	 hasmvd=false,
	 hasatkd=false,
	 ani={}
	}
	for i=0,3 do
		add(s.ani,slime_ani[typ]+i)
	end
	add(slimes,s)
end

function getslime(x,y)
	for s in all(slimes) do
		if s.x==x and s.y==y then
			return s
		end
	end
	return nil
end

function moveslime(s,dx,dy)
	s.x+=dx
	s.y+=dy
	
	slimeflip(s,dx)
	s.sox,s.soy=-dx*8,-dy*8
--	s.ox,s.oy=s.sox,s.soy
	s.mov=mov_walk
	ani_t=0
	_upd=update_slime
end

function mov_walk(s,at)
	s.ox=s.sox*(1-at)
	s.oy=s.soy*(1-at)
end

function slimeflip(s,dx)
	if dx<0 then
	 s.flp=true
	elseif dx>0 then
		s.flp=false
	end
end
-->8
--ui/cursor
function movecursor(i)
	if slctd and mvdist>0 then
		local dx,dy=dirx[i+1],diry[i+1]
		local destx,desty=cx+dx,cy+dy
		if iswalkable(destx,desty,"checkslime") then
		 cx,cy=destx,desty
		 moveslime(slctd,dx,dy)
		 mvdist-=1
		end			 
	elseif not slctd then
	 cx+=dirx[i+1]
	 cy+=diry[i+1]
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000dddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000dddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000dddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000dddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666bb6666666666666666666666bb666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66333366666bb666666bb66666333366000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
63666636663333666633336663666636000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b366663b6b3663b66b3663b6b366663b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b366663b6b3663b66b3663b6b366663b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
63666636663333666633336663666636000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66333366666bb666666bb66666333366000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666bb6666666666666666666666bb666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33b66b33666666666666666633b66b33000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
36666663633bb336633bb33636666663000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b666666b6366663663666636b666666b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666666666b6666b66b6666b666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666666666b6666b66b6666b666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b666666b6366663663666636b666666b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
36666663633bb336633bb33636666663000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33b66b33666666666666666633b66b33000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6666666666ccc6666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66ccc6666c0ccc6666ccc66666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c0ccc666c0ccc666c0ccc666cccccc6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0ccccc66ccccc66c0ccccc6c00ccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccc66ccccc66ccccccc6cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6ccccc6666ccc6666ccccc666cccccc6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010140010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
