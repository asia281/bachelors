% Joanna Wojciechowska 429677
:- ensure_loaded(library(lists)).

wyprawy :- 
    current_prolog_flag(argv, [FileName|_]),
    open(FileName, read, Stream),
    readEdges(Stream, PrevEdges),
    close(Stream),
    parseEdges(PrevEdges, Edges),
    readAndFind(Edges).

% Read edges from file.
readEdges(Stream, Edges) :-
    read(Stream, Edge),
    (Edge = end_of_file -> Edges = []
    ;readEdges(Stream, RestEdges),
    Edges = [Edge|RestEdges]
    ).

parseEdges([], []).
parseEdges([end_of_file], []).
parseEdges([trasa(Tid, Source, Destination, Type, oba, Km)|Rest], [Added1,Added2|Acc]) :- 
    Added1 = edge(Tid, Source, Destination, Type, Km),
    Added2 = edge(Tid, Destination, Source, Type, Km),
    parseEdges(Rest, Acc).

parseEdges([trasa(Tid, Source, Destination, Type, jeden, Km)|Rest], [Added|Acc]) :- 
    Added = edge(Tid, Source, Destination, Type, Km),
    parseEdges(Rest, Acc).

% Read input for one task and find all routes satisfying given conditions.
readAndFind(Edges) :-
    write("Podaj miejsce startu: "), 
    read(Source),
    Source \== koniec,
    write("Podaj miejsce koncowe: "),
    read(Destination),
    Destination \== koniec,
    !,
    parseConditions(Length, Types),
    findPaths(Edges, Source, Destination, Types, Length, FoundRoutes),
    printMultiRoutes(FoundRoutes),
    readAndFind(Edges). 

readAndFind(_) :- writeln("Koniec programu. Milych wedrowek!").

% Read, parse and check conditions on input.
parseConditions(Length, Types) :- 
    write("Podaj warunki: "),
    read(Cond),
    readConditions(Cond, Conditions),
    checkConditions(Conditions, 0, Length, Types),
    !.

parseConditions(Length, Types) :- 
    writeln("Podaj jeszcze raz."),    
    parseConditions(Length, Types).

% Transform tuple of conditions to the list.
readConditions(nil, []).
readConditions((Cond, Conditions), [Cond|Acc]) :- 
    !, readConditions(Conditions, Acc).
readConditions(X, [X]).

checkConditions([], _, nil, []).

% Append rodzaj condition.
checkConditions([rodzaj(R)|Conditions], N, Length, [R|Types]) :- 
    !, checkConditions(Conditions, N, Length, Types).

% Check dlugosc condition and append it to accumulator.
checkConditions([dlugosc(Comp, N)|Conditions], 0, dlugosc(Comp, N), Types) :-
    checkComp(Comp),
    number(N), N >= 0,
    !, checkConditions(Conditions, 1, nil, Types).

checkConditions([dlugosc(_, _)|_], _, _, _) :-
    write("Error: za duzo warunkow na dlugosc.\n"),
    !, fail.

% Check inncorect condition.
checkConditions([BadCond|_], _, _, _) :-
    format("Error: niepoprawny warunek - ~w~n", [BadCond]),
    fail.

% Check if comparator sign is one of possible ones.
checkComp(eq).
checkComp(lt).
checkComp(le).
checkComp(gt).
checkComp(ge).

% Check dlugosc condition with a total length of a path.
checkLength(dlugosc(eq, K), K).
checkLength(nil, _).
checkLength(dlugosc(lt, K), Km) :- Km < K.
checkLength(dlugosc(le, K), Km) :- Km =< K.
checkLength(dlugosc(gt, K), Km) :- Km > K.
checkLength(dlugosc(ge, K), Km) :- Km >= K.

checkCondsNotLen(Edge, Visited, Type, Types) :- 
    \+ member(Edge, Visited),
    checkType(Type, Types).

checkAllConds(Edge, Visited, Length, Sum, Type, Types) :- 
    checkLength(Length, Sum),
    checkCondsNotLen(Edge, Visited, Type, Types).


