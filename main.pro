?-
array(x,60,0),
array(y,60,0),
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
%parent is a keyword
array(parentt,60,0),
array(path,50,30),
G_pathlen := 0,

%debug
G_breakloop := 0,
G_indexdebug := 0,

%---pathing---
G_openindex := 0,
G_spawnx := 0,
G_spawny := 300,
G_spawnindex := 30,
G_destx := 900,
G_desty := 300,
G_destindex := 39,
G_openindex := 0,
G_openlen := 0,
G_closedlen := 0,
G_currentindex := 0,
G_lowestfindex := 0,
G_lowestf := 0,
G_adjacentx := 0,
G_adjacenty := 0,
G_newg := 0,
G_opencontains := 0,
G_adjacentindex := 0,
G_adjacentxoffset := 0,
G_adjacentyoffset := 0,
G_destfound := 0,
G_pathfinddone := 0,

%---movement---
G_movindex := 0,
G_time := 0,

%---gameplay---
G_walls := 10,
G_petunjuk := 0,

%--images---
G_ground := bitmap_image("sand.bmp",_),
G_start := bitmap_image("start.bmp",_),
G_finish := bitmap_image("finish.bmp",_),
G_build_wall := bitmap_image("hammer_silver.bmp",_),
G_wall := bitmap_image("wall.bmp",_),
G_alien1 := bitmap_image("alien1.bmp",_),
G_alien2 := bitmap_image("alien2.bmp",_),

picture(30) := G_start,
picture(39) := G_finish,

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
window(main,_,scene(_),"pacman",10,10,1020,640).
	
scene(init) :-
	G_timer := set_timer(_,0.09,timer),
	G_timer2 := set_timer(_,1,move),
	indexOf(500,300),
	picture(G_tile_index) := G_wall,
	for(X,0,900,100),
		for(Y,0,500,100),
				indexOf(X,Y),
				x(G_tile_index) := X,
				y(G_tile_index) := Y,
				fail.
	
intro(paint) :-
	text_out(25,50,"Pindahkan penghalang dengan TOMBOL ARAH. Letakkan penghalang dengan SPASI. Tekan ENTER untuk memulai"),		
	text_out(25,75,"Anda hanya memiliki 10 penghalang! Semakin lama musuh mencapai finish, semakin tinggi skor anda!").

scene(paint):-
	for(I,0,59),
		draw_bitmap(x(I),y(I),picture(I),_,_),
		fail.

