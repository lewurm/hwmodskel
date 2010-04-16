#alias fuer simulation neustarten
alias rr "restart -f"

#signale hinzufuegen
add wave *

#rauszoomen
wave zoomout 500.0

#simulation starten und 100ms lang laufen lassen (wird durch assert abgebrochen)
run -all

#ganz nach links scrollen
wave seetime 0
