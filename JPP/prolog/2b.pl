last(E, [E]).
last(E, [_|L]) :-  last(E, L).

addone([],[]).
addone([X|Xs],[Y|Ys]) :- Y is X+1, addone(Xs,Ys).


suma2([],A,A).
suma2([X|Xs],A,N) :- A1 is A+X, suma2(Xs,A1,N).
suma2(Xs,N) :- suma2(Xs,0,N).

min([M], M).

min(T, X) :- (L =< X -> min([L|T], L); min([L|T], X)).