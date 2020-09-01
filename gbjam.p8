pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--slime tactics
--by civz3r0 and jordab
function _init()
 t=0
 
 dirx,diry={-1,1,0,0,1,1,-1,-1}
          ,{0,0,-1,1,-1,1,1,-1}
 
 --slime-opedia
 --friendly: 1-??
 --enemies: ??-??
 --sword slime: type 1
 --spear slime: type 2
 
 slime_ani={64,80}
 slime_hp={2,2}
 slime_atk={2,1}
 slime_range={
  {{1,0}},
  {{1,0},{2,0}}
 }
 slime_cleave={
  false,
  true
 }
 slime_mov={2,2}
 
 debug={}
 
--	menu_init()
 game_start() --to simplify testing
end

function menu_init()
	_upd,_drw=update_menu
	         ,draw_menu
end

function game_start()
 c_ani,cx,cy={48,49,50,51},7,7
 
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
 
 ani_t,slctd,mvdist=0,nil,0
 
 locstore,floats,
 winds,menuwind={},{},{},nil
 
	_upd,_drw=update_game
	         ,draw_game
end
-->8
--update
function _update60()
 t+=1
 _upd()
 if (#debug>4) debug={}
 dofloats()
end

function update_menu()
	if (btn(❎)) game_start()
end

function update_game()
	if menuwind then
		if btnp(❎) then
			menuwind.dur=0
			menuwind=nil
		end
	else
	 for i=0,3 do
			if btnp(i) then
			 movecursor(i)
			end
		end
	
		if btnp(❎) then
			local is_slime=getslime(cx,cy)	
			if not slctd and is_slime 
			and not is_slime.hasmvd then
		 	slctd=is_slime
		 	locstore[1],locstore[2],mvdist=
		 	 slctd.x,slctd.y,slctd.mr
	  elseif slctd 
	  and not slctd.hasatkd then
	   slctd.hasmvd=true
	   slimeatk(slctd)
			end
		end
		
		if btnp(🅾️) then
			if slctd then
				if mvdist<slctd.mr then
				 slctd.x,slctd.y=
				  locstore[1],locstore[2]
			  cx,cy,mvdist=slctd.x,slctd.y,
			               slctd.mr
			 else
			  slctd=nil
			 end
			else
			 showmenu()
			end
		end
	end
end

function update_slime()
 ani_t=min(ani_t+0.05,1)
 for s in all(slimes) do
 	if s.mov then
 		s:mov()
		end
 end
 
 if ani_t==1 then
  for s in all(slimes) do
   if s.mov==mov_bump then
    s.hasatkd=true
    slctd=nil
   end
  	s.mov=nil
  end
  _upd=update_game
 end
end

function update_aiplan()
	
end

function update_aiturn()
	
end
-->8
--draw
function _draw()
 palt(0,false)
	palt(6,true)
	pal(0,140,1)
 _drw()
 drawind()
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
		drawspr(s.ani,
		        s.x*8+s.ox,s.y*8+s.oy,
		        s.flp)
	end
	if (not slctd) drawspr(c_ani,cx*8,cy*8,false)
	
	for f in all(floats) do
		oprint8(f.txt,f.x,f.y,f.c,0)
	end
end

function drawspr(_spr,_x,_y,_flip)
	spr(_spr[flr(t/15)%#_spr+1],_x,_y,1,1,_flip)
end
-->8
--utility
function iswalkable(x,y,mode)
 local mode=mode or ""
 
 if inbounds(x,y) then
  local tle=mget(x,y)
  if not fget(tle,0) then
   if mode=="checkslime" then
    local slime=getslime(x,y)
    return not slime or slime!=slctd
   end
   return true
  end
 end
 return false
end

function inbounds(x,y)
 return not (x<0 or y<0 or x>15 or y>15)
end

function rectfill2(_x,_y,_w,_h,_c)
 rectfill(_x,_y,_x+max(_w-1,0),_y+max(_h-1,0),_c)
end

function oprint8(_t,_x,_y,_c,_c2)
 for i=1,8 do
  print(_t,_x+dirx[i],_y+diry[i],_c2)
 end 
 print(_t,_x,_y,_c)
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
	 range=slime_range[typ],
	 cleave=slime_cleave[typ],
	 atk=slime_atk[typ],
	 hp=slime_hp[typ],
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
	s.ox,s.oy=s.sox,s.soy
	s.mov=mov_walk
	ani_t=0
	_upd=update_slime
end

function slimebump(s,dx,dy)
	slimeflip(s,dx)
	s.sox,s.soy=dx*8,dy*8
	s.ox,s.oy=0,0
	s.mov=mov_bump
end

function mov_walk(s)
 local tme=1-ani_t
	s.ox=s.sox*tme
	s.oy=s.soy*tme
end

function mov_bump(s)
 local tme=ani_t>0.5 
       and 1-ani_t 
       or ani_t
 s.ox=s.sox*tme
	s.oy=s.soy*tme
end

function slimeflip(s,dx)
	s.flp=dx==0 and s.flp or dx<0
end

function slimeatk(s)
 local sr=s.range
 local srx=sr[1][1]
 slimeflip(s,srx)
	s.sox,s.soy=srx*8,sr[1][2]*8
	s.ox,s.oy=0,0
	s.mov=mov_bump
	ani_t=0
	_upd=update_slime
	for a in all(sr) do
	 local tx,ty=s.x+a[1],s.y+a[2]
	 local target=getslime(tx,ty)
		if target then
		 addfloat("-"..s.atk,tx*8,ty*8,12)
			target.hp-=s.atk
			if (not s.cleave) return 
		end
	end
end
-->8
--ui/cursor
function movecursor(i)
	local dx,dy=dirx[i+1],diry[i+1]
	local destx,desty=cx+dx,cy+dy
	if slctd and mvdist>0 then
		if iswalkable(destx,desty,"checkslime") then
		 cx,cy=destx,desty
		 moveslime(slctd,dx,dy)
		 mvdist-=1
		end			 
	elseif not slctd and
	inbounds(destx,desty) then
	 cx=destx
	 cy=desty
	end
end

function addfloat(_txt,_x,_y,_c)
 add(floats,{txt=_txt,x=_x,y=_y,c=_c,ty=_y-10,t=0})
end

function dofloats()
 for f in all(floats) do
  f.y+=(f.ty-f.y)/10
  f.t+=1
  if f.t>70 then
   del(floats,f)
  end
 end
end

function doburst()
	for b in all(bursts) do
		b.t+=1
		if b.t>70 then
			del(bursts,b)
		end
	end
end

function addwind(_x,_y,_w,_h,_txt)
 local w={x=_x,
          y=_y,
          w=_w,
          h=_h,
          txt=_txt}
 add(wind,w)
 return w
end

function drawind()
 for w in all(wind) do
  local wx,wy,ww,wh=w.x,w.y,w.w,w.h
  rectfill2(wx,wy,ww,wh,0)
  rect(wx+1,wy+1,wx+ww-2,wy+wh-2,6)
  wx+=4
  wy+=4
  clip(wx,wy,ww-8,wh-8)
  for i=1,#w.txt do
   local txt=w.txt[i]
   print(txt,wx,wy,6)
   wy+=6
  end
  clip()
 
  if w.dur then
   w.dur-=1
   if w.dur<=0 then
    local dif=w.h/4
    w.y+=dif/2
    w.h-=dif
    if w.h<3 then
     del(wind,w)
    end
   end
  else
   if w.butt then
    oprint8("❎",wx+ww-15,wy-1+min(sin(time())),6,0)
   end
  end
 end
end

function showmenu()
	menuwind=addwind(36,50,54,13,{"end turn?"})
 menuwind.butt=true
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000dddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700007007000dddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000770000dddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000770000dddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700007007000dddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000dddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
67666676070000700c0000c0070000700c0000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66c66c6600c00c000070070000c00c00007007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6667c6660007c000000c70000007c000000c70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666c7666000c70000007c000000c70000007c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66c66c6600c00c000070070000c00c00007007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
67666676070000700c0000c0070000700c0000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666cc666000cc0000000000000000000000cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6600006600000000000cc000000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c066660cc000000c0c0000c00c0000c0c000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c066660cc000000c0c0000c00c0000c0c000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6600006600000000000cc000000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666cc666000cc0000000000000000000000cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c66c0000c00c00000000000000000000c00c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0666666000000000000cc000000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c666666cc000000c0000000000000000c000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666000000000c0000c00c0000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666000000000c0000c00c0000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c666666cc000000c0000000000000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0666666000000000000cc000000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c66c0000c00c00000000000000000000c00c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666000000000000070000000070000000000000000000000000000000000000000000080800000000000008080000000000000000000000000000000000
66ccc7c600ccc7c000ccc70000000070000000700000000000000000000000000000000000080800000808000008080000080800000000000000000000000000
66ccc7c600ccc7c00c0cc7c000cccc70000000700000000000000000000000000000000000888880000808000088888000080800000000000000000000000000
6c0cc7c60c0cc7c00c0cc7c00c0ccc7c0ccccc700000000000000000000000000000000008080880008888800808088000888880000000000000000000000000
c0ccc7ccc0ccc7cc0ccc7070c0ccc707c00ccc700000000000000000000000000000000000888880080808000088880008080880000000000000000000000000
cccc707ccccc707c0cccc7c0cccccc7cccccc7000000000000000000000000000000000080888808008880800088808080888808000000000000000000000000
6cccc7c60cccc7c000cccc000ccccc000ccccc700000000000000000000000000000000000888808008880800088808000088808000000000000000000000000
66666666000000000000000000000000000000000000000000000000000000000000000000800800000880000080080000088000000000000000000000000000
666666660000000000000000000000000000000000c0000000c0000000c0000000c0000000404404000000000000000000404404000000000000000000000000
666607760000077000000770000007700000077000c0000000c0000000c0000000c0000044444044004044040040440444444044000000000000000000000000
66c0777700c0777700c0777700c0777700c077770ccccc700ccccc700ccccc700ccccc7044404440444440444444404444404440000000000000000000000000
6cc070770cc070770cc070770cc070770cc0707707ccc07007ccc07007ccc07007ccc07000444400444044404440444000444400000000000000000000000000
c0c07077c0c07077c0c07077c0c07077c0c070770770007007700070077000700770007004444004004444000044440004444004000000000000000000000000
ccc07777ccc07777ccc07777ccc07777ccc07777077cc777077cc777077cc777077cc77700444440044444440444444400444440000000000000000000000000
6ccc07760ccc07700ccc07700ccc07700ccc077007cccc0007cccc0007cccc0007cccc0000444444004444440044444400444444000000000000000000000000
66666666000000000000000000000000000000000ccccc000ccccc000ccccc000ccccc0000400404004004040040040400400404000000000000000000000000
60006666000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6600066600077707000000000000000000000000070c0c0000000000000000000000000004004440000000000000000000000000000000000000000000000000
600000660077777000000000000000000000000007cc0cc000000000000000000000000000444004000000000000000000000000000000000000000000000000
00000006777777c000000000000000000000000007c0c0c000000000000000000000000004404444000000000000000000000000000000000000000000000000
cc0000cc0c70c0c00000000000000000000000000700000000000000000000000000000000044400000000000000000000000000000000000000000000000000
c0cccccc0cccccc0000000000000000000000000070ccc0000000000000000000000000004444044000000000000000000000000000000000000000000000000
6cccccc600cccc0000000000000000000000000000ccccc000000000000000000000000000444444000000000000000000000000000000000000000000000000
66ccccc6000000000000000000ccc0000000000000c0c0c000000000000000000000000000400404000000000000000000000000000000000000000000000000
66666666000000000ccccc000ccccc000ccccc00c0cc0c0000000000000000000000000000004040000000000000000000000000000000000000000000000000
666666660ccccc000ccccc000c0cc0000ccccc00cc0ccccc00000000000000000000000000004440000000000000000000000000000000000000000000000000
66cccc660c0cc0c0cc0cc0c00c7ccc00cc0cc0000ccc0ccc00000000000000000000000000444074000000000000000000000000000000000000000000000000
6c0ccc76cc7ccc00cc7ccc00077ccc00cc7ccc0000cccc0000000000000000000000000007044470000000000000000000000000000000000000000000000000
60ccc707c77cccc0077ccc0007cccc00077cccc0c00cccc000000000000000000000000077700070000000000000000000000000000000000000000000000000
66cccc7607cccc0007cccc000cccc00007cccc000ccccc0000000000000000000000000077744777000000000000000000000000000000000000000000000000
666ccc7600000000000000000000000000000000cccccc0000000000000000000000000007744470000000000000000000000000000000000000000000000000
6666666600000000000000000000000000000000c0c00c0000000000000000000000000000400404000000000000000000000000000000000000000000000000
00000000c0c0c0000000000000000000000000007c0000007c00c0cc7c00c0c07c00000000000000000000000000000000000000000000000000000000000000
00000000cc11cc0000000000000000000000000070c0c0c07cc0c0cc70c0c0cc70c0c0c000000000000000000000000000000000000000000000000000000000
000000000c1111cc0000000000000000000000007c7770cc70c0ccc07c777ccc7c7770cc00000000000000000000000000000000000000000000000000000000
0000000000c0101c0000000000000000000000007cc77ccc7c777c007cc77cc07cc77ccc00000000000000000000000000000000000000000000000000000000
000000000cc1111c0000000000000000000000007cc7ccc07cc77cc0ccc7ccc07cc7ccc000000000000000000000000000000000000000000000000000000000
00000000cc11111c000000000000000000000000ccccccc0ccc7ccc00cccc0c0ccccccc000000000000000000000000000000000000000000000000000000000
00000000c111111c0000000000000000000000000cc0c0c00cc0c0c00cc000000cc0c0c000000000000000000000000000000000000000000000000000000000
00000000c11111c00000000000000000000000000c00c0c00c00c0000c0000000c00c0c000000000000000000000000000000000000000000000000000000000
00000000000ccc0000ccc00000ccc000000ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000ccccc00cccccc00ccccc0000ccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ccc0cc0ccc0ccc0ccc0cc000ccc0cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000c0cccc0cc0cccc0c0cccc000c0cccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000c7cccc0cc7cccc0c7cccc000c7cccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000c7cccc00c7cccc0c7cccc000c7cccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000007cccc0007cccc007cccc00007cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ccccc000ccccc00ccccc0000ccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080800080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010140400101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101500101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101014401010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010160010101700101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010b0000180501a0501c0502405024050240302401010870000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004020201770117601d7501e750117501e7502e7502d750297502675016750157501d7501c750147500d750097500b75011750107502b750107501175012750177501c7501f7501c75026750197502b7502a750
__music__
00 01424344

