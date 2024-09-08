% Joanna Wojciechowska 429677

:- ensure_loaded(library(lists)).

wyprawy :-
    current_prolog_flag(argv, [Sciezka|_]),
    write(Sciezka). 
    
wczytajPlik(NazwaPliku, Trasy) :-
    catch(
        open(NazwaPliku, read, Strumien),
        error(existence_error(source_sink, Path), _),
        (format('Error: brak pliku o nazwie - ~w~n', [Path]), fail)
    ),
    wczytajTrasy(Strumien, Trasy),
    close(Strumien).

wczytajTrasy(Strumien, []) :-
    at_end_of_stream(Strumien).

wczytajTrasy(Strumien, [Trasa | Trasy]) :-
    read(Strumien, Trasa),
    wczytajTrasy(Strumien, Trasy).