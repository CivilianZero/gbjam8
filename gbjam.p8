pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--slime tactics
--by civz3r0 and jordab
function _init()
 t=0
 turn_org=20
 turn_t=turn_org
 next_tut=1
 player_turn=0
 card_timer=80
 dirx,diry={-1,1,0,0,1,1,-1,-1},{0,0,-1,1,-1,1,1,-1}
 current_level=3
 --level-opedia
 levels={
  {
   name="desert gateway",
   x=0,
   opening_tutorials=1,
   tut_locations={0,1,1,1},
   tutorials={{"   protect your slime", "tribe as they journey", "across the sjrraka", "desert with their", "sacred tablets!"}, 
   {"  regular slimes are", "bread and butter units that", "attack diagonally", "in front of", "themselves!"},{"  use positioning to", "your advantage to","avoid enemy attacks!"},{"When you're done, ","press 🅾️ to end your","turn."}}
  },
  {
   name="highway",
   x=17,
   opening_tutorials=1,
   tut_locations={0,1,1,2,2},
   tutorials={
   {"enemies attack at the", "end of your turn. you", "can see what spaces", "they will hit by","hovering over the unit."},
   {"shield slimes", "pushes enemies around", "it away when it ","attacks!"},
   {"use it to create", "space for your","other units", "and set up combos!"},
   {"","the slime tablets will", "move towards the goal", "automatically"},
   {"","if you lose all of","your tablets in a level,", "you will lose! Be careful!"}
   }
  },
  {
   name="dunes",
   opening_tutorials=1,
   tut_locations={0,1},
   x=34,
   tutorials={{"","grapple slimes pull", "faraway enemies close,", "for followups!"},
   {"slime rangers are fast", "moving units that","can attack up close", "and at range!"}}
  },
  {
   name="salt flats",
   opening_tutorials=2,
   tut_locations={0,0},
   x=51,
   tutorials={{"","the thief slime", "attacks from behind,", "for massive damage!"},
   {"He doesn't", "actually steal","anything."}}
  },
  {
   opening_tutorials=0,
   tut_locations={0},
   name="island hopping",
   x=68,
   tutorials={}
  },
  {
   opening_tutorials=0,
   tut_locations={0},
   name="fortress I",
   x=85,
   tutorials={}
  },
  {
   opening_tutorials=0,
   tut_locations={0},
   name="fortress II",
   x=99,
   tutorials={}
  },
 }


 --slime-opedia
 --friendly: 1-??
 --enemies: ??-??
 --sword slime: type 1
 --shield slime: type 2
 --ranger slime: type 3
 --thief slime: type 4
 --slime mage: type 5
 --tablet: type 6
 --grapple slime: type 7
 --bunny enemy: type 9
 --dragon enemy: type 10
 --snake enemy: type 11
 --dog enemy: type 12
 --golem enemy: type 13

 slime_name={"slime","shield slime","ranger slime","thief slime","slime mage","tablet","grapple slime","desert demon","sand dragon","salt snake", "dune hound", "obsidian golem"}
 slime_ani={64,80,84,88,68,72,76,96,112,116,100,104}
 slime_hp={8,16,14,8,6,10,9,9,24,5,8,24}
 slime_atk={6,3,5,12,4,0,4,6,8,3,4,10}
 slime_range={
  {{1,-1},{1,1}},
  {{1,0},{1,-1},{1,1},{-1,0},{-1,1},{-1,-1}},
  {{0,-1},{0,1},{-1,-1},{-1,1}},
  {{-1,0}},
  {{3,0},{3,-1},{3,1},{4,0}},
  {{0,0}},
  {{1,0},{2,0},{3,0},{4,0},{5,0}},
  {{-1,1},{-1,0},{0,1}},
  {{-1,0},{-2,0},{-3,0},{-4,0},{-1,1},{-1,-1}},
  {{-1,0}},
  {{-1,0},{-1,1},{-1,-1}},
  {{-2,0},{-1,1},{-1,-1},{-2,1},{-2,-1},{-3,0},{-2,2},{-2,-2}}
 }
 slime_push_strength={
  0,
  1,
  0,
  0,
  0,
  0,
  -5,
  0,
  0,
  0,
  0,
  1
 }
 slime_push_axis={
  0,
  "x",
  0,
  0,
  0,
  0,
  "x",
  0,
  0,
  0,
  0,
  "x"
 }
 slime_attack_move={
  {0,0},
  {0,0},
  {0,0},
  {0,0},
  {0,0},
  {0,0},
  {0,0},
  {0,0},
  {0,0},
  {0,0},
  {0,0},
  {0,0},
 }
 slime_aiming={
  false,
  true,
  false,
  false,
  false,
  false,
  true,
  false,
  false,
  false,
  false,
  false,
 }
 slime_cleave={
  true,
  true,
  true,
  false,true,false,false,
  true,
  true,
  false,
  true,
  true
 }
 slime_mov={3,3,5,4,2,0,4,3,4,3,5,2}

 debug={}

 menu_init()
end

function menu_init()
 _upd,_drw=update_menu
 ,draw_menu
end

function initialize_level() 
 map(levels[current_level].x,0)

 slimes={}
 tablets={}
 bads={}
 dmobs={}
 winds={}

 player_turn=0
 next_tut=1
 ani_t,slctd,mvdist,aiming=0,nil,0,false
 loaded_attack_range=nil
 loaded_push_axis=nil

 spawnthings() 			

end

function cheat()
 if current_level==4 then
  slime_range[10]=4
  slime_range[10]={{-1,0},{-2,0}}
 end
 if current_level==6 then
 end
end

function game_start()
 c_en=1
 c_ani,cx,cy={48,49,50,51},5,5

 locstore,floats,movcursor,
 winds,menuwind={},{},{},{},nil
 atk_vis={}

 distmap=blankmap(-1)
 initialize_level()
 cheat()
 _upd,_drw=update_level_card,draw_level_card
end

function loadnextlevel()
 current_level+=1
 initialize_level()
 _upd,_drw=update_level_card,draw_level_card
end

function startlevel() 
 hidestats()
 if #levels[current_level].tutorials~=0 then
  showtut(1)
 end
 _upd,_drw=update_tutorial,draw_game
end

function spawnthings()
 local adjx=levels[current_level].x

 for x=adjx,adjx+16 do
  for y=0,15 do
   for i=1,#slime_ani do
    if mget(x,y)==slime_ani[i] then
     local newx = x%17
     addslime(i,newx,y)
     mset(x,y,3)
    end
   end
  end
 end

 for s in all(slimes) do
  if not s.ally then
   add(bads,s)
   del(slimes,s)
  end
 end

 for s in all(slimes) do
  if s.typ==6 then
   add(tablets,s)
   del(slimes,s)
  end
 end

 tablettarget()
end

-->8
--update
function _update60()
 t+=1
 _upd()
 dofloats()
end

function update_menu()
 if (btnp(❎)) game_start()
end

function update_level_card()
 card_timer-=1
 if card_timer<=0 then
  card_timer=80
  startlevel()
 end
end

function update_tutorial() 
 if btnp(❎) then
  tutwind.dur=0
  tutwind=nil
  next_tut+=1
  if player_turn==0 then
   check_next_tutorial()
  else
   _upd=update_game
  end
 end
 if #levels[current_level].tutorials<=0 then
  check_next_tutorial() 
 end
end

function check_next_tutorial() 
 if next_tut > levels[current_level].opening_tutorials then
  _upd=update_aiturn
 else
  showtut(next_tut)
 end
end

function show_next_tutorial() 
 showtut(next_tut)
 _upd=update_tutorial
end

function update_game()
 if player_turn==levels[current_level].tut_locations[next_tut] then
  show_next_tutorial()
 end
 c_en=1
 wincheck()
 losecheck()

 if menuwind then
  if btnp(❎) then
   menuwind.dur=0
   menuwind=nil
   for s in all(slimes) do
    s.hasmvd=false
    s.hasatkd=false
   end
   _upd=update_aiturn
  end
  if btnp(🅾️) then
   menuwind.dur=0
   menuwind=nil
  end
 else
  for i=0,3 do
   if btnp(i) then
    if slctd and aiming then
      slimeaim(i)
    else
      movecursor(i)
    end
   end
  end

  if btnp(❎) then
   local is_slime=getslime(cx,cy,"slimes")	
   if not slctd and is_slime and not is_slime.hasmvd then
    slctd=is_slime
    loaded_attack_range=slctd.range
    loaded_push_axis=slctd.push_axis
    locstore[1],locstore[2],mvdist=
    slctd.x,slctd.y,slctd.mr
   elseif slctd and slctd.aiming and not aiming and spaceisvalid(slctd.x,slctd.y) then
     aiming = true
   elseif slctd and not slctd.hasatkd then
    if spaceisvalid(slctd.x,slctd.y) then
	 if not slctd.double_move or slctd.hasatkd then
     slctd.hasmvd=true
	 end
     slimeatk(slctd)
     losecheck()
     _upd=update_slime
    else 
     slctd.x,slctd.y=
     locstore[1],locstore[2]
     cx,cy,mvdist=slctd.x,slctd.y,
     slctd.mr
     paintatk(slctd)
     slctd=nil
    end
   else
    _upd=update_slime
   end
  end

  if btnp(🅾️) then
   if slctd then
    if mvdist<slctd.mr then
     slctd.x,slctd.y=
     locstore[1],locstore[2]
     cx,cy,mvdist=slctd.x,slctd.y,slctd.mr
     disableaiming()
     paintatk(slctd)
     slctd=nil
    else
     disableaiming()
     paintatk(slctd)
     slctd=nil
    end
   else
    showmenu()
   end
  end
 end