%W
scene(key_down(38,_)) :- 
	(G_build_mode ?= no ->
		donothing
	else (G_build_mode ?= yes ->

		clearMap,

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
scene(key_down(39,_)) :- 
	(G_build_mode ?= no ->
		donothing
	else (G_build_mode ?= yes ->

		clearMap,

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
scene(key_down(37,_)) :- 
	(G_build_mode ?= no ->
		donothing
	else (G_build_mode ?= yes ->

		clearMap,

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
scene(key_down(40,_)) :- 
	(G_build_mode ?= no ->
		donothing
	else (G_build_mode ?= yes ->

		clearMap,

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
	(G_build_mode ?= no ; G_tile_index =:= G_spawnindex ; G_tile_index =:= G_destindex->
		donothing
	else (G_build_mode ?= yes ->
			indexOf(G_build_wallx,G_build_wally),
			picture(G_tile_index) := G_wall,
			walkable(G_tile_index) := 0,
			G_justbuiltwall := yes,
			G_walls := G_walls - 1,
			(G_walls =:= -1 -> G_build_mode := no)
		)
	).

scene(key_down(13,_)) :- 
	clearMap,
	G_build_mode := no,

	%add dest 
	indexOf(G_destx,G_desty),
	G_destindex := G_tile_index,

	%add spawn to open array
	indexOf(G_spawnx,G_spawny),
	G_spawnindex := G_tile_index,
	h(G_spawnindex) := 0,
	g(G_spawnindex) := 0,
	processF(G_spawnindex),
	insertToOpen(G_spawnindex),

	opennotempty,
	(G_destfound =:= 1 ->
		reconstructPath,
		printPath,
		G_movindex := G_pathlen + 1,
		G_pathfinddone := 1
	else
		window(_,main,warning(_),"Warning",100,100,500,160)
	).
		
warning(paint) :-
	text_out(25,50,"Tidak ditemukan jalan, harap tata ulang penghalang").

clearMap :-
	for(I,0,59),
		(walkable(I) =:= 1 -> picture(I) := G_ground else picture(I) := G_wall),
		(I < 59 -> fail else picture(30) := G_start,picture(39) := G_finish,true).	

opennotempty :-
	for(A,0,200),
		mainloop,
		(G_destfound =:= 0, A < 200 -> false else true).

%bodyofmainloop
mainloop :-
		takeLowestF,
		setCurrent(G_lowestfindex),

		%if current is dest break
		(G_currentindex =:= G_destindex -> G_destfound :=1,true),

		%switch it to closed array
		removeFromOpen(G_currentindex),
		insertToClosed(G_currentindex),
		adjacentxoffsetloop.
		
		
adjacentxoffsetloop :-

	%generate adjacent tiles
	for(AdjacentXOffset,-100,100,100),
		G_adjacentxoffset := AdjacentXOffset,
		adjacentyoffsetloop,
		(AdjacentXOffset < 100 -> fail else true).
	
adjacentyoffsetloop :-
	for(AdjacentYOffset,-100,100,100),	
		G_breakloop := 0,

		%validate adjacent, if it goes out of the map, ignore it
		G_adjacentx := x(G_currentindex) + G_adjacentxoffset,
		G_adjacenty := y(G_currentindex) + AdjacentYOffset,

		%make a adjacent index reference
		indexOf(G_adjacentx,G_adjacenty),
		G_adjacentindex := G_tile_index,
		(G_adjacentx < 0 ; G_adjacentx > 900 -> G_breakloop := 1),
		(G_adjacenty > 500 ; G_adjacenty < 0 -> G_breakloop := 1),
			
		%if it's not walkable or in closed array
		(walkable(G_adjacentindex) =:= 0 -> G_breakloop := 1),
		(closed(G_adjacentindex) =:= 1 -> G_breakloop := 1),

		%recalculate g of all adjacent tiles to later check if it's
		%better or not to get there directly
		G_newg := g(G_currentindex) + 10,
		(G_adjacentxoffset =:= AdjacentYOffset -> G_newg := g(G_currentindex) + 14),
		(G_adjacentxoffset + AdjacentYOffset =:= 0 -> G_newg := g(G_currentindex) + 14),
		openContains(G_adjacentindex),

		( G_breakloop =:= 0 ->
			(G_opencontains =:= 0 ; G_newg < g(G_adjacentindex) ->
				parentt(G_adjacentindex) := G_currentindex,

				g(G_adjacentindex) := G_newg,
				h(G_adjacentindex) := (abs(x(G_destindex) - x(G_adjacentindex)) + abs(y(G_destindex) - y(G_adjacentindex))) / 10,
				processF(G_adjacentindex),
				insertToOpen(G_adjacentindex)
				
			)
		),
		(G_breakloop =:= 0,AdjacentYOffset < 100 -> fail else true).


%---debugging---
printOpen :-
	for(I,0,59),
		write(openn(I)),
		(I < 59 -> false else nl,true).

printClosed :-
	for(I,0,59),
		write(closed(I)),
		(I < 59 -> false else nl,true).

printWalkable :-
	for(I,0,59),
		write(walkable(I)),
		(I < 59 -> false else nl,true).

printParent :-
	for(I,0,59),
		write(parentt(I)),
		(I < 59 -> false else nl,true).

printG :-
	for(I,0,59),
		write(g(I)),
		(I < 59 -> false else nl,true).

printF :-
	for(I,0,59),
		write(I),write(f(I)),nl,
		(I < 59 -> false else nl,true).

printH :-
	for(I,0,59),
		write(h(I)),
		(I < 59 -> false else nl,true).

donothing:-
	true.

timer(end):-
	(G_petunjuk =:= 0 ->
		window(_,main,intro(_),"Petunjuk",100,100,800,160),
		G_petunjuk := 1
	),
	update_window(_).

move(end) :-
	(G_pathfinddone =:= 1 ->
		(G_movindex >= 0 -> 
			picture(path(G_movindex + 1)) := G_ground,
			(G_movindex mod 2 =:= 1 ->
				picture(path(G_movindex)) := G_alien1
			else
				picture(path(G_movindex)) := G_alien2
			),
			G_movindex := G_movindex - 1,
			G_time := G_time + 1
		else
			window(_,main,score(_),"score",100,100,500,160),G_pathfinddone := 0
		)
	).
		
score(paint) :-
	text_out(25,50,"Waktu anda adalah " + print(G_time) + " detik. Cari lagi rute yang lebih lama!"),
	true.

indexOf(X,Y) :-
	G_tile_index := X//100 + 10 * Y//100,
	true.
	
processF(Tile_index) :-
	f(Tile_index) := g(Tile_index) + h(Tile_index),
	true.

takeLowestF :-
	G_lowestf := 9999,
	for(I,0,59),
		(openn(I) =:= 1 ->
			(f(I) < G_lowestf ->
				G_lowestf := f(I),
				G_lowestfindex := I)
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

openContains(Tile_index) :-
	(openn(Tile_index) =:= 1 -> G_opencontains := 1 else G_opencontains := 0),
	true.

reconstructPath:-
	Current := G_destindex,
	for(I,0,999),
		G_pathlen := I,
		path(I) := Current,
		Current := parentt(Current),
		(Current =:= G_spawnindex -> path(I + 1) := Current, true else false).

printPath:-	
	for(I,G_pathlen,0,-1),
		write(path(I)),nl,
		(I =:= 0 -> true else false).
	
		

	

	
		


