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
black(1,1).
black(1,3).
black(3,3).
black(4,2).


% ------------------------------------


% Check if (X,Y) is a White Cell:
is_white(X,Y):- cell(X,Y,_) , not(black(X,Y)).

% Finds First White nextNumber(N) in Row
%row_next(_,5,_):- false,!.
row_next(X,Y,N):- cell(X,Y,Y1), ( (is_white(X,Y) , Y1 =:= N)-> true,! ; NY is Y+1 ,row_next(X,NY,N) ).

% Finds First White prevNumber(N) in Row
%row_prev(_,0,_):- false,!. 
row_prev(X,Y,N):- cell(X,Y,Y1), ( (is_white(X,Y) , Y1 =:= N)-> true,! ; NY is Y-1 ,row_prev(X,NY,N) ).

% Finds First White nextNumber(N) in Column
%column_next(5,_,_):- false,!.
column_next(X,Y,N):- cell(X,Y,Y1), ( (is_white(X,Y) , Y1 =:= N)-> true,! ; NX is X+1 ,column_next(NX,Y,N) ).

% Finds First White prevNumber(N) in Column
%column_prev(0,_,_):- false,!. 
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

