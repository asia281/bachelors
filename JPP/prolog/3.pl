tree(empty).
tree(P, N) :- tree(P).
tree(L, N), tree(P, N) :- N1 is N+1, tree(node(L,_,P), N1).

fin(M, N) :- M =< N, M => 0 !.

liscie(empty, []).

lenght([], 0).
lenght([_|T], N1) :- lenght(T, N), N1 is N+1.

middle_odd(List, Middle) :-
    length(List, Length),
    Length mod 2 =:= 1, % check if the length is odd
    MiddleIndex is (Length + 1) // 2, % compute the index of the middle element
    nth1(MiddleIndex, List, Middle).

podlista([], L, _).
podlista(L1, L2) :- podlista(L1, L2, L1).
podlista([G | R], [G1 | R1], Tmp) :- podlista(Tmp, R1, Tmp).
podlista([G | R], [G | R1], Tmp) :- podlista(R, R1, Tmp).


\+()