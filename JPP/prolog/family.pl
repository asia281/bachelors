dziecko(Dziecko, Matka, Ojciec)
dziecko(jasio, ewa, jan).
dziecko(stasio, ewa, jan).
dziecko(jan, zofia, adam).
dziecko(adam, anna, jakub).

ojciec(Ojciec, Dziecko) :- dziecko(Dziecko, _, Ojciec)
matka(Matka, Dziecko) :- dziecko(Dziecko, Matka, _)
