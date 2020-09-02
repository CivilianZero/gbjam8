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
 --knight slime: type 3
 --thief slime: type 4
 
 --spear slime currently has
 --shield slime sprite⬇️
 slime_ani={64,80,132,112}
 slime_hp={3,4,2,3}
 slime_atk={2,1,4,2}
 slime_range={
  {{1,0}},
  {{1,0},{2,0}},
  {{0,1},{0,-1}},
  {{-1,0}}
 }
 slime_cleave={
  false,
  true,
  false,
  false
 }
 slime_mov={3,3,5,5}
 
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
 ani_t=min(ani_t+0.13,1)
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
 add(winds,w)
 return w
end

function drawind()
 for w in all(winds) do
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
     del(winds,w)
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
0000000000000000cccccccc00000000000000000000000000000000cccccccccccccccc00000000000000000000000000000000000000000000000000000000
000000000dddddd0cccccccc00000000000000000000000000000000cccccccccccccccc00000000000000000000000000000000000000000000000000000000
007007000dddddd0cccccccc00000000000000000000000000000000cccccccccccccccc00000000000000000000000000000000000000000000000000000000
000770000dddddd0cccccccc00000000000000000000000000000000cccccccccccccccc00000000000000000000000000000000000000000000000000000000
000770000dddddd0cccccccc00000000000000007777777700000000cccccccccccccccc00000000000000000000000000000000000000000000000000000000
007007000dddddd0cccccccc00000000000000007777777707000000000cccc0cccccccc00000000000000000000000000000000000000000000000000000000
000000000dddddd0cccccccc000000007777777777c777c77c70077700000000cccc0ccc00000000000000000000000000000000000000000000000000000000
0000000000000000cccccccc000000007777777777c77cc7ccc77ccc00000000000c000000000000000000000000000000000000000000000000000000000000
66666666666666666666666666666666770770c7cccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000
676666766c6666c6676666766c6666c6770770070000000007000000000000000000000000000000000000000000000000000000000000000000000000000000
66c66c666676676666c66c6666766766770770070000000000700700000000000000000000000000000000000000000000000000000000000000000000000000
6667c666666c76666667c666666c7666770770070000000000700070000000000000000000000000000000000000000000000000000000000000000000000000
666c76666667c666666c76666667c666770770070000000000000070000000000000000000000000000000000000000000000000000000000000000000000000
66c66c666676676666c66c6666766766770770070000000000070000000000000000000000000000000000000000000000000000000000000000000000000000
676666766c6666c6676666766c6666c6770770070000000000077000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666666666666770770070000000000007000000000000000000000000000000000000000000000000000000000000000000000000000
666cc6666666666666666666666cc666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66000066666cc666666cc66666000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666606660000666600006660666606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c066660c6c0660c66c0660c6c066660c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c066660c6c0660c66c0660c6c066660c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666606660000666600006660666606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66000066666cc666666cc66666000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666cc6666666666666666666666cc666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c66c00666666666666666600c66c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666660600cc006600cc00606666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c666666c6066660660666606c666666c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666666666c6666c66c6666c666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666666666c6666c66c6666c666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c666666c6066660660666606c666666c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666660600cc006600cc00606666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c66c00666666666666666600c66c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666667666666667666666666000000000000000000000000000000006668686666666666666868666666666600000000000000000000000000000000
6666676666ccc7666666667666666676000000000000000000000000000000006668686666686866666868666668686600000000000000000000000000000000
66ccc7666c0cc7c666cccc7666666676000000000000000000000000000000006688888666686866668888866668686600000000000000000000000000000000
6c0cc7c66c0cc7c66c0ccc7c6ccccc76000000000000000000000000000000006808088666888886680808866688888600000000000000000000000000000000
c0ccc7cc6ccc7076c0ccc707c00ccc76000000000000000000000000000000006688888668080866668888666808088600000000000000000000000000000000
cccc707c6cccc7c6cccccc7cccccc707000000000000000000000000000000008688886866888686668886868688886800000000000000000000000000000000
6cccc7c666cccc666ccccc666ccccc76000000000000000000000000000000006688886866888686668886866668886800000000000000000000000000000000
66666666666666666666666666666666000000000000000000000000000000006686686666688666668668666668866600000000000000000000000000000000
6666666666666666666666666666666666c6666666c6666666c6666666c666666686886866666666666666666686886800000000000000000000000000000000
6666677666666776666667766666677666c6666666c6666666c6666666c666668888868866868868668688688888868800000000000000000000000000000000
66c0777766c0777766c0777766c077776ccccc766ccccc766ccccc766ccccc768880888688888688888886888880888600000000000000000000000000000000
6cc070776cc070776cc070776cc0707767ccc07667ccc07667ccc07667ccc0766688886688808886888088866688886600000000000000000000000000000000
c0c07077c0c07077c0c07077c0c07077677000766770007667700076677000766888866866888866668888666888866800000000000000000000000000000000
ccc07777ccc07777ccc07777ccc07777677cc777677cc777677cc777677cc7776688888668888888688888886688888600000000000000000000000000000000
6ccc07766ccc07766ccc07766ccc077667cccc6667cccc6667cccc6667cccc666688888866888888668888886688888800000000000000000000000000000000
666666666666666666666666666666666ccccc666ccccc666ccccc666ccccc666686686866866868668668686686686800000000000000000000000000000000
66667776000000000000000000000000666666660000000000000000000000006666666600000000000000000000000000000000000000000000000000000000
66677767000000000000000000000000676c6c660000000000000000000000006866888600000000000000000000000000000000000000000000000000000000
6677777600000000000000000000000067cc6cc60000000000000000000000006688866800000000000000000000000000000000000000000000000000000000
777777c600000000000000000000000067c6c6c60000000000000000000000006880888800000000000000000000000000000000000000000000000000000000
6c70c0c6000000000000000000000000676666660000000000000000000000006668886600000000000000000000000000000000000000000000000000000000
6cccccc6000000000000000000000000676ccc660000000000000000000000006888808800000000000000000000000000000000000000000000000000000000
66cccc6600000000000000000000000066ccccc60000000000000000000000006688888800000000000000000000000000000000000000000000000000000000
66666666000000000000000000ccc00066c6c6c60000000000000000000000006686686800000000000000000000000000000000000000000000000000000000
6666666666ccc6666ccccc666ccccc66c6cc6c660000000000000000000000006666868600000000000000000000000000000000000000000000000000000000
6ccccc6666cc0c666c0cc0666ccccc66cc0ccccc0000000000000000000000006666888600000000000000000000000000000000000000000000000000000000
6c0cc0c66c0ccc666c7ccc66cc0cc0c66ccc0ccc0000000000000000000000006688807800000000000000000000000000000000000000000000000000000000
cc7cccc66c7ccc66677ccc66cc7cccc666cccc660000000000000000000000006768887600000000000000000000000000000000000000000000000000000000
c77cccc6677cc66667cccc66677cccc6c66cccc60000000000000000000000007776667600000000000000000000000000000000000000000000000000000000
67cccc6667ccc6666cccc66667cccc666ccccc660000000000000000000000007778877700000000000000000000000000000000000000000000000000000000
66666666666666666666666666666666cccccc660000000000000000000000006778887600000000000000000000000000000000000000000000000000000000
66666666666666666666666666666666c6c66c660000000000000000000000006686686800000000000000000000000000000000000000000000000000000000
c6c6c6660000000000000000000000007c6666667c66c6cc7c66c6c67c6666660000000000000000000000000000000000000000000000000000000000000000
cc11cc6600000000000000000000000070c6c6c67cc6c0cc70c6c0cc70c6c6c60000000000000000000000000000000000000000000000000000000000000000
6c1111cc0000000000000000000000007c7770cc70c6ccc67c777ccc7c7770cc0000000000000000000000000000000000000000000000000000000000000000
66c0101c0000000000000000000000007cc77ccc7c777c667cc77cc67cc77ccc0000000000000000000000000000000000000000000000000000000000000000
6cc1111c0000000000000000000000007cc7ccc67cc77cc6ccc7ccc67cc7ccc60000000000000000000000000000000000000000000000000000000000000000
cc11111c000000000000000000000000ccccccc6ccc7ccc66cccc6c6ccccccc60000000000000000000000000000000000000000000000000000000000000000
c111111c0000000000000000000000006cc6c6c66cc6c6c66cc666666cc6c6c60000000000000000000000000000000000000000000000000000000000000000
c11111c60000000000000000000000006c66c6c66c66c6666c6666666c66c6c60000000000000000000000000000000000000000000000000000000000000000
666ccc6666ccc66666ccc666666ccc66000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66ccccc66cccccc66ccccc6666ccccc6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6ccc0cc6ccc0ccc6ccc0cc666ccc0cc6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c0cccc6cc0cccc6c0cccc666c0cccc6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c7cccc6cc7cccc6c7cccc666c7cccc6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6c7cccc66c7cccc6c7cccc666c7cccc6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
67cccc6667cccc667cccc66667cccc66000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6ccccc666ccccc66ccccc6666ccccc66000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202070202020202070208020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020303030207020202030303020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202040404060404040202060404020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020708020215020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0208030303030803030303030202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0203034003030303030303030302020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0203030350030303030348030302020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0203038403030303030303580302161603020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0203030350030303030348030302161603020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0203700303030303030304040402030302020800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0203030303040604050402020802020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0204040504020202020202021616020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202031602020403020206060606060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202050402020203020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020206020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000002020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000002020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010b0000180501a0501c0502405024050240302401010870000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004020201770117601d7501e750117501e7502e7502d750297502675016750157501d7501c750147500d750097500b75011750107502b750107501175012750177501c7501f7501c75026750197502b7502a750
__music__
00 01424344

