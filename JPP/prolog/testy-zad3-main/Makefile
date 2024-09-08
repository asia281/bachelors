# On students (it has to work):
#solution: solution.sav
#	spld --static --exechome=/opt/sicstus/bin/ solution.sav -o solution
#solution.sav: solution.pl
#	echo "compile('solution.pl'). save_program('solution.sav')." | sicstus

# Alternatively, for local uses:
 solution: solution.pl
	swipl --goal=wyprawy --stand_alone=true -o solution -c solution.pl

