% Hitori Game Size
size(4,4).

% Fill Grid
cell(1,1,2).
cell(1,2,2).
cell(1,3,2).
cell(1,4,4).

cell(2,1,1).
cell(2,2,4).
cell(2,3,2).
cell(2,4,3).

cell(3,1,2).
cell(3,2,3).
cell(3,3,2).
cell(3,4,1).

cell(4,1,3).
cell(4,2,4).
cell(4,3,1).
cell(4,4,2).

% Black Cells
:-dynamic(black/2).
% UnShaded Cells
:-dynamic(circle/2).


% ------------------------------------


% Check if (X,Y) is a White Cell:
is_white(X,Y):- cell(X,Y,_) , not(black(X,Y)).

% Finds First White nextNumber(N) in Row
row_next(X,Y,N):- cell(X,Y,Y1), ( (is_white(X,Y) , Y1 =:= N)-> true,! ; NY is Y+1 ,row_next(X,NY,N) ).

% Finds First White prevNumber(N) in Row
row_prev(X,Y,N):- cell(X,Y,Y1), ( (is_white(X,Y) , Y1 =:= N)-> true,! ; NY is Y-1 ,row_prev(X,NY,N) ).

% Finds First White nextNumber(N) in Column
column_next(X,Y,N):- cell(X,Y,Y1), ( (is_white(X,Y) , Y1 =:= N)-> true,! ; NX is X+1 ,column_next(NX,Y,N) ).

% Finds First White prevNumber(N) in Column
column_prev(X,Y,N):- cell(X,Y,Y1), ( (is_white(X,Y) , Y1 =:= N)-> true,! ; NX is X-1 ,column_prev(NX,Y,N) ).


% Check if element(X,Y) is unique:
unique_at(X,Y):- NX is X+1 , PX is X-1 , NY is Y+1 , PY is Y-1 , cell(X,Y,N),
					 not(row_next(X,NY,N)),
					 not(row_prev(X,PY,N)),
					 not(column_next(NX,Y,N)),
					 not(column_prev(PX,Y,N)).


% Check if list of White cells are unique:
white_cells_unique([]).
white_cells_unique([[H1,H2]|T]):- unique_at(H1,H2) , white_cells_unique(T).

% Check if the whole Grid's White cells are unique
grid_unique():- findall([X,Y],is_white(X,Y),L) , white_cells_unique(L).


% ------------------------------------


% Check if element(X,Y) has black cells neighbors:
no_blackcells_neighbors_at(X,Y):- NX is X+1 , PX is X-1 , NY is Y+1 , PY is Y-1 ,
								  not(black(X,NY)),
								  not(black(X,PY)),
								  not(black(NX,Y)),
								  not(black(PX,Y)).

% Check if list of Black cells aren't adjacent:
black_cells_not_adjacent([]).
black_cells_not_adjacent([[H1,H2]|T]):- no_blackcells_neighbors_at(H1,H2) , black_cells_not_adjacent(T).

% Check if the whole Grid's Black cells dont touch each other:
black_dont_touch():- findall([X,Y],black(X,Y),L) , black_cells_not_adjacent(L).


% ------------------------------------


% Neighbors
right_neighbor(X,Y,L):- NY is Y+1 , is_white(X,NY) , L = [X,NY] ; L = []. 
left_neighbor(X,Y,L):- PY is Y-1 , is_white(X,PY) , L = [X,PY] ; L = []. 
up_neighbor(X,Y,L):- PX is X-1 , is_white(PX,Y) , L = [PX,Y] ; L = []. 
down_neighbor(X,Y,L):- NX is X+1 , is_white(NX,Y) , L = [NX,Y] ; L = []. 

% Return list[4] : neighbors of a Cell #Throws Empty lists
neighbors([],[]).
neighbors([X,Y],L):- is_white(X,Y),
					 right_neighbor(X,Y,L1),
					 left_neighbor(X,Y,L2),
					 up_neighbor(X,Y,L3),
					 down_neighbor(X,Y,L4),
					 L = [L1|[L2|[L3|[L4]]]],!.

% My Set:
member([X,Y],[[X,Y]|_]).
member([X,Y],[_|T]) :- member([X,Y],T).

add_set([],L2,L2).
add_set([X,Y],L2,R):- not(member([X,Y],L2)) , R = [[X,Y]|L2] ,! ; R = L2.

% Length of the List:
len([_],Y):- Y is 1.
len([_|T],Y):- len(T,Y1),Y is Y1 + 1 .