end

function disableaiming()
  aiming=false
  loaded_attack_range=nil
  loaded_push_axis=nil
end

function update_tablet()
 ani_t=min(ani_t+0.08,1)
 for t in all(tablets) do
  if t.mov then
   t:mov()
  end
 end
 turn_t-=1

 if ani_t==1 and turn_t==0 then
  ani_t=0
  turn_t=turn_org
  _upd=update_game
  player_turn+=1
 end
end

function update_tabletplan()
 for t in all(tablets) do
  findpath(t)
  t.hasmvd=false
 end
 _upd=update_tabletmove
end

function update_tabletmove()
 for t in all(tablets) do
  if not t.hasmvd then
   t.hasmvd=true
   for p in all(t.path) do
    moveslime(t,p.x,p.y)
   end
   t.path={}
  end
 end
 ani_t=0
 turn_t=turn_org
 _upd=update_tablet
end

function update_slime()
 ani_t=min(ani_t+0.13,1)
 for s in all(slimes) do
  if s.mov then
   s.atkpaint={}
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
   paintatk(s)
  end
  _upd=update_game
 end
end

function update_aiturn()
 wincheck()
 losecheck()
 local b=bads[c_en]
 ani_t=0
 turn_t=turn_org
 gettarget(b)
 if not b.hasmvd then
  if b.x~=b.tar.x or b.y~=b.tar.y then
   findpath(b)
  else
   tar_reached(b)
  end
 else
  slimeatk(b)
 end
 _upd=update_aimove
end

function update_aimove()
 losecheck()
 local b=bads[c_en]
 ani_t=min(ani_t+1,1)
 if b.mov then
  b:mov()
 end

 
 if btn(🅾️) then
  turn_t-=20
 else
  turn_t-=1
 end

 if ani_t==1 and turn_t<=0 then
  if b.mov==mov_walk then
   b.mr-=1
  end
  if b.mr<=0 or b.x==b.tar.x and b.y==b.tar.y then
   tar_reached(b)
  else
   b.hasmvd=false
   _upd=update_aiturn
  end
 end
end

function update_win()
 if btnp(❎) then
  winwind.dur=0
  winwind=nil
  loadnextlevel()
 end
end

function update_finish()
 if btnp(❎) then
  reload(0x2000, 0x2000, 0x1000)
  current_level=1
  game_start()
 end
end

function update_lose()
 if btnp(❎) then
  reload(0x2000, 0x2000, 0x1000)
  game_start()
 end
end

-->8
--draw
function _draw()
 palt(0,false)
 palt(6,true)
 _drw()
 drawind()
 foreach(debug,printh)
end

function draw_menu()
 cls(1)
 print("slime tactics",35,25,7)
 print("a game by kevin smith,",25,43,7)
 print("jordan carroll, and ",25,49,7)
 print("kenney goad",25,55,7)
 print("press ❎ to start",31,70,7)
end

function draw_level_card()
 cls(1)
 print(current_level .. ". " .. levels[current_level].name,34,60,7)
end

function draw_finish()
 cls(q)
 color(7)
 print("congratulations!",34,60)
 print("you have led your tribe to safety!",14,66)
 print("press ❎ to play again",22,72)
end

function draw_lose()
 cls(1)
 color(7)
 print("game over",34,60)
 print("press ❎ to try again",20,68)
end

function draw_game()
 cls(1)
 map(levels[current_level].x,0)
 for d in all(dmobs) do
  if sin(time()*8)>0 then
   drawspr(d.ani,d.x*8,d.y*8,false)
  end
  d.dur-=1
  if d.dur<=0 then
   del(dmobs,d)
  end
 end
 for s in all(slimes) do
  drawspr(s.ani,
  s.x*8+s.ox,s.y*8+s.oy,
  s.flp)
 end

 for t in all(tablets) do
  drawspr(t.ani,
  t.x*8+t.ox,t.y*8+t.oy,
  t.flp)
 end

 for b in all(bads) do
  drawspr(b.ani,
  b.x*8+b.ox,b.y*8+b.oy,
  b.flp)
 end
 if (not slctd) drawspr(c_ani,cx*8,cy*8,false)

 for f in all(floats) do
  oprint8(f.txt,f.x,f.y,f.c,7)
 end

 for b in all(bads) do
  if cx==b.x and cy==b.y then
   drawtarget(b)
  end
 end

 if slctd then
  calcdist(slctd.x,slctd.y)
  for x=0,15 do
   for y=0,15 do
    if distmap[x][y]<=mvdist and distmap[x][y]>0 and iswalkable(x,y,"checkmobs")then
     drawspr({16,17,18,19},x*8,y*8,false)
    end
   end
  end
 end

local units={}
foreach(slimes,function(u) add(units,u) end)
foreach(tablets,function(u) add(units,u) end)
foreach(bads,function(u) add(units,u) end)

 for u in all(units) do
  if cx==u.x and cy==u.y then
   if not u.hasmvd and #u.atkpaint>0 then
    drawtarget(u) 
   end
   showstats(u)
  else
   hidestats()
  end
 end

 for v in all(atk_vis) do
  debug={}
  if sin(time()*8)>0 then
   drawspr({32,33,34,35},v.x*8,v.y*8,false)
  end
  v.dur-=1
  if v.dur<=0 then
   del(atk_vis,v)
  end
 end

 --visualize distance map test
 -- for x=0,15 do
 --  for y=0,15 do
 --   if distmap[x][y]>0 then
 --    print(distmap[x][y],x*8,y*8,8)
 --   end
 --  end
 -- end
end

