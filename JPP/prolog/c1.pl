:- ensure_loaded(library(lists)).

% Predykat wczytujący trasy z pliku
wczytaj_trasy(Sciezka) :-
    open(Sciezka, read, Strumien),
    wczytaj_trasy(Strumien, []),
    close(Strumien).

wczytaj_trasy(Stream, Trasy) :-
    read(Stream, Trasa),
    (Trasa = end_of_file -> Trasy = [] ; wczytaj_trasy(Stream, [Trasa | Trasy])).

% Predykat sprawdzający, czy dany warunek na długość trasy jest spełniony
spelnia_warunek(dlugosc(eq, K), K).
spelnia_warunek(dlugosc(lt, K), Dlugosc) :- Dlugosc < K.
spelnia_warunek(dlugosc(le, K), Dlugosc) :- Dlugosc =< K.
spelnia_warunek(dlugosc(gt, K), Dlugosc) :- Dlugosc > K.
spelnia_warunek(dlugosc(ge, K), Dlugosc) :- Dlugosc >= K.

% Predykat sprawdzający, czy dana trasa spełnia podane warunki
spelnia_warunki(Trasa, Warunki) :-
    spelnia_warunki(Trasa, Warunki, []).

spelnia_warunki(_, [], _).
spelnia_warunki(Trasa, [Warunek | Warunki], Odwiedzone) :-
    spelnia_warunek(Warunek, Trasa),
    \+ member(Trasa, Odwiedzone),
    Trasa = trasa(_, _, Koniec, _, _, _),
    spelnia_warunki_koniec(Koniec, Warunki, [Trasa | Odwiedzone]).

spelnia_warunki_koniec(_, [], _).
spelnia_warunki_koniec(Koniec, [Warunek | Warunki], Odwiedzone) :-
    spelnia_warunek(Warunek, Koniec),
    spelnia_warunki_koniec(Koniec, Warunki, Odwiedzone).

% Predykat wyświetlający opis trasy
wyswietl_trase(trasa(Id, Skad, Dokad, Rodzaj, Kierunek, Dlugosc)) :-
    write(Skad), write(' -(r'), write(Id), write(','), write(Rodzaj), write(')-> '),
    write(Dokad), write(' Dlugosc trasy: '), write(Dlugosc), nl.



% Predykat obsługujący interaktywne wprowadzanie danych
wyprawy(Sciezka) :-
    wczytaj_trasy(Sciezka),
    repeat,
    write('Podaj miejsce startu: '), read(Start),
    write('Podaj miejsce koncowe: '), read(Koniec),
    write('Podaj warunki: '), read(Warunki),
    (Warunki = koniec -> write('Koniec programu. Milych wedrowek!'), nl, ! ;
     parse_warunki(Warunki, ParsowaneWarunki),
    znaleziono_wyprawy(Start, Koniec, ))

    znajdzWyprawy(_, _, [], []).

znajdzWyprawy(Poczatek, Koniec, [Trasa | Trasy], [Trasa | Znalezione]) :-
    Trasa = trasa(_, Poczatek, Koniec, _, _, _),
    znajdzWyprawy(Poczatek, Koniec, Trasy, Znalezione).

znajdzWyprawy(Poczatek, Koniec, [Trasa | Trasy], Znalezione) :-
    Trasa = trasa(_, Poczatek, Dokad, _, _, _),
    Poczatek \= Koniec,
    znajdzWyprawy(Dokad, Koniec, Trasy, Znalezione).

znajdzWyprawy(Poczatek, Koniec, [_ | Trasy], Znalezione) :-
    znajdzWyprawy(Poczatek, Koniec, Trasy, Znalezione).