W treści nie jest sprecyzowane czy mamy sprawdzać istnienie nazw miast i tras.

Można przyjąć jedno z dwóch rozwiązań: 
- nie sprawdzamy ich istnienia, dzięki czemu mamy krótszy kod,
- sprawdzamy ich istnienie (co zajmuje 5-10 linii kodu).

O ile będzie to testowane (jest szansa, że ten edge-case nie będzie w testach),
to słuszniejsze wydaje się sprawdzanie istnienia miast.
Jedynym argumentem za brakiem sprawdzenia jest krótszy kod,
jednak z treści wiadomo, że
"Program powinien sprawdzać poprawność danych wprowadzanych interaktywnie".
Biorąc pod uwagę, że zdecydowanie najdłuższą częścią tego zadania
jest parsowanie i sprawdzanie poprawności interakcji użytkownika,
nie zdziwiłbym się, gdyby były sprawdzane wszystkie edge-case'y.

Sprawdzanie ich istnienia wydaje się być bardziej poprawną opcją,
bo zawsze można zaargumentować, że brak tych miast jest niepoprawne:
"Gdyby użytkownik portalu PKP wyszukał trasy Szcecin->Warszawa 
i nic by nie znalazło, to użytkownik mógłby źle wywnioskować, że danego dnia
nie ma pociągów między tymi miastami."

Słuszność niesprawdzania nazw już trudno jest zaargumentować.

Też jeżeli wszyscy będziemy się trzymać jednej wersji error handlingu,
to nawet gdyby autorzy zadania założyli sobie inną wersję,
to prawdopodobnie się do nas dostosują jeżeli będziemy mieć spójne podejście
(co się już zdarzyło dodatnią ilość razy na innych przedmiotach).