function drawspr(_spr,_x,_y,_flip)
 spr(_spr[flr(t/15)%#_spr+1],_x,_y,1,1,_flip)
end

function drawtarget(e)
 for t in all(e.atkpaint) do
  drawspr({32,33,34,35},t.x*8,t.y*8,false)
 end
end
-->8
--utility
function spaceisvalid(x,y)
 local thingcount=0
 for s in all(slimes) do
  if s.x==x and s.y==y then
   thingcount+=1
  end
 end
 for t in all(tablets) do
  if t.x==x and t.y==y then
   thingcount+=1
  end
 end
 return thingcount < 2
end

function allunitsmoved()
 for s in all(slimes) do
  if not s.hasmvd then
   return false
  end
 end
 return true
end

function iswalkable(x,y,mode)
 local mode=mode or ""
 local offx=levels[current_level].x+x

 if inbounds(x,y) then
  if mode=="alliedok" then
   local slime=getslime(x,y)
   if slime and slime.ally then
    return true
   end
  end

  local tle=mget(offx,y)
  if mode=="sight" then
   return not fget(tle,2)
  else
   if not fget(tle,0) then
    if mode=="checkmobs" or mode=="alliedok" then
     local slime=getslime(x,y)
     return not slime
    end
    return true
   end
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

function dist(fx,fy,tx,ty)
 local dx,dy=fx-tx,fy-ty
 return sqrt(dx*dx+dy*dy)
end

function blankmap(_dflt)
 local ret={} 
 if (_dflt==nil) _dflt=0

 for x=0,15 do
  ret[x]={}
  for y=0,15 do
   ret[x][y]=_dflt
  end
 end
 return ret
end

function calcdist(tx,ty)
 local cand,step={},0
 distmap=blankmap(-1)
 add(cand,{x=tx,y=ty})
 distmap[tx][ty]=0
 repeat
  step+=1
  candnew={}
  for c in all(cand) do
   for d=1,4 do
    local dx=c.x+dirx[d]
    local dy=c.y+diry[d]
    if iswalkable(dx,dy) and distmap[dx][dy]==-1 then
     distmap[dx][dy]=step
     add(candnew,{x=dx,y=dy})
    end
   end
  end
  cand=candnew
 until #cand==0
end

function los(x1,y1,x2,y2)
 local frst,sx,sy,dx,dy=true

 if dist(x1,y1,x2,y2)==1 then return true end
 if x1<x2 then
  sx,dx=1,x2-x1
 else
  sx,dx=-1,x1-x2
 end
 if y1<y2 then
  sy,dy=1,y2-y1
 else
  sy,dy=-1,y1-y2
 end
 local err,e2=dx-dy

 while not(x1==x2 and y1==y2) do
  if not frst and iswalkable(x1,y1,"sight")==false then return false end
  e2,frst=err+err,false
  if e2>-dy then
   err-=dy
   x1=x1+sx
  end
  if e2<dx then 
   err+=dx
   y1=y1+sy
  end
 end
 return true 
end

function find(table,key)
 for i in all(table) do
  if i[key] then
   return true
  end
 end
 return false
end
-->8
--slimes
function addslime(typ,_x,_y)
 local s={
  typ=typ,
  name=slime_name[typ],
  x=_x,
  y=_y,
  ox=0,
  oy=0,
  flp=false,
  mr=slime_mov[typ],
  mrmax=slime_mov[typ],
  mov=nil,
  range=slime_range[typ],
  cleave=slime_cleave[typ],
  push_s=slime_push_strength[typ],
  push_axis=slime_push_axis[typ],
  atkmv=slime_attack_move[typ],
  aiming=slime_aiming[typ],
  atk=slime_atk[typ],
  hp=slime_hp[typ],
  maxhp=slime_hp[typ],
  hasmvd=false,
  hasatkd=false,
  ani={}
 }
 for i=0,3 do
  add(s.ani,slime_ani[typ]+i)
 end
 s.ally=s.ani[1]<=92 and true or false
 if (not s.ally) s.flp=true
 paintatk(s)
 add(slimes,s)
end

function getslime(x,y,mode)
 if (mode==nil) mode="all"

 if mode=="all" or mode=="slimes" or mode=="player" then
  for s in all(slimes) do
   if s.x==x and s.y==y then
    return s
   end
  end
 end
 if mode=="all" or mode=="bads" then
  for b in all(bads) do
   if b.x==x and b.y==y then
    return b
   end
  end
 end
 if mode=="all" or mode=="tablets" or mode=="player" then
  for t in all(tablets)do
   if t.x==x and t.y==y then
    return t
   end
  end
 end
 return nil
end

function moveslime(s,dx,dy)
 if s.ally then
  sfx(13)
 else
  sfx(43)
 end
 s.x+=dx
 s.y+=dy

 slimeflip(s,dx)
 s.sox,s.soy=-dx*8,-dy*8
 s.ox,s.oy=s.sox,s.soy
 s.mov=mov_walk
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

function pushslime(s,t)
 local destx,desty

 if loaded_push_axis=="x" then
  local i=0
  local mod=1
  -- flip mod if we're pulling
  if s.push_s < 0 then
    mod=mod*-1
  end
  -- flip it again if we're facing the opposite direction
  if t.x < s.x then
    mod=mod*-1
  end
  while iswalkable(t.x+(i+1)*mod,t.y,"checkmobs") and abs(i)<abs(s.push_s) do
   i+=1
  end
  t.x=t.x+i*mod
 end

 if loaded_push_axis=="y" then
  local i=0
  local mod=1
  if s.push_s < 0 then
    mod=mod*-1
  end
  -- flip it again if we're facing the opposite direction
  if t.y < s.y then
    mod=mod*-1
  end
  while iswalkable(t.x,t.y+(i+1)*mod,"checkmobs") and abs(i)<abs(s.push_s) do
   i+=1
  end
  t.y=t.y+i*mod
 end

 paintatk(t)
end

function attackmove(s)
 local destx,desty=s.x+s.atkmv[1],s.y+s.atkmv[2]
 if iswalkable(destx,desty,"checkmobs") then
  s.x,s.y=destx,desty
 end
end

function slimeaim(i)
  local s = slctd

  -- left input means flip all x negative
  loaded_attack_range=transformrange(s.range, i)
  loaded_push_axis=transformaxis(s.push_axis, i)
  paintatk(s)
  -- right input means return all x to normal
  -- up input means 
end

function transformrange(rng, i)
  -- double check space is moveable before allowing aiming
  local placeholder={}
  if i==0 then
    -- left
    for s in all(rng) do
      local new={-s[1],s[2]}
      add(placeholder, new);
    end
    return placeholder
  elseif i==3 then
    -- up
    for s in all(rng) do
      local new={-s[2],s[1]}
      add(placeholder, new);
    end
    return placeholder
  elseif i==1 then
    -- right
    return rng
  elseif i==2 then
    -- down
    for s in all(rng) do
      local new={s[2],-s[1]}
      add(placeholder, new);
    end
    return placeholder
  else 
    return rng
  end
end

function transformaxis(axis, i)
  if i==3 or i==2 then
    -- up or down
    if axis=="x" then
      return "y"
    elseif axis=="y" then
      return "x"
    end
  else 
    return axis
  end
end

function slimeatk(s)
 sfx(16)
 local sr=s.range
 if aiming then
   sr=loaded_attack_range
 end
 local srx=sr[1][1]
 slimeflip(s,srx)
 s.sox,s.soy=srx*8,sr[1][2]*8
 s.ox,s.oy=0,0
 s.mov=mov_bump
 ani_t=0
 s.hasatkd=true
 aiming=false
 add_atk_vis(s)
 for a in all(sr) do
  local typ=s.ally and "player" or "bads"
  local tx,ty=s.x+a[1],s.y+a[2]
  local target=getslime(tx,ty)
  if target then
   if typ=="bads" and target.ally or typ=="player" and not target.ally then
    target.hp-=s.atk
    pushslime(s,target)
    attackmove(s)
    addfloat("-"..s.atk,tx*8,ty*8,12)
   end
   if typ=="player" and target.ally and s.push_s < 0 then
    pushslime(s,target)
   end
   if target.hp<=0 then
    add(dmobs,target)
    if target.ally then
     del(tablets,target)
     del(slimes,target)
     hidestats()
    else
     del(bads,target)
     c_en=1
    end
    target.dur=40
   end
   if (not s.cleave) return 
  end
 end
end

function paintatk(e)
 local range_to_paint = e.range
 if aiming then
   range_to_paint=loaded_attack_range
 end
 e.atkpaint={}
 
 for a in all(range_to_paint) do	
  add(e.atkpaint,{x=a[1]+e.x,y=a[2]+e.y})
 end
end
-->8
--ui/cursor
function movecursor(i)
 local dx,dy=dirx[i+1],diry[i+1]
 local destx,desty=cx+dx,cy+dy
 if slctd and mvdist>0 then
  if iswalkable(destx,desty,"alliedok") then
   cx,cy=destx,desty
   moveslime(slctd,dx,dy)
   ani_t=0
   _upd=update_slime
   mvdist-=1
  end			 
 elseif not slctd and inbounds(destx,desty) then
  cx=destx
  cy=desty
  sfx(31)
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

function addwind(_x,_y,_w,_h,_txt,_col,_tcol)
 local w={x=_x,
 y=_y,
 w=_w,
 h=_h,
 txt=_txt,
 col=_col,
 tcol=_tcol}
 add(winds,w)
 return w
end

function drawind()
 for w in all(winds) do
  local wx,wy,ww,wh,wc,tc=w.x,w.y,w.w,w.h,w.col,w.tcol
  rectfill2(wx,wy,ww,wh,wc)
  rect(wx+1,wy+1,wx+ww-2,wy+wh-2,7)
  wx+=4
  wy+=4
  clip(wx,wy,ww-8,wh-8)
  for i=1,#w.txt do
   local txt=w.txt[i]
   print(txt,wx,wy,tc)
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
    oprint8("❎",wx+ww-15,wy+2+min(sin(time())),7,1)
   end
  end
 end
end

function showwin()
--  music(-1)
 winwind=addwind(36,50,54,13,{"level clear!"},1,15)
 sfx(34)
 winwind.butt=true
 if current_level==#levels then
  _upd,_drw=update_finish,draw_finish
 end
end

function showmenu()
 menuwind=addwind(36,50,54,13,{"end turn?"},1,15)
 menuwind.butt=true
end

function showtut(i)
 tutwind=addwind(8,36,100,40,levels[current_level].tutorials[i],1,15)
 tutwind.butt=true
end

function showstats(ent)
 local wcol = 8
 local winy = 92
 if ent.y > 8 then
  winy = 2
  winds={}
 end
 if ent.ally then
  if ent.hasmvd then
   wcol = 12 
  else
   wcol = 1
  end
 end
 ntext = ent.name
 htext = "Health " .. ent.hp .. "/" .. ent.maxhp
 amtext = "Attack " .. ent.atk .. "  Move " .. ent.mr
 statswind=addwind(2,winy,100,34,{ntext,"--------",htext,amtext},wcol,15);
end

function hidestats()
 if statswind then
  statswind.dur=0
  statswind=nil
 end
end
-->8
--mechanics

function check_block(unit)
 local range=unit.range
 for r in all(range) do
  if not iswalkable(r[1],r[2]) then
   return false
  end
 end
 return true
end

function add_atk_vis(unit)
 local range=unit.range
 for r in all(range) do
  local rx,ry=unit.x+r[1],unit.y+r[2]
 end
end

function tar_reached(b)
 b.hasmvd=true
 b.mr=b.mrmax
 paintatk(b)
 c_en+=1
 if c_en>=#bads then
  c_en=1
  if b.mov==mov_walk then
   _upd=update_tabletplan
  else
   _upd=update_aiturn
  end
 else		
  _upd=update_aiturn
 end
end

function gettarget(e)
 calcdist(e.x,e.y)
 local bx,by,bdst,tdst,ttable,maxdist=e.x,e.y,99,99,{},6
 for t in all(tablets) do
  add(ttable,t)
 end
 for s in all(slimes) do
  add(ttable,s)
 end
 for t in all(ttable) do
  for r in all(e.range) do
   local dx,dy=t.x-r[1],t.y-r[2]
   if iswalkable(dx,dy,"checkmobs") and buddycheck(b,dx,dy) then
    tdst=distmap[dx][dy]
   end
   if tdst<bdst and los(dx,dy,t.x,t.y) then
    bdst=tdst
    bx,by=dx,dy
   end
  end
 end
 e.tar={x=bx,y=by}
end

function findpath(e)
 calcdist(e.tar.x,e.tar.y)
 local bx,by,bdst=0,0,distmap[e.x][e.y]
 for i=1,4 do
  local dx,dy=dirx[i],diry[i]
  local tx,ty=e.x+dx,e.y+dy
  if iswalkable(tx,ty,"checkmobs") then
   local dst=distmap[tx][ty]
   if dst<bdst then
    bdst=dst
    bx,by=dx,dy
   end
  end
 end
 moveslime(e,bx,by)
end

function buddycheck(self,dx,dy)
 for b in all(bads) do
  if not b==self and b.tar and dx==b.tar.x and dy==b.tar.y then
   return false
  end
 end
 return true
end

function tablettarget()
 for t in all(tablets) do
  t.tar={x=15,y=t.y}
 end
end

function wincheck()
 if #bads==0 then
  _upd=update_win	
  showwin()
 end
 local win_counter=0 
 for t in all(tablets) do	
  if t.y==15 then	
   win_counter+=1 	
  end	
 end	
 if win_counter==#tablets then	
  _upd=update_win	
  showwin()
 end
end

function losecheck()
 if #tablets==0 or #slimes==0 then
  _upd,_drw=update_lose,draw_lose
 end
 return false
end
__gfx__
0000000000000000ccccccccffffffff8888888888888888ffffffffcccccccccccccccf77777777ffffffffff7777ffffffffffff7777ffff7777ffff7777ff
000000000dddddd0ccccccccffffffff8888888888888888ffffffffcccccccccccccccf77777777f7777777ff7777ff77777777ff8778ffff877877778778ff
007007000dddddd0ccccccccffffffffcccccccc88c888c8ffffffffcccccccccccccccf77777777ff777777ff7787ff77777777ff7777ffff777777777777ff
000770000dddddd0ccccccccffffffffcccccccc88c88cc8ffffffffccccccccccccccff77777777ff877788ff8888ff88888888ff8778ffff877778877778ff
000770000dddddd0ccccccccffffffffccccccccccccccccffffffffcccccccccccccccc77777777ff777888ff7877ff78778787ff7777ffff777778877777ff
007007000dddddd0ccccccccffffffffccccccccccccccccf4fffffffffccccfcccccccf77777777ff877888ff8888ff88888888ff8777ffff877788887778ff
000000000dddddd0ccccccccffffffffcccccccccccccccc4c4ff444ffffffffcccccccf77777777ff777788ff8888ff87877877ff7777ffff777788887777ff
0000000000000000ccccccccffffffffccccccccccccccccccc44cccffffffffcccccccf77777777ff8778ffff8888ff78888888ff8778ffff87788ff88778ff
66cccc66666666666666666666cccc66880880c800ccccccffffffffffff8f7fffffffff00000000ff7777ffffffffff00000000ff7777ff0000000000000000
6666666666cccc6666cccc66666666668808800800000000f7fffffff7f888ff11f111ff00000000ff877877ff87878700000000ff7777ff0000000000000000
c6cccc6c6c6666c66c6666c6c6cccc6c8808800800000000ff8ff7ffff8878ff11f111ff00000000ff777777ff87777700000000ff7787ff0000000000000000
c6cccc6c6c6cc6c66c6cc6c6c6cccc6c8808800800000000ff8fff8ffff88ffff1ff11ff00000000ff877777ff77777700000000ff8888ff0000000000000000
c6cccc6c6c6cc6c66c6cc6c6c6cccc6c8808800800000000ffffff8ff7f88f7fffffffff00000000f8887878ff87778800000000ff7877ff0000000000000000
c6cccc6c6c6666c66c6666c6c6cccc6c8808800800000000fff7ffffff8788ffff1f111f00000000f8788888ff77778800000000ff8888ff0000000000000000
6666666666cccc6666cccc66666666668808800800000000fff88ffff7f88fffff11f11f00000000ff888888ff87788800000000ff8888ff0000000000000000
66cccc66666666666666666666cccc668808800800000000ffff8fffff887fffffffffff00000000ffffffffff7777ff00000000ff8888ff0000000000000000
66688666666666666666666666688666ffffffffff7777fffffffffffcfcfcfc111ffffffcfcfcffff7778ff888888888888888f00000000fff78f8ff87878ff
6611116666688666666886666611116677777777ff8778ffff1111ffcfcfcfcfff1ff11fcfcfcfcf777777ffcccccccccccccccf00000000ff78f8f88f8f8f87
6166661666111166661111666166661677777777ff7777fff11111fffffffffffffff11ffcfcfcfc777778ffcccccccccccccccf00000000f788fffff88ffff8
8166661868166186681661868166661878787888ff8778fff11111ffcfcfcfcfff1ff1ffcfcfcfcf777777ffccccccccccccccff0000000078f8ffffffffffff
8166661868166186681661868166661888887878ff7777fff11f11ffffffffffff11fffffcfcfcfc788788ffcccccccccccccccc0000000088ffffffffffffff
6166661666111166661111666166661688888888ff8777fff11f11ffffffffffff11ff11cfcfcfcf888788fffffccccfcccccccf000000008f8fffffffffffff
6611116666688666666886666611116688888888ff7777ffffffffffffffffffffffff1ffcfcfcfc8888888fffffffffcccccccf00000000ff8fffffffffffff
66688666666666666666666666688666ffffffffff8778ffffffffffffffffffffffffffcfcfcfcfffffffffffffffffcccccccf00000000ffffffffffffffff
11c66c11666666666666666611c66c11ffffffffff7777fffcfffffffffcfcfcffffffffffffffcfffffffffffffffffffffffffffffffffffffffff77777777
16666661611cc116611cc11616666661ff878787ff7777ffcfcfcfffffffffcffffffffffffcfcfc777777ffffffffffff787fff7f7f7f7fff88ffff777f7777
c666666c6166661661666616c666666cff877777ff7787fffcfffffffffcfcfcffffffffffffffcf777778fffffffffff788888ff7f7f7f7ffffffff7777777f
666666666c6666c66c6666c666666666ff777777ff8888ffcfcfcfffffffffcffcfcfcfcfcfcfcfc777777ffffffffff78888f877f7f7f7f8888888f7f777777
666666666c6666c66c6666c666666666ff877788ff7877fffcfffffffffcfcfcffffffffffffffcf887777fffffffffff888f8f8f7f7f7f7ffffffff77777777
c666666c6166661661666616c666666cff777788ff8888ffcfcfcfffffffffcffcfcfcfcfcfcfcfc887778ffffff8ffff88f88887f7f7f7fff88888f7777f777
16666661611cc116611cc11616666661ff877788ff8888fffcfffffffffcfcfccfcfcfcfcfcfcfcf888777ffffffffffff88888ff7f7f7f7ffffffff77f77777
11c66c11666666666666666611c66c11ff7778ffff8888ffcfcfcfffffffffcffcfcfcfcfcfcfcfcff7777fffffffffff8ffffff7f7f7f7fff8fffff77777777
66666666666666666666666666666666666677766666666666666666666677766666666666666666666771666667716666666666666666666666666666666666
6666666666ccc16666ccc1666666666666677767666677766666777666677767666771666667716666ccc16666ccc1666666666666ccc16666ccc16666666666
66cccc166ccccc166ccccc1666cccc166677777666677767666777676677777666ccc16666ccc1666cc7cc166cc7cc1666c777166cccc7766cccc77666c77716
6ccccc166c1ccc166c1ccc166ccccc16777777166677777666777776777777166cc7cc166cc7cc166cc7cc166cc7cc166c77c7166c1c7c776c1c7c776c77c716
c1cccc116ccccc166ccccc16c1cccc1167c1c116777777167777771667c1c1166cc7cc166cc7cc1666ccc16666ccc166c17cc7c16cc7ccc76cc7ccc7c17cc7c1
cccccc116cccc1166cccc116cccccc116cccccc667c1c11667c1c1166cccccc666ccc16666ccc1666667766666677666cc7cccc16cc7cc776cc7cc77cc7cccc1
6ccccc1666ccc16666ccc1666ccccc1666cccc666cccccc66cccccc666cccc66666776666667766666666666666666666c777c1666c7716666c771666c777c16
666666666666666666666666666666666666666666cccc6666cccc66666666666666666666666666666666666666666666666666666666666666666666666666
66666666666c1776666c1776666666667c66666666666666666666667c6666666666666666666666666666666666666600000000000000000000000000000000
6666677666c1777166c177716666677671c6c6c67c6666667c66666671c6c6c666666666661c1666661c16666666666600000000000000000000000000000000
66c17777661171716611717166c177777c7771cc71c6c6c671c6c6c67c7771cc6c1c116666cc116666cc11666c1c116600000000000000000000000000000000
6cc171776cc171716cc171716cc171777cc77cc17c7771cc7c7771cc7cc77cc16cccc1166c7c11666c7c11666cccc11600000000000000000000000000000000
c1c171776cc177716cc17771c1c171777cc7ccc67cc77cc17cc77cc17cc7ccc6cc7cc116677c1166677c1166cc7cc11600000000000000000000000000000000
ccc177776ccc17766ccc1776ccc17777cc1ccc167cc7ccc67cc7ccc6cc1ccc16c77cc11667cc166667cc1666c77cc11600000000000000000000000000000000
6ccc177666cc116666cc11666ccc17766c16c616cc16cc16cc16cc166c16c61667cc11666cc116666cc1166667cc116600000000000000000000000000000000
666666666666666666666666666666666c66c6166c66c6166c66c6166c66c6166666666666666666666666666666666600000000000000000000000000000000
66868666666666666686866666666666666666666111668661116686666666666611146666666666666666666611146600000000000000000000000000000000
66868666668686666686866666868666611166861661116616611166611166866117171666111466661114666117171600000000000000000000000000000000
61118866668686666111886666868666166111661111711611117116166111666111111661171716611717166111111600000000000000000000000000000000
61171786611188666117178661118866111171161611166616111666111171166111111461111116611111166111111400000000000000000000000000000000
61111866661717866611186661171786661116666171111661711116661116661111111461111114611111141111111400000000000000000000000000000000
16111868616118666161186616111868117111161111116611111166117111161611111411111114111111141611111400000000000000000000000000000000
16111866616118666161186616111666111111661111686611116866111111661611116616111114161111141611116600000000000000000000000000000000
66166866666116666616686666611666161668661616666616166666161668666616646616166466161664666616646600000000000000000000000000000000
86886866666666666666666686886866666666666666118666661186666666660000000000000000000000000000000000000000000000000000000000000000
18611188868868668688686618611188666661181116178611161786666661180000000000000000000000000000000000000000000000000000000000000000
61817118186111881861118861817118611161781616118616161186611161780000000000000000000000000000000000000000000000000000000000000000
66111166618171186181711866111166116161181166116611661166116161180000000000000000000000000000000000000000000000000000000000000000
16611186661111666611116616611186166661161666186616661866166661160000000000000000000000000000000000000000000000000000000000000000
61111866111111861111118661111866166111861661186616611866166111860000000000000000000000000000000000000000000000000000000000000000
11181866111818661118186611181866111118661111866611118666111118660000000000000000000000000000000000000000000000000000000000000000
16866866168668661686686616866866666666666666666666666666666666660000000000000000000000000000000000000000000000000000000000000000
c6c6c666000000000000000000000000000000000000000066686866666666666668686666666666000000000000000000000000000000000000000000000000
cc11cc66000000000000000000000000000000000000000066686866666868666668686666686866000000000000000000000000000000000000000000000000
6c1111cc000000000000000000000000000000000000000066888886666868666688888666686866000000000000000000000000000000000000000000000000
66c0101c000000000000000000000000000000000000000068080886668888866808088666888886000000000000000000000000000000000000000000000000
6cc1111c000000000000000000000000000000000000000066888886680808666688886668080886000000000000000000000000000000000000000000000000
cc11111c000000000000000000000000000000000000000086888868668886866688868686888868000000000000000000000000000000000000000000000000
c111111c000000000000000000000000000000000000000066888868668886866688868666688868000000000000000000000000000000000000000000000000
c11111c6000000000000000000000000000000000000000066866866666886666686686666688666000000000000000000000000000000000000000000000000
666ccc6666ccc66666ccc666666ccc667c6666667c66c6cc7c66c6c67c66c6cc6666666666666666666666666666666600000000000000000000000000000000
66ccccc66cccccc66ccccc6666ccccc678c6c6c67cc6c8c878c6c8cc7cc6c8c86666666666cc86666cc888666cc8886600000000000000000000000000000000
6ccc0cc6ccc0ccc6ccc0cc666ccc0cc67c7778cc78c6ccc67c777cc878c6ccc66ccc886666cc88666cccc8666ccc886600000000000000000000000000000000
6c0cccc6cc0cccc6c0cccc666c0cccc67cc77cc87c777c667cc77cc67c777c666cccc8866ccc88666c7cc866cc7cc88600000000000000000000000000000000
6c7cccc6cc7cccc6c7cccc666c7cccc67cc7ccc67cc77c86ccc7cc867cc77c86cc7cc8866c7c8866677cc866cc7cc88600000000000000000000000000000000
6c7cccc66c7cccc6c7cccc666c7cccc6cc8ccc86cc87cc866cccc6868c87cc86c77cc886677c866667cc8866677c888600000000000000000000000000000000
67cccc6667cccc667cccc66667cccc666c86c6866c86c6866c8666666c86c68667cc886667c886666cc8866667c8886600000000000000000000000000000000
6ccccc666ccccc66ccccc6666ccccc666c66c686666666666c6666666c66c6666666666666666666666666666666666600000000000000000000000000000000
66868666668686666686866666666666c6cc6c660000000066666666000000000000000000000000000000000000000000000000000000000000000000000000
66868666668686666686866666868666cc7ccccc0000000068668886000000000000000000000000000000000000000000000000000000000000000000000000
611188666111886661118866668686666ccc7ccc0000000066888668000000000000000000000000000000000000000000000000000000000000000000000000
6117178666171786611717866111886666cccc660000000068808888000000000000000000000000000000000000000000000000000000000000000000000000
61111866616118666611186661171786c66cccc60000000066688866000000000000000000000000000000000000000000000000000000000000000000000000
161118686161186661611866161118686ccccc660000000068888088000000000000000000000000000000000000000000000000000000000000000000000000
16111866666116666161186616111666cccccc660000000066888888000000000000000000000000000000000000000000000000000000000000000000000000
66166866666666666616686666611666c6c66c660000000066866868000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000066668686000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000066668886000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000066888078000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000067688876000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000077766676000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000077788777000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000067788876000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000066866868000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000007c6666667c66c6cc7c66c6c67c66c6cc0000000000000000000000000000000000000000000000007770000007000000
0000000000000000000000000000000071c6c6c67cc6c1c171c6c1cc7cc6c1c10000000000000000000000000700000000000000000000007000077070000770
000000000000000000000000000000007c7771cc71c6ccc67c777cc171c6ccc60000000000000000000000000000770000000000000000000077077000770070
000000000000000000000000000000007cc77cc17c777c667cc77cc67c777c660000000000000000000000000007770000077000000070000077700000700000
000000000000000000000000000000007cc7ccc67cc77c16ccc7cc167cc77c160000000000000000000000000077700000077000000000000007770000000700
00000000000000000000000000000000cc1ccc16cc17cc166cccc6161c17cc160000000000000000000000000077000000000000000000000770770707007707
000000000000000000000000000000006c16c6166c16c6166c1666666c16c6160000000000000000000000000000007000000000000000000770000007700000
000000000000000000000000000000006c66c616666666660c6666666c66c6660000000000000000000000000000000000000000000000000000077700000007
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000077000000770
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077000077007000770070
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000077000000777000077700000770000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077000007770000007770000007700
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007700000700770007007700
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700770000007700000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffffffffffffffff88ffffff888ff8f8f8fffff
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffffffffffffffffff88ffffff88f8ff8f8ff8f
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffff8fffffff8fff8f888fff8f8f8ffffff88ff
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffffffffff8ffffff8888ffff8888f8f8ff8f8f
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffffffff8f888ffff8f88ffff8f8fffffffffff
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff8fffffff8f8fffffff88fff88ff8ffffff8f8f
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fff8fffffff8ffffff888fffffff8f8fffff8f8f
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffffffffffffffffffffffffff888ffffffffff
__label__
ffff8f7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8f7fffffffffffffffffffffffffffffffffffffffff
f7f888fffffffffff7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f888ffffffffffffffffffffffffffffffffffffffffff
ff8878ffffffffffff4ff7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8878ffffffffffffffffffffffffffffffffffffffffff
fff88fffffffffffff4fff4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff88fffffffffffffffffffffffffffffffffffffffffff
f7f88f7fffffffffffffff4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f88f7fffffffffffffffffffffffffffffffffffffffff
ff8788fffffffffffff7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8788ffffffffffffffffffffffffffffffffffffffffff
f7f88ffffffffffffff44ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f88fffffffffffffffffffffffffffffffffffffffffff
ff887fffffffffffffff4fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff887fffffffffffffffffffffffffffffffffffffffffff
4444444444444444444444444444444444444444444444444444444444444444ffffffffffffffffffffffffffffffffffffffffffffffffffff8f7fffffffff
4444444444444444444444444444444444444444444444444444444444444444f7fffffff7fffffffffffffff7fffffff7ffffff7f7f7f7ff7f888ffffffffff
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccff4ff7ffff4ff7ffffffffffff4ff7ffff4ff7fff7f7f7f7ff8878ffffffffff
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccff4fff4fff4fff4fffffffffff4fff4fff4fff4f7f7f7f7ffff88fffffffffff
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccffffff4fffffff4fffffffffffffff4fffffff4ff7f7f7f7f7f88f7fffffffff
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccfff7fffffff7fffffffffffffff7fffffff7ffff7f7f7f7fff8788ffffffffff
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccfff44ffffff44ffffffffffffff44ffffff44ffff7f7f7f7f7f88fffffffffff
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccffff4fffffff4fffffffffffffff4fffffff4fff7f7f7f7fff887fffffffffff
ffffffffffff8f7fccccccccccccccccffffffffcccccccccccccccccccccccc4444444444444444444444444444444444444444444444444444444444444444
fffffffff7f888ffccccccccccccccccf7ffffffcccccccccccccccccccccccc4444444444444444444444444444444444444444444444444444444444444444
ffffffffff8878ffccccccccccccccccff4ff7ffcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
fffffffffff88fffccccccccccccccccff4fff4fcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
fffffffff7f88f7fccccccccccccccccffffff4fcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ffffffffff8788ffccccccccccccccccfff7ffffcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
fffffffff7f88fffccccccccccccccccfff44fffcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ffffffffff887fffccccccccccccccccffff4fffcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7777ffffffffff
ffffffffffffffffffffffffff787fffffffffffffffffffff787ffffffffffffffffffff7ffffffffffffffff787fffffffffffff787fffff877877ffffffff
fffffffffffffffffffffffff788888ffffffffffffffffff788888fffffffffffffffffff4ff7fffffffffff788888ffffffffff788888fff777777ffffffff
ffffffffffffffffffffffff78888f87ffffffffffffffff78888f87ffffffffffffffffff4fff4fffffffff78888f87ffffffff78888f87ff877778ffffffff
fffffffffffffffffffffffff888f8f8fffffffffffffffff888f8f8ffffffffffffffffffffff4ffffffffff888f8f8fffffffff888f8f8ff777778ffffffff
fffffffffffffffffffffffff88f8888ffff8ffffffffffff88f8888fffffffffffffffffff7fffffffffffff88f8888fffffffff88f8888ff877788ffffffff
ffffffffffffffffffffffffff88888fffffffffffffffffff88888ffffffffffffffffffff44fffffffffffff88888fffffffffff88888fff777788ffffffff
fffffffffffffffffffffffff8fffffffffffffffffffffff8ffffffffffffffffffffffffff4ffffffffffff8fffffffffffffff8ffffffff87788fffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffff7777ffffffffffffffffffffffffffffffffffffffffffff7777ffffffffffff7777ffffffffff
ff787fffff787fffff787fff777777777777777777777777778778ffffffffffffffffff777777777777777777777777ff8778fff7ffffffff7777ffffffffff
f788888ff788888ff788888f777777777777777777777777777777ffffffffffffffffff777777777777777777777777ff7777ffff4ff7ffff7787ffffffffff
78888f8778888f8778888f87787878887878788878787888877778ffffffffffffffffff787878887878788878787888ff8778ffff4fff4fff8888ffffffffff
f888f8f8f888f8f8f888f8f8888878788888787888887878877777ffffffffffffffffff888878788888787888887878ff7777ffffffff4fff7877ffffffffff
f88f8888f88f8888f88f8888888888888888888888888888887778ffffffffffffffffff888888888888888888888888ff8777fffff7ffffff8888ffffffffff
ff88888fff88888fff88888f888888888888888888888888887777ffffffffffffffffff888888888888888888888888ff7777fffff44fffff8888ffffffffff
f8fffffff8fffffff8fffffffffffffffffffffffffffffff88778ffffffffffffffffffffffffffffffffffffffffffff8778ffffff4fffff8888ffffffffff
ffffffffffffffffffffffffffffffffffffffff11cffc11ffffffffffffffffffffffffffffffffffffffffffffffffff7777ffffffffffffffffffff7777ff
777777777777777777777777777777777777777717777771777777777777777777777777ffffffffffffffffffffffffff7777fff7ffffffffffffffff7777ff
7777777777777777777777777777777777777777c777777c777777777777777777777777ffffffffffffffffffffffffff7787ffff4ff7ffffffffffff7787ff
787878887878788878787888787878887878788878787888787878887878788878787888ffffffffffffffffffffffffff8888ffff4fff4fffffffffff8888ff
888878788888787888887878888878788888787888887878888878788888787888887878ffffffffffffffffffffffffff7877ffffffff4fffffffffff7877ff
8888888888888888888888888888888888888888c888888c888888888888888888888888ffffffffffffffffffffffffff8888fffff7ffffffffffffff8888ff
888888888888888888888888888888888888888818888881888888888888888888888888ffffffffffffffffffffffffff8888fffff44fffffffffffff8888ff
ffffffffffffffffffffffffffffffffffffffff11cffc11ffffffffffffffffffffffffffffffffffffffffffffffffff8888ffffff4fffffffffffff8888ff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
7f7f7f7f7f7f7f7fffffffffffffffffffffffff7f7f7f7fffffffffffffffff7f7f7f7f811f7f7fffffffff7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f
f7f7f7f7f7f7f7f7fffffffffffffffffffffffff7f7f7f7ffffffffffcccc1ff7f7f7f787171117fffffffff7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
7f7f7f7f7f7f7f7fffffffffffffffffffffffff7f7f7f7ffffffffffccccc1f7f7f7f7f811f1f11ffffffff7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f
f7f7f7f7f7f7f7f7fffffffffffffffffffffffff7f7f7f7ffffffffc1cccc11f7f7f7f7f117f7f1fffffffff7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
7f7f7f7f7f7f7f7fffffffffffffffffffffffff7f7f7f7fffffffffcccccc117f7f7f7f78111f71ffffffff7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f
f7f7f7f7f7f7f7f7fffffffffffffffffffffffff7f7f7f7fffffffffccccc1ff7f7f7f7f7811111fffffffff7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7
7f7f7f7f7f7f7f7fffffffffffffffffffffffff7f7f7f7fffffffffffffffff7f7f7f7f7f7f7f7fffffffff7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
7f7f7f7fffffffffffffffffffffffff7f7f7f7f7f7f7f7ffffffffffff771ffffffffff7f7f7f7f7f7f7f7f7f7f7f7fffffffff7f7f7f7f811fffff7f7f7f7f
f7f7f7f7fffffffffffffffffffffffff7f7f7f7f7f7f7f7ffffffffffccc1fffffffffff7f7f7f7f7f7f7f7f7f7f7f7fffffffff7f7f7f7871f111ff7f7f7f7
7f7f7f7fffffffffffffffffffffffff7f7f7f7f7f7f7f7ffffffffffcc7cc1fffffffff7f7f7f7f7f7f7f7f7f7f7f7fffffffff7f7f7f7f811f1f117f7f7f7f
f7f7f7f7fffffffffffffffffffffffff7f7f7f7f7f7f7f7fffffffffcc7cc1ffffffffff7f7f7f7f7f7f7f7f7f7f7f7fffffffff7f7f7f7f11ffff1f7f7f7f7
7f7f7f7fffffffffffffffffffffffff7f7f7f7f7f7f7f7fffffffffffccc1ffffffffff7f7f7f7f7f7f7f7f7f7f7f7fffffffff7f7f7f7ff8111ff17f7f7f7f
f7f7f7f7fffffffffffffffffffffffff7f7f7f7f7f7f7f7fffffffffff77ffffffffffff7f7f7f7f7f7f7f7f7f7f7f7fffffffff7f7f7f7ff811111f7f7f7f7
7f7f7f7fffffffffffffffffffffffff7f7f7f7f7f7f7f7fffffffffffffffffffffffff7f7f7f7f7f7f7f7f7f7f7f7fffffffff7f7f7f7fffffffff7f7f7f7f
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7777ffffffffffffffffffff7777ff
777777777777777777777777fffffffff7ffffffffffffffffffffffffffffff811fffffffffffffffffffffffffffffff8778ffffffffffffffffffff8778ff
777777777777777777777777ffffffffff4ff7ffffffffffffffffffffcccc1f871f111fffffffffffffffffffffffffff7777ffffffffffffffffffff7777ff
787878887878788878787888ffffffffff4fff4ffffffffffffffffffccccc1f811f1f11ffffffffffffffffffffffffff8778ffffffffffffffffffff8778ff
888878788888787888887878ffffffffffffff4fffffffffffffffffc1cccc11f11ffff1ffffffffffffffffffffffffff7777ffffffffffffffffffff7777ff
888888888888888888888888fffffffffff7ffffffffffffffffffffcccccc11f8111ff1ffff8fffffffffffffffffffff8777ffffffffffffffffffff8777ff
888888888888888888888888fffffffffff44ffffffffffffffffffffccccc1fff811111ffffffffffffffffffffffffff7777ffffffffffffffffffff7777ff
ffffffffffffffffffffffffffffffffffff4fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8778ffffffffffffffffffff8778ff
ffffffffffffffffffffffffffffffffffffffffffffffffff7777ffffffffffffffffffffffffffffffffffffffffffff7777ffffffffffffffffffff7777ff
ffffffffffffffffff787fff777777777777777777777777778778fff7fffffffffffffffffffffffffffffff7ffffffff877877f7fffffff7ffffffff7777ff
fffffffffffffffff788888f777777777777777777777777777777ffff4ff7ffffffffffffffffffffffffffff4ff7ffff777777ff4ff7ffff4ff7ffff7787ff
ffffffffffffffff78888f87787878887878788878787888877778ffff4fff4fffffffffffffffffffffffffff4fff4fff877777ff4fff4fff4fff4fff8888ff
fffffffffffffffff888f8f8888878788888787888887878877777ffffffff4fffffffffffffffffffffffffffffff4ff8887878ffffff4fffffff4fff7877ff
fffffffffffffffff88f8888888888888888888888888888887778fffff7ffffffffffffffffffffffff8ffffff7fffff8788888fff7fffffff7ffffff8888ff
ffffffffffffffffff88888f888888888888888888888888887777fffff44ffffffffffffffffffffffffffffff44fffff888888fff44ffffff44fffff8888ff
fffffffffffffffff8fffffffffffffffffffffffffffffff88778ffffff4fffffffffffffffffffffffffffffff4fffffffffffffff4fffffff4fffff8888ff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffff787fffff787ffffffffffff7fffffff7fffffff7ffffff7777777777777777ff787ffffffffffff7fffffff7fffffff7ffffffffffffffffffffff
fffffffff788888ff788888fffffffffff4ff7ffff4ff7ffff4ff7ff7777777777777777f788888fffffffffff4ff7ffff4ff7ffff4ff7ffffffffffffffffff
ffffffff78888f8778888f87ffffffffff4fff4fff4fff4fff4fff4f787878887878788878888f87ffffffffff4fff4fff4fff4fff4fff4fffffffffffffffff
fffffffff888f8f8f888f8f8ffffffffffffff4fffffff4fffffff4f8888787888887878f888f8f8ffffffffffffff4fffffff4fffffff4fffffffffffffffff
fffffffff88f8888f88f8888fffffffffff7fffffff7fffffff7ffff8888888888888888f88f8888fffffffffff7fffffff7fffffff7ffffffffffffffffffff
ffffffffff88888fff88888ffffffffffff44ffffff44ffffff44fff8888888888888888ff88888ffffffffffff44ffffff44ffffff44fffffffffffffffffff
fffffffff8fffffff8ffffffffffffffffff4fffffff4fffffff4ffffffffffffffffffff8ffffffffffffffffff4fffffff4fffffff4fffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7777ffffffffff
ffffffffffffffffff787fffff787fffffffffffffffffffffffffffff787fffffffffff7777777777777777777777777777777777777777778778ffffffffff
fffffffffffffffff788888ff788888ffffffffffffffffffffffffff788888fffffffff7777777777777777777777777777777777777777777777ffffffffff
ffffffffffffffff78888f8778888f87ffffffffffffffffffffffff78888f87ffffffff7878788878787888787878887878788878787888877778ffffffffff
fffffffffffffffff888f8f8f888f8f8fffffffffffffffffffffffff888f8f8ffffffff8888787888887878888878788888787888887878877777ffffffffff
fffffffffffffffff88f8888f88f8888fffffffffffffffffffffffff88f8888ffffffff8888888888888888888888888888888888888888887778ffffffffff
ffffffffffffffffff88888fff88888fffffffffffffffffffffffffff88888fffffffff8888888888888888888888888888888888888888887777ffffffffff
fffffffffffffffff8fffffff8fffffffffffffffffffffffffffffff8fffffffffffffffffffffffffffffffffffffffffffffffffffffff88778ffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffff787fffff787fffff787fffffffffffffffffff77777777ffffffffff787fffff787fffffffffff77777777ffffffff
fffffffffffffffffffffffffffffffff788888ff788888ff788888fffffffffffffffff77777777fffffffff788888ff788888fffffffff77777777ffffffff
ffffffffffffffffffffffffffffffff78888f8778888f8778888f87ffffffffffffffff78787888ffffffff78888f8778888f87ffffffff78787888ffffffff
fffffffffffffffffffffffffffffffff888f8f8f888f8f8f888f8f8ffffffffffffffff88887878fffffffff888f8f8f888f8f8ffffffff88887878ffffffff
fffffffffffffffffffffffffffffffff88f8888f88f8888f88f8888ffffffffffffffff88888888fffffffff88f8888f88f8888ffffffff88888888ffffffff
ffffffffffffffffffffffffffffffffff88888fff88888fff88888fffffffffffffffff88888888ffffffffff88888fff88888fffffffff88888888ffffffff
fffffffffffffffffffffffffffffffff8fffffff8fffffff8fffffffffffffffffffffffffffffffffffffff8fffffff8ffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffff787fffff787fffff787ffff7fffffff7ffffffff787fffff787fffff787fffff787fffffffffffff787fffff787fffff787fffff787fff
fffffffffffffffff788888ff788888ff788888fff4ff7ffff4ff7fff788888ff788888ff788888ff788888ffffffffff788888ff788888ff788888ff788888f
ffffffffffffffff78888f8778888f8778888f87ff4fff4fff4fff4f78888f8778888f8778888f8778888f87ffffffff78888f8778888f8778888f8778888f87
fffffffffffffffff888f8f8f888f8f8f888f8f8ffffff4fffffff4ff888f8f8f888f8f8f888f8f8f888f8f8fffffffff888f8f8f888f8f8f888f8f8f888f8f8
fffffffffffffffff88f8888f88f8888f88f8888fff7fffffff7fffff88f8888f88f8888f88f8888f88f8888fffffffff88f8888f88f8888f88f8888f88f8888
ffffffffffffffffff88888fff88888fff88888ffff44ffffff44fffff88888fff88888fff88888fff88888fffffffffff88888fff88888fff88888fff88888f
fffffffffffffffff8fffffff8fffffff8ffffffffff4fffffff4ffff8fffffff8fffffff8fffffff8fffffffffffffff8fffffff8fffffff8fffffff8ffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff787fffff787fffff787ffff7fffffff7fffffff7ffffffff787fffff787fffff787ffff7ffffffff787fffffffffffffffffffffffffffffffffffff787fff
f788888ff788888ff788888fff4ff7ffff4ff7ffff4ff7fff788888ff788888ff788888fff4ff7fff788888ffffffffffffffffffffffffffffffffff788888f
78888f8778888f8778888f87ff4fff4fff4fff4fff4fff4f78888f8778888f8778888f87ff4fff4f78888f87ffffffffffffffffffffffffffffffff78888f87
f888f8f8f888f8f8f888f8f8ffffff4fffffff4fffffff4ff888f8f8f888f8f8f888f8f8ffffff4ff888f8f8fffffffffffffffffffffffffffffffff888f8f8
f88f8888f88f8888f88f8888fff7fffffff7fffffff7fffff88f8888f88f8888f88f8888fff7fffff88f8888fffffffffffffffffffffffffffffffff88f8888
ff88888fff88888fff88888ffff44ffffff44ffffff44fffff88888fff88888fff88888ffff44fffff88888fffffffffffffffffffffffffffffffffff88888f
f8fffffff8fffffff8ffffffffff4fffffff4fffffff4ffff8fffffff8fffffff8ffffffffff4ffff8fffffffffffffffffffffffffffffffffffffff8ffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff787fffff787fffff787fffff787fffff787ffff7ffffffff787fffff787fffff787fffff787fffff787fffff787fffffffffffffffffffff787fffff787fff
f788888ff788888ff788888ff788888ff788888fff4ff7fff788888ff788888ff788888ff788888ff788888ff788888ffffffffffffffffff788888ff788888f
78888f8778888f8778888f8778888f8778888f87ff4fff4f78888f8778888f8778888f8778888f8778888f8778888f87ffffffffffffffff78888f8778888f87
f888f8f8f888f8f8f888f8f8f888f8f8f888f8f8ffffff4ff888f8f8f888f8f8f888f8f8f888f8f8f888f8f8f888f8f8fffffffffffffffff888f8f8f888f8f8
f88f8888f88f8888f88f8888f88f8888f88f8888fff7fffff88f8888f88f8888f88f8888f88f8888f88f8888f88f8888fffffffffffffffff88f8888f88f8888
ff88888fff88888fff88888fff88888fff88888ffff44fffff88888fff88888fff88888fff88888fff88888fff88888fffffffffffffffffff88888fff88888f
f8fffffff8fffffff8fffffff8fffffff8ffffffffff4ffff8fffffff8fffffff8fffffff8fffffff8fffffff8fffffffffffffffffffffff8fffffff8ffffff

__gff__
0000010001010001010001010101010100000000010100010000010100010000000000000101000000000101010000000000000001010000000001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
170316030303030303031703030303030003030303033b033c0303030303033b031903030303030303030303030303030303000909090909090909090909640909090900020202020207020202020207030302020003030303030303030303036003600303600300030a0c0c0c0c0c0c0c0c0c0c0c0c0c0c0000000000000000
040404040404040416160316163d170300033b030316033c03350316160303030319030303030303030303030303037403030009090909093f740909740909643f3f0900022936600303036003362936600337290029030303030e0c0c0c0c0c0e0c0c0c0c0c0c000d0d033e0303030364030303030374740000000000000000
03170202160202020404040404040404000303033b033c3c3c3c3c033b0d1603031903030303030303030303032f2e030303000909090e3f3f09090909096409093f090002290404040304040402020604040229002903032e03030316161603030d030303000000160d16036060030303030a03030374740000000000000000
0303033c3b033c030316033c033c0e03000316033c3c3c0303603c3c3c0d03030319030303032e2f030303032e2f03033b03000909090909090974090909093f3f09090002290202020303020202020229292929002b032e030316161603033e030d60031b0000000d0d60033b03030a03030d033e0374740000000000000000
3c3c3c2424240f03032424240d163503002b2b2b3c3c0303030303033c1a3c3c3c19030354030303030374030303030303030016090909093f0909090909093f090909003627030303032816030303372902292900030303030303640303030a0c1660030d000000030d0303600a0f0d3b030d0a0c0c0c0f0000000000000000
242424242424242424030374351603350035030303030303030303037403033b0319030303030303037403030303033b030300163f09090909090909093f3f090909090009034c0316030404030303031702290200034016160a030364030325030d030a0d0000000a0f4c03031a2a2a03030d2a6009090d0000000000000000
3d3d0303033d03403d3d033d3d3d3d3d0003030303031674033c3b03603b3b60031903500303030303037403030303036803005458160909090e09093f643f3f3f3f09003f48034c03030202030360033770290200540340031a2a03030303252b1a6803030000001a2a4803503e036403682a09097009090000000000000000
3d0303033d3d4803033d3d3d3d3d743d003d40400303603c3c3d3d3d3d3d3d3d3d1903484003030303030303032e032f030300484c503f093f3f090909093f3f0964090036481858030302030303036037293616004803500303030303030335170303740d000000440303403b03030316030309090909090000000000000000
24242403160303403b3b03037403030d001650030303033d3d603d03163d03033c1903480303030303030303030374030374001640093f093f603f3f3f3f3f3f3f3f0900090303500303020303036003372936160029030a3a03030a3a03031603036803030000000a0f48035003036403680f09097009090000000000000000
03033c2424240f1603033b033516163500034803030303600316163c03033c033c190303400303032e030303037403030303004809090909096009093f643f3f3d6409003f16034003030360160304382902020200294c1a2a1a032a2a030325036003290d0000001a2a5803030a0f0f03030d0f6009090d0000000000000000
033c3c0316161624243c03161616030300163c161616160303033c3c3c3c3c3c0319034c03030303033e03030303740303740009093f093f3f09093f3f3f3f3f3f3f3f003f03540303030604050429292902020200482e40030316161634160e0c0d0d160d000000030d543b031a2a0d3e030d1a0c0c0c2a0000000000000000
03033c3c0303033c0324242424240f030003033c3c3c3c3c3c3c3c3c03030a0f031903030303030303740303030303030303000909093f09600909093f3f0e09090909003603030303030202020229021637020200580303030316036403160f03030d160d000000030d03030303030d3b030d03030303030000000000000000
030303033c3c3c030324033c3c03240300173b3b3b3b3c3c3c3c3c3b3b161a0f03190303030303030303030303032e0303030009090909090909640909096409090909000204040438042929603729020437020200030c0c030303640303032a030c0d030d0000000d0d03160360030d03031a03030360030000000000000000
03033c3c3c16163c3c3c3c033c3c3c3c000317030a0c0f03031616033b033b03031903032e030303033b0303030303033e030009093f3f0909093f3f3f643f3f3f3f09000202020829082902050402020260020200030303032424242424243a030d1a241a0000000d0d030360603b1a03606060033b03030000000000000000
3c3c3c1616163c3c3c163c030303033c00033b030f032a25250316030303030303190303030303033b03030303740303030300093f3f74090909090909093f3f0909090002020202292929292929292929380202000303030303030303606003030d030303000000030d03160360036003033b03030303030000000000000000
3c3c3c3c3c163c3c3c3c3c3c03033c3c000303032a242a033b030303033b030303190303030303030374030374037403030300090974090974090909090909090909090002020202020202020202020202020202000303036060600303030303031a242424000000031a24242424242424242424242424240000000000000000
0000000000000000001919191919191900191919191919191919191919191919191919191919000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020002000002020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020002020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002020202020002020200020002000202020202020202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
001000000e073266153e615266151a6730c1733e61518073180731a6733e615266151a6333e6000c17300004180733e6153e6153e6151a673180733e6151a6730c1733e6153e6153e6150e6650c173180733e615
00100020080050f0050f0750a075140051405511045110450a005160051600511005110051100511005140051b0551b055270451f0151d025180550f0550f05516055200550d0050d0551805519035030050d005
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00101820275552b5552e55524505245052555527505275052455500505005052055500505005050050500505295552b5550050500505275550050500505005052455525505255050050525555255552553525525
0010000003070030700307003070000000000000000000000d0700d07000000000000a0700a00000000000000a07000000000000807008000080700a07000000000000000000000000000f070000000f07000000
001000000305203052030520705207052050520505208052080520905211052140521b05200002000020000213075130711407114071160720d0720000211072000020f07200000000000d072000000000000000
001000001b31618116191161b1161951620526275261b52627526195261b5261e52625526225261d5261e5161b31618116191161b1161952620526275261b51627516195161b5161e52625516225261d5261e516
001000002c7701d7701877001700207700070000700277700070000700207700070000700147701377016770007000070000700187700070016700167701670003700007000070014750137500f7500a75000700
011000001b70019700197001360013655000000000000000000000000000000136001365500000000000000000000000000000000000136551360000000000000000000000000000000013655000000000000000
0010182018073266153e615266151a6730c1733e615180733e600180003e6150000400000000003e6150000000000000003e6150000000000000003e615000000c1733e6153e6153e61526615266150000000000
01100000275552b5552e55524505245052555527505275052455500505005052055500505005050050500505295552b5550050500505275550050500505005052455525505255050050525555255552553525525
011000201b700197001970013600136550000000000000001b700197001970013600136550000000000000001b700197001970013600136550f143000000f143136551365513655136550f1431f6421f6321f622
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001a5501e5502155022550235502555026550295502a5502e5502f5501950016500145001450016500185001a5000050000500005000050000500005000050000500005000050000500005000050000500
0001000026550265502355021550215501f5501e5501e5501c5501c55019550165500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000034750307502e7502c7502a750287502575022750207501c7501d7501b7501a750187501875016750147501275011750107500f7500d7500d7500d7500c7500b7500a7500975007750067500575004750
000100001b650196501765015650156201460012600126500f6500e6500d6500c6500b6500f6000e6000a65008650066500665006650066500765006650066500b6000b600056500365003650026300065000670
000100000030000300003000030000300003002c3502835024350213501e3501e3501b3501b3501c3501f3502035022350263502b3502d3500030000300003000030000300003000030000300003000030000300
000200002f3502f3502f3502f3502f3502a3502a3502a3502a350243502435024350243501f3501f3501f3501f35018350183501835018350183002b3002b3000000000000000000000000000000000000000000
00010000306502f6502f65030650326503465036650386503865038650386503a6503a6503b6503b6503a65037650356503465033650306502c6502b6502a650286502665025650226501e6501c650146500d650
0001000000000000000000000000000000000000000000002575025750257502575025700257002575025750257502475023750227502271021700207001f7501f7501e7501d7501c7501b750177301472013700
000200000c7500c7500c7500d7500e7500e7500f7501075010750107501175011750117501275012750137501375014750157501675017750187501a7501a7501c7501d7501f750217502375025750287502b750
000100001915010150131501115011150101500e150141500e150121500f150121501115014150121500e150101500b1500e150151500d15017150101500a1500d150091500b1500a15007150061500515008150
00010000000000f0500f0500f0500e0500e0000e0000e0000c0000d0500e0500e0500e05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000355502e550055000250026500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00010000000003f400294503b4003b4003640028450324002f4002d4002b4000040000400264502540000400004002240000400254502040000000214002540023450204001d4002245018400174001c45000000
0001000000100001000010022150001000010000100001002015000100001000010000100001001e1500010000100001000010015150001000010000100001000010014150001000010000100001000a15000100
000200002115000100210500010021150001002100000100211002115021000210500010021150001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
0008000008070080500815008150092500a2500a250090000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800003f5503d5003c5503a50033500345000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000185002a5002615028150291502b1502c1502e1502e150301503015031150321503315034150361500000000000000000000000000000002f15030150311503215033150341503515037150381503a150
0001000032050340503705038050390503a0503b0503d0501d200192001b200202002320026200282002a2002b2002b2002120018200142001420000000152001620016200182001b2001e200202002920034200
00030000003001e37000000000001e35000000000001e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000004700337503575037750397503c7503f7503f750337503575037750397503a7502e750317503375037750377502c7502d75030750347502375026750297502c750197501c7502275125750157501a750
00100000000002c7502875000000000002a7502f75000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000000035450004003545000400354500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000285502a5502d5503155033550345501f5502155024550265501755017550185501a5501c5501e5501155011550125501455015550195501b550085500b5500d5500f5501255015550095500a5500a550
000500000000000000000002b2302b2302b2402b1402b1302b1402b4302b4402b4502b4502d5002d5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000026500565013650166502b65031650386503d650206500f65003650006500060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000400003b2003c250352503d250352503c25035200332003a2000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
0001000015450164501145012450144501645017450184501a4501c4501e450194501a4501c4501d4501f450214502445025450274502f450314503445035450384503a4503d4503f4503f4503e4500040000400
0001000033350333503335033350343503435034350343503435033350313502d35028350233501f3501a35016350113500d3500a350083500035000000000000000000000000000000000000000000000000000
000100000e25006250052500525004250042500625007250082500a2500b2500d2501025013250162501725000250000000000000000000000000000000000000000000000000000000000000000000000000000
000a000025073190410d013010510d0000d0000d0000d000090000900014000090000900018000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002535500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002545125451254512540025400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000d23219231252310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002535127351000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002535625356273562a35600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002545627456244572540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001855318523255002550000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500000000000000000
001000002a5542a554000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002457324543245130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 00010304
00 00010304
00 00010304
00 09034344
00 05060708
00 05060708
00 05060708
00 0506070b
00 00010304
00 00010304
00 00010304
00 09034344
00 05060708
00 05060708
00 05060708
00 05060708
00 00010304
00 00010304
00 00010304
00 09034344
00 05060708
00 05060708
00 05060708
00 0506070b
00 00010304
00 00010304
00 00010304
00 09034344
00 05060708
00 05060708
00 05060708
00 05060708
00 00010304
00 00010304
00 00010304
00 09034344
00 05060708
00 05060708
00 05060708
00 0506070b
00 00010304
00 00010304
00 00010304
00 09034344
00 05060708
00 05060708
00 05060708
00 05060708
00 00010304
00 00010304
00 00010304
00 09034344
00 05060708
00 05060708
00 05060708
00 0506070b
00 00010304
00 00010304
00 00010304
00 09034344
00 05060708
00 05060708
00 05060708
02 05060708