% [] Operators:
first([F,_|_],F).
second([_,S|_],S).
third([_,_,T|_],T).
forth([_,_,_,F|_],F).

% Collect all adjacent White Cells in list:
calculate_white_space([],VL,VL).
calculate_white_space(L,VL,R):-
						not(member(L,VL)),
						% write(L),nl,
						add_set(L,VL,RES1),
						
						neighbors(L,NB),
						first(NB,L1),
						second(NB,L2),
						third(NB,L3),
						forth(NB,L4),
						
						calculate_white_space(L1,RES1,RES2),!,
						calculate_white_space(L2,RES2,RES3),!,
						calculate_white_space(L3,RES3,RES4),!,
						calculate_white_space(L4,RES4,R),!
						; R = VL .

% Check if all White Cells is adjacent:
white_continues():- is_white(X,Y),!, calculate_white_space([X,Y],[],R),
					len(R,LEN1),!,findall([A,B],is_white(A,B),L) , len(L,LEN2),!, LEN1=:=LEN2.

solved():- grid_unique(),
		   black_dont_touch(),
		   white_continues().


% ------------------------------------
% --------------PART 2----------------
% ------------------------------------

% ---------- Starting techniques -----

% #1 Searching for adjacent triplets:
% Mark Cell as shaded(Black) or not shaded(Circle)
shade(X,Y):- black(X,Y),! ;
	neighbors([X,Y],NB),
	first(NB,L1),
	unshade_around_shaded(L1),
	second(NB,L2),
	unshade_around_shaded(L2),
	third(NB,L3),
	unshade_around_shaded(L3),
	forth(NB,L4),
	unshade_around_shaded(L4),
	assert(black(X,Y)),!.

unshade_around_shaded([]).
unshade_around_shaded([X,Y]):- unshade(X,Y).

unshade(X,Y):- circle(X,Y),! ; assert(circle(X,Y)),!.

% Check for adjacent triplets rows starting from[X1,Y1]:
adjacent_row_at(X1,Y1):-
	Y2 is Y1+1 , Y3 is Y1+2,
	cell(X1,Y1,N1) , cell(X1,Y2,N2) , cell(X1,Y3,N3),
	( N1 =:= N2 , N2 =:= N3 ->
		shade(X1,Y1),
		unshade(X1,Y2),
		shade(X1,Y3),% write(X1),write(Y1),write("->triple Founded[Row]"),nl,
		Y4 is Y1+3,
		adjacent_row_at(X1,Y4)
		;
		adjacent_row_at(X1,Y2)
	).

% Loop through all Rows:
search_adjacent_triplets_rows([X,Y]):-
	cell(X,Y,_) , \+ adjacent_row_at(X,Y),

	NX is X+1,
	search_adjacent_triplets_rows([NX,Y]);
	false,!.


% Check for adjacent triplets columns starting from[X1,Y1]:
adjacent_column_at(X1,Y1):-
	X2 is X1+1 , X3 is X1+2,
	cell(X1,Y1,N1) , cell(X2,Y1,N2) , cell(X3,Y1,N3),
	( N1 =:= N2 , N2 =:= N3 ->
		shade(X1,Y1),
		unshade(X2,Y1),
		shade(X3,Y1),% write(X1),write(Y1),write("->triple Founded[Column]"),nl,
		X4 is X1+3,
		adjacent_column_at(X4,Y1)
		;
		adjacent_row_at(X2,Y1)
	).

% Loop through all Columns:
search_adjacent_triplets_columns([X,Y]):-
	cell(X,Y,_) , \+ adjacent_column_at(X,Y),

	NY is Y+1,
	search_adjacent_triplets_columns([X,NY]);
	false,!.


% #2 Square between a pair:
% Check for pairs in row starting from[X1,Y1]:
pair_row_at(X1,Y1):-
	Y2 is Y1+1 , Y3 is Y1+2,
	cell(X1,Y1,N1) , cell(X1,Y2,_) , cell(X1,Y3,N3),
	( N1 =:= N3 ->
		unshade(X1,Y2),
		%write(X1),write(Y1),write("->pair Founded[Row]"),nl,
		pair_row_at(X1,Y2)
	).

% Loop through all Rows:
search_pairs_rows([X,Y]):-
	cell(X,Y,_) , \+ pair_row_at(X,Y),

	NX is X+1,
	search_pairs_rows([NX,Y]);
	false,!.


