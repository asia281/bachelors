enumFromTo(N, N, [N]).
enumFromTo(N, M, [N|T]) :- N < M, N1 is N + 1, enumFromTo(N1, M, T).

% odwrotna(L, A, R) :- R == reverse L ++ A
odwrotna([], Acc, Acc).
odwrotna([H|T], Acc, Res) :- odwrotna(T, [H|Acc], Res).