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


is_white(X,Y):- cell(X,Y,_) , not(black(X,Y)).

% Finds nextNumber(N) in Row
row_next(_,5,_):- false,!.
row_next(X,Y,N):- cell(X,Y,Y1), ( (Y1 =\= N)-> NY is Y+1 ,row_next(X,NY,N) ; true,!).

% Finds prevNumber(N) in Row
row_prev(_,0,_):- false,!. 
row_prev(X,Y,N):- cell(X,Y,Y1), ( (Y1 =\= N)-> NY is Y-1 ,row_prev(X,NY,N) ; true,!).

% Finds nextNumber(N) in Column
column_next(5,_,_):- false,!.
column_next(X,Y,N):- cell(X,Y,Y1), ( (Y1 =\= N)-> NX is X+1 ,column_next(NX,Y,N) ; true,!).

% Finds prevNumber(N) in Column
column_prev(0,_,_):- false,!. 
column_prev(X,Y,N):- cell(X,Y,Y1), ( (Y1 =\= N)-> NX is X-1 ,column_prev(NX,Y,N) ; true,!).