% Check for pairs in column starting from[X1,Y1]:
pair_column_at(X1,Y1):-
	X2 is X1+1 , X3 is X1+2,
	cell(X1,Y1,N1) , cell(X2,Y1,_) , cell(X3,Y1,N3),
	( N1 =:= N3 ->
		unshade(X2,Y1),
		%write(X1),write(Y1),write("->pair Founded[Column]"),nl,
		pair_column_at(X2,Y1)
	).

% Loop through all Columns:
search_pairs_columns([X,Y]):-
	cell(X,Y,_) , \+ pair_column_at(X,Y),

	NY is Y+1,
	search_pairs_columns([X,NY]);
	false,!.



% ---------- Basic techniques --------


% #1&2 Shading squares in rows and columns (Recurring Numbers) & Un-shading around shaded squares:
% iterate on first column
find_recurring_numbers([X,Y]):-
	cell(X,Y,_) , \+ find_recurring_numbers_at_row(X,Y),

	NX is X+1,
	find_recurring_numbers([NX,Y]);
	false,!.

% iterate on first row
find_recurring_numbers_at_row(X,Y):-
	cell(X,Y,_),
	check_recurring_number(X,Y),
	NY is Y+1,
	find_recurring_numbers_at_row(X,NY).

% check if cell[X,Y] is repeated in it's row\column (in order to shade it)
check_recurring_number(X,Y):-
	not(black(X,Y)),
	check_row(X,Y),!,
	check_col(X,Y),!
	;true,!.

% check if cell[X,Y] is repeated in it's row
check_row(X,Y):- cell(X,Y,N) , Y1 is Y+1 , row_next(X,Y1,N) , shade(X,Y) ; true,!.
% check if cell[X,Y] is repeated in it's column
check_col(X,Y):- cell(X,Y,N) , X1 is X+1 , column_next(X1,Y,N) , shade(X,Y) ; true,!.


% ---------- Corner techniques -------
% Check the four corners
corner_techniques():-
	corner_up_left(),!,
	corner_up_right(),!,
	corner_down_left(),!,
	corner_down_right(),!.


corner_up_left():-
	cell(1,1,N1),cell(1,2,N2),cell(2,1,N3),
	N1=:=N2 , N2=:=N3 , shade(1,1)
	;true,!.

corner_up_right():-
	size(_,Columns) , Y1 is Columns-1,
	cell(1,Columns,M1),cell(1,Y1,M2),cell(2,Columns,M3),
	M1=:=M2 , M2=:=M3 , shade(1,Columns)
	;true,!.

corner_down_left():-
	size(Rows,_) , X1 is Rows-1,
	cell(Rows,1,L1),cell(X1,1,L2),cell(Rows,2,L3),
	L1=:=L2 , L2=:=L3 , shade(Rows,1)
	;true,!.

corner_down_right():-
	size(Rows,Columns) , X1 is Rows-1 , Y1 is Columns-1,
	cell(Rows,Columns,K1),cell(X1,Columns,K2),cell(Rows,Y1,K3),
	K1=:=K2 , K2=:=K3 , shade(Rows,Columns)
	;true,!.


% ------------------------------------
%backtrack(3):- grid_unique(),!.
backtrack(16):- grid_unique(),!,white_continues(),!,black_dont_touch(),!.
backtrack(CellNumber):-
	CellNumber2 is CellNumber,
	CellNumber2 =\= 16,
	write(CellNumber),nl,
	white_continues(),black_dont_touch(),
	TI is  CellNumber / 4,
	I is floor(TI), II is I + 1,
	J is CellNumber mod 4, JJ is J + 1,
	NCN is CellNumber + 1,
	%write(II),write(JJ),write(NCN),nl,
	shade(II,JJ), ( not(backtrack(NCN)) -> retract(black(II,JJ)) , backtrack(NCN);true).


ss():-findall([X,Y],black(X,Y),L) , write(L).
% ------------------------------------



solve():-
	% Starting techniques:
	triples(),
	\+ search_pairs_rows([1,1]),
	\+ search_pairs_columns([1,1]),
	% Basic techniques:
	%\+ find_recurring_numbers([1,1]),
	% Corner techniques:
	corner_techniques(),
	% Advanced techniques:
	backtrack(0).

triples():-
	\+ search_adjacent_triplets_rows([1,1]),
	\+ search_adjacent_triplets_columns([1,1]).


main():-
	init(),
	solve(),
	solved().
	
init():-
	retractall(black(_,_)),
	retractall(circle(_,_)).