% findPath(Edges, Source, Destination, Types, Length, PrevSum, Visited, (PathAcc, SumAcc))
% Find path finds a path tak satisfies conditions. 
% Edges - list of all available edges (from .txt file).
% Source - 
% Destination - 
% Types - list of all available types of edge (from Podaj Warunki).
% Length - length condition from input or nil if not given.
% PrevSum - sum of visited edges.
% Visited - list  of visited edges.
% (PathAcc, SumAcc) - path and sum to return. 
% Find any edge.
findPath(Edges, nil, nil, Types, Length, 0, Visited, ([Edge], Sum)) :-
    member(Edge, Edges),
    Edge = edge(_, _, _, Type, Sum),
    checkAllConds(Edge, Visited, Length, Sum, Type, Types).

% Find an edge from Source.
findPath(Edges, Source, nil, Types, Length, PrevSum, Visited, ([Edge], Sum)) :-
    member(Edge, Edges),
    Edge = edge(_, Source, _, Type, Km),
    Sum is PrevSum + Km,
    checkAllConds(Edge, Visited, Length, Sum, Type, Types).

% Find an edge to Destination.
findPath(Edges, nil, Destination, Types, Length, 0, Visited, ([Edge], Sum)) :-
    member(Edge, Edges),
    Edge = edge(_, _, Destination, Type, Sum),
    checkAllConds(Edge, Visited, Length, Sum, Type, Types).

% Find an edge from Source to Destination.
findPath(Edges, Source, Destination, Types, Length, PrevSum, Visited, ([Edge], Sum)) :-
    member(Edge, Edges),
    Edge = edge(_, Source, Destination, Type, Km),
    Sum is PrevSum + Km,
    checkAllConds(Edge, Visited, Length, Sum, Type, Types).

% Find a path to Destination.
findPath(Edges, nil, Destination, Types, Length, PrevSum, Visited, ([Edge|Path], SumAcc)) :-
    Edge = edge(_, _, Intermediate, Type, Km),
    member(Edge, Edges),
    Sum is PrevSum + Km,
    checkCondsNotLen(Edge, Visited, Type, Types),
    findPath(Edges, Intermediate, Destination, Types, Length, Sum, [Edge|Visited], (Path, SumAcc)).

% Find a path from Source to Destination.
findPath(Edges, Source, Destination, Types, Length, PrevSum, Visited, ([Edge|Path], SumAcc)) :-
    member(Edge, Edges),
    Edge = edge(_, Source, Intermediate, Type, Km),
    Sum is PrevSum + Km,
    checkCondsNotLen(Edge, Visited, Type, Types),
    findPath(Edges, Intermediate, Destination, Types, Length, Sum, [Edge|Visited], (Path, SumAcc)).

% Check if route has a given type.
checkType(_, []).
checkType(Type, L) :- member(Type, L).

% Find all paths between Source and Destination
findPaths(Edges, Source, Destination, Types, Length, FoundRoutes) :-
    findAll(findPath(Edges, Source, Destination, Types, Length, 0, []), FoundRoutes).

findAll(Condition, Acc, FoundRoutes) :- 
    call(Condition, X), 
    \+(member(X, Acc)), 
    !, findAll(Condition, [X|Acc], FoundRoutes).
findAll(_, Acc, Acc).
findAll(Condition, FoundRoutes) :- findAll(Condition, [], FoundRoutes).

% Print all found routes.
printMultiRoutes([]).
printMultiRoutes([(Route, Sum)|Routes]) :- 
    printRoutes(Route, Sum),
    printMultiRoutes(Routes).

% Print single route.
printRoutes([Edge|[]], Sum) :-
    Edge = edge(Tid, Source, Destination, Type, _),
    format("~w -(~w,~w)-> ~w~nDlugosc trasy: ~w.~n", 
    [Source, Tid, Type, Destination, Sum]).

printRoutes([Edge|Routes], Sum) :-
    Edge = edge(Tid, Source, _, Type, _),
    format("~w -(~w,~w)-> ", [Source, Tid, Type]),
    printRoutes(Routes, Sum).