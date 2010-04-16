SHELL := bash

MPWD := $(shell pwd)
D_BEHSIM := $(MPWD)/../sim/beh
D_POSTSIM := $(MPWD)/../sim/post
POST_VHO := $(MPWD)/../quartus/calc/simulation/modelsim/calc.vho
POST_SDO := $(MPWD)/../quartus/calc/simulation/modelsim/calc_vhd.sdo
POST_SDO_INST := inst
QUARTUS := $(MPWD)/../quartus/calc
QUOPT := --read_settings_files=on --write_settings_files=off calc -c calc

HN := $(shell hostname)
TILABHOSTS := $(shell echo ti{1..9}) apps1

WORK := work

# o reihenfolge ist wichtig
# o keine testbechnes hier angeben
BEH_IFILES = gen_pkg alu
BEH_IFILES := $(strip $(BEH_IFILES))

# o keine testbenches hier angeben
# o beachte, dass sich viele files schon in dem VHO file befinden -- es muessen eigentlich nur
#   abhaengigkeiten fuer die testbenches angegeben werden
POST_IFILES = gen_pkg
POST_IFILES := $(strip $(POST_IFILES))

#virtuelle targets fuer behsim: weil wir sowas wie ein objectfile von vcom nicht bekommen. bessere ideen sind willkommen
BEH_VTARGETS := $(foreach n, $(BEH_IFILES), $(D_BEHSIM)/$(WORK)/$(n)/_primary.dat)

#virtuelle targets fuer postsim
POST_VTARGETS := $(foreach n, $(POST_IFILES), $(D_POSTSIM)/$(WORK)/$(n)/_primary.dat)


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
	vsim "work.$@_tb(sim)" -f /dev/null -do $(MPWD)/$@_tb.do

#postsim
postsim: $(POST_VHO) $(D_POSTSIM)/modelsim.ini $(POST_VTARGETS)

$(D_POSTSIM)/modelsim.ini:
	@echo " INIT for post-layout simulation"
	@mkdir -p $(D_POSTSIM)
	@cd $(D_POSTSIM); \
	vlib work > /dev/null ; \
	vmap work work > /dev/null ;

$(D_POSTSIM)/$(WORK)/%/_primary.dat: %.vhd $(D_POSTSIM)/modelsim.ini
	@echo " CC    $<"
	@cd $(D_POSTSIM); \
	vcom -work $(WORK) $(MPWD)/$<

post_%: $(D_POSTSIM)/$(WORK)/post_%_tb/_primary.dat post_%_tb.do postsim $(POST_SDO)
	cd $(D_POSTSIM); \
	vsim "work.$@_tb(sim)" -sdftyp /$(POST_SDO_INST)=$(POST_SDO) -f /dev/null -do $(MPWD)/$@_tb.do

$(QUARTUS):
	@echo -n " Quartus  generate project"
ifeq ($(findstring $(HN), $(TILABHOSTS)),$(HN))
	@echo "(@tilab)"
	@cd ../quartus; ./linux_tilab.sh
else
	@echo "(not @ tilab)"
	@cd ../quartus; ./linux_web.sh
endif

#TODO: more targets plz...
$(POST_VHO) $(POST_SDO): $(QUARTUS) postsim
	@echo " Quartus  analysis & synthesis"
	@unset LS_COLORS; cd $(QUARTUS); \
	quartus_map $(QUOPT)
	@echo " Quartus  fitter"
	@unset LS_COLORS; cd $(QUARTUS); \
	quartus_fit $(QUOPT)
	@echo " Quartus  assembler"
	@unset LS_COLORS; cd $(QUARTUS); \
	quartus_asm $(QUOPT)
	@echo " Quartus  timing analyzer"
	@unset LS_COLORS; cd $(QUARTUS); \
	quartus_tan $(QUOPT) --timing_analysis_only
	@echo " Quartus  EDA netlist writer"
	@unset LS_COLORS; cd $(QUARTUS); \
	quartus_eda $(QUOPT)
	#not nice atm :/
	@echo " CC    $(POST_VHO)"
	@cd $(D_POSTSIM); \
	vcom -work $(WORK) $(POST_VHO)

.PHONY: clean
clean:
	rm -Rf $(D_BEHSIM) $(D_POSTSIM) $(QUARTUS)

