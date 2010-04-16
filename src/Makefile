SHELL := bash

MPWD := $(shell pwd)
D_BEHSIM := $(MPWD)/../sim/beh
D_POSTSIM := $(MPWD)/../sim/post
POST_VHO := $(MPWD)/../quartus/calc/simulation/modelsim/calc.vho
POST_SDO := $(MPWD)/../quartus/calc/simulation/modelsim/calc_vhd.sdo
POST_SDO_INST := inst

WORK := work

# o reihenfolge ist wichtig
# o keine testbechnes hier angeben
BEH_IFILES = gen_pkg foo
BEH_IFILES := $(strip $(BEH_IFILES))

# o keine testbenches hier angeben
# o beachte, dass sich viele files schon in dem VHO file befinden -- es muessen eigentlich nur
#   abhaengigkeiten fuer die testbenches angegeben werden
POST_IFILES = gen_pkg
POST_IFILES := $(strip $(POST_IFILES))

#virtuelle targets fuer behsim: weil wir sowas wie ein objectfile von vcom nicht bekommen. bessere ideen sind willkommen
BEH_VTARGETS := $(foreach n, $(BEH_IFILES), $(D_BEHSIM)/$(WORK)/$(n)/_primary.dat)

#virtuelle targets fuer postsim
POST_VTARGETS := $(foreach n, $(shell grep ENTITY $(POST_VHO) | awk '{ print $$2 }'), $(D_POSTSIM)/$(WORK)/$(n)/_primary.dbs)
POST_VTARGETS += $(foreach n, $(POST_IFILES), $(D_POSTSIM)/$(WORK)/$(n)/_primary.dat)


all: behsim

#behsim
behsim: $(D_BEHSIM)/modelsim.ini $(BEH_VTARGETS)

$(D_BEHSIM)/modelsim.ini:
	@echo " INIT for behavioural simulation"
	@mkdir -p $(D_BEHSIM)
	@#make fuehrt jeden befehl in einer eigenen shell aus, deswegen ein "oneliner"
	@cd $(D_BEHSIM); \
	vlib work > /dev/null ; \
	vmap work work > /dev/null ;

$(D_BEHSIM)/$(WORK)/%/_primary.dat: %.vhd $(D_BEHSIM)/modelsim.ini
	@echo " CC    $<"
	@cd $(D_BEHSIM); \
	vcom -work $(WORK) $(MPWD)/$<

beh_%: $(D_BEHSIM)/$(WORK)/beh_%_tb/_primary.dat beh_%_tb.do behsim
	cd $(D_BEHSIM); \
	vsim -t ps "work.$@_tb(sim)" -f /dev/null -do $(MPWD)/$@_tb.do

#postsim
postsim: $(POST_VHO) $(D_POSTSIM)/modelsim.ini $(POST_VTARGETS)

$(D_POSTSIM)/modelsim.ini:
	@echo " INIT for post-layout simulation"
	@mkdir -p $(D_POSTSIM)
	@cd $(D_POSTSIM); \
	vlib work > /dev/null ; \
	vmap work work > /dev/null ;

$(D_POSTSIM)/$(WORK)/%/_primary.dbs: $(POST_VHO) $(D_POSTSIM)/modelsim.ini
	@echo " CC    $<"
	@cd $(D_POSTSIM); \
	vcom -work $(WORK) $(POST_VHO)

$(D_POSTSIM)/$(WORK)/%/_primary.dat: %.vhd $(D_POSTSIM)/modelsim.ini
	@echo " CC    $<"
	@cd $(D_POSTSIM); \
	vcom -work $(WORK) $(MPWD)/$<

post_%: $(D_POSTSIM)/$(WORK)/post_%_tb/_primary.dat post_%_tb.do postsim $(POST_SDO)
	cd $(D_POSTSIM); \
	vsim -t ps "work.$@_tb(sim)" -sdftyp /$(POST_SDO_INST)=$(POST_SDO) -f /dev/null -do $(MPWD)/$@_tb.do

$(POST_VHO) $(POST_SDO):
	@if [ -f $@ ]; \
	then echo "vho/sdo: passt"; true ; \
	else echo "Fehler: $@ muss mit quartus erstellt werden"; false; \
	fi

quartus:
	@echo "Die angebotene (free) Quartus II Version aka Web Edition funktioniert "
	@echo "unter Linux leider nicht. (Build endet mit einem Error, auch mit dem debouncing-bsp der LVA)."
	@echo "Befehl um es trotzdem zu probieren (falls installiert):"
	@echo "$$ unset LS_COLORS #falls gesetzt..."
	@echo -n "$$ quartus # bin verzeichnis von quartus muss sich in "; echo -n "$$"; echo "PATH befinden"
	@echo "in windows (per cygwin?): TODO"

.PHONY: clean
clean:
	rm -Rf $(D_BEHSIM) $(D_POSTSIM)

