?-
array(tiles_x,60,0),
array(tiles_y,60,0),
G_build_wallx := 500,
G_build_wally := 300,
array(picture,60,bitmap_image("sand.bmp",_)),
array(walkable,60,1),
array(f,60,9999),
array(g,60,0),
array(h,60,0),
%open is a keyword
array(openn,60,0),
array(closed,60,0),
array(parent,60,0),

%---pathing---
G_openindex := 0,
G_spawnindex := 0,
G_destindex := 0,
G_openindex := 0,
G_openlen := 0,
G_closedlen := 0,
G_currentindex := 0,
G_lowestfindex := 0,

%--images---
G_ground := bitmap_image("sand.bmp",_),
G_build_wall := bitmap_image("hammer_silver.bmp",_),
G_wall := bitmap_image("wall.bmp",_),

%---colors---
%beige
G_base_color is rgb(255,228,181),

%--input FSM---
G_build_mode := yes,
G_justbuiltwall := no,

%---return values---
G_tile_index := 0,
G_lowest_f_tile := 0,

%---wut---
window(_,_,scene(_),"pacman",10,10,1020,640).
	
scene(init) :-
	G_timer := set_timer(_,0.05,timer),
	indexOf(500,300),
	picture(G_tile_index) := G_wall,
	for(X,0,900,100),
		for(Y,0,500,100),
				indexOf(X,Y),
				tiles_x(G_tile_index) := X,
				tiles_y(G_tile_index) := Y,
				fail.
				

scene(paint):-
	for(I,0,60,1),
		draw_bitmap(tiles_x(I),tiles_y(I),picture(I),_,_),
		fail.

%W
scene(key_down(87,_)) :- 
	(G_build_mode ?= no ->
		donothing
	else (G_build_mode ?= yes ->

		(G_justbuiltwall ?= no ->
			indexOf(G_build_wallx,G_build_wally),
			picture(G_tile_index) := G_ground
		),

		(G_build_wally ?= 0 ->
			donothing
		else
			G_build_wally := G_build_wally - 100
		),

		indexOf(G_build_wallx,G_build_wally),
		picture(G_tile_index) := G_wall,
		G_justbuiltwall := no
	)).
%d
scene(key_down(68,_)) :- 
	(G_build_mode ?= no ->
		donothing
	else (G_build_mode ?= yes ->

		(G_justbuiltwall ?= no ->
			indexOf(G_build_wallx,G_build_wally),
			picture(G_tile_index) := G_ground
		),

		(G_build_wallx ?= 900 ->
			donothing
		else
			G_build_wallx := G_build_wallx + 100
		),

		indexOf(G_build_wallx,G_build_wally),
		picture(G_tile_index) := G_wall,
		G_justbuiltwall := no
	)).
%a
scene(key_down(65,_)) :- 
	(G_build_mode ?= no ->
		donothing
	else (G_build_mode ?= yes ->

		(G_justbuiltwall ?= no ->
			indexOf(G_build_wallx,G_build_wally),
			picture(G_tile_index) := G_ground
		),

		(G_build_wallx ?= 0 ->
			donothing
		else
			G_build_wallx := G_build_wallx - 100
		),

		indexOf(G_build_wallx,G_build_wally),
		picture(G_tile_index) := G_wall,
		G_justbuiltwall := no
	)).
%s
scene(key_down(83,_)) :- 
	(G_build_mode ?= no ->
		donothing
	else (G_build_mode ?= yes ->

		(G_justbuiltwall ?= no ->
			indexOf(G_build_wallx,G_build_wally),
			picture(G_tile_index) := G_ground
		),

		(G_build_wally ?= 500 ->
			donothing
		else
			G_build_wally := G_build_wally + 100
		),

		indexOf(G_build_wallx,G_build_wally),
		picture(G_tile_index) := G_wall,
		G_justbuiltwall := no
	)).

scene(key_down(32,_)) :- 
	(G_build_mode ?= no ->
		donothing
	else (G_build_mode ?= yes ->
		indexOf(G_build_wallx,G_build_wally),
		picture(G_tile_index) := G_wall,
		walkable(G_tile_index) := 0,
		G_justbuiltwall := yes
	)).

scene(key_down(13,_)) :- 
	G_build_mode := no,
	%add dest 
	indexOf(1000,300),
	G_destindex := G_tile_index,

	%add spawn to open array
	indexOf(0,300),
	G_spawnindex := G_tile_index,
	h(G_spawnindex) := 0,
	g(G_spawnindex) := 0,
	processF(G_spawnindex),
	insertToOpen(G_spawnindex),
	%while true with break
		takeLowestF,
		setCurrent(G_lowestfindex),

		%if current is dest break
		(G_currentindex =:= G_destindex -> true),
		
		%switch it to closed array
		removeFromOpen(G_currentindex),
		insertToClosed(G_currentindex),

		for(AdjacentXOffset,-100,100,100),
			for(AdjacentYOffset,-100,100,100),
				AdjacentX := tiles_x(G_currentindex) + AdjacentXOffset,
				AdjacentY := tiles_Y(G_currentindex) + AdjacentYOffset,
				write(AdjacentX),write(AdjacentY),nl,
				fail,
			fail.
		
		
		
	
	
		
	
donothing:-
	true.

timer(end):-
	update_window(_).

indexOf(X,Y) :-
	G_tile_index := X//100 + 10 * Y//100,
	true.
	
processF(Tile_index) :-
	f(Tile_index) := g(Tile_index) + h(Tile_index),
	true.

takeLowestF :-
	G_lowestfindex := 9999,
	for(I,0,60),
		(openn(I) =:= 1 ->
			(f(I) < G_lowestfindex -> write(I),G_lowestfindex := f(I))
		),
		(I < 59 -> fail else true).		

setCurrent(Tile_index) :-
	G_currentindex := Tile_index,
	true.

removeCurrent :-
	G_currentindex := 0,
	true.

insertToOpen(Tile_index) :-
	openn(Tile_index) := 1,
	true.

removeFromOpen(Tile_index) :-
	openn(Tile_index) := 0,
	true.

insertToClosed(Tile_index) :-
	closed(Tile_index) := 1,
	true.


	

	
		


