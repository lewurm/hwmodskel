SHELL := bash

MPWD := $(shell pwd)
D_BEHSIM := $(MPWD)/../sim/beh
D_POSTSIM := $(MPWD)/../sim/post
POST_VHO := $(MPWD)/../quartus/calc/simulation/modelsim/calc.vho
POST_SDO := $(MPWD)/../quartus/calc/simulation/modelsim/calc_vhd.sdo
POST_SDO_INST := inst
QUARTUS := $(MPWD)/../quartus/calc
QUOPT := --read_settings_files=on --write_settings_files=off calc -c calc

ifeq ($(findstring $(HN), $(TILABHOSTS)),$(HN))
QUMACRO := unset LS_COLORS; cd $(QUARTUS); export LD_LIBRARY_PATH=/opt/quartus/quartus/linux64; export LM_LICENSE_FILE=26888@quartus; 
else
QUMACRO := unset LS_COLORS; cd $(QUARTUS);
endif

HN := $(shell hostname)
TILABHOSTS := $(shell echo ti{1..9}) apps1

WORK := work

# o source files der module
# o reihenfolge ist wichtig
# o keine testbechnes hier angeben
SRCFILES := foo

# o files der packages
# o keine testbechnes hier angeben
PKGFILES := gen_pkg

BEH_IFILES = $(PKGFILES) $(SRCFILES)
BEH_IFILES := $(strip $(BEH_IFILES))

POST_IFILES = $(PKGFILES)
POST_IFILES := $(strip $(POST_IFILES))

POST_SRC = $(SRCFILES)


#virtuelle targets fuer behsim: weil wir sowas wie ein objectfile von vcom nicht bekommen. bessere ideen sind willkommen
BEH_VTARGETS := $(foreach n, $(BEH_IFILES), $(D_BEHSIM)/$(WORK)/$(n)/_primary.dat)

#virtuelle targets fuer packagefiles der postsim
POST_VTARGETS := $(foreach n, $(POST_IFILES), $(D_POSTSIM)/$(WORK)/$(n)/_primary.dat)

#virtuelle targets fuer sourcefiles der postsim
POST_SRC_VTARGETS := $(foreach n, $(POST_SRC), $(n).vhd)


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
postsim: $(POST_VHO) $(POST_SDO)

$(D_POSTSIM)/modelsim.ini:
	@echo " INIT for post-layout simulation"
	@mkdir -p $(D_POSTSIM)
	@cd $(D_POSTSIM); \
	vlib work > /dev/null ; \
	vmap work work > /dev/null ;

$(D_POSTSIM)/$(WORK)/%/_primary.dat: %.vhd
	@echo " CC    $<"
	@cd $(D_POSTSIM); \
	vcom -work $(WORK) $(MPWD)/$<

post_%: postsim $(D_POSTSIM)/$(WORK)/post_%_tb/_primary.dat post_%_tb.do
	cd $(D_POSTSIM); \
	vsim "work.$@_tb(sim)" -sdftyp /$(POST_SDO_INST)=$(POST_SDO) -f /dev/null -do $(MPWD)/$@_tb.do

$(QUARTUS): $(D_POSTSIM)/modelsim.ini
	@echo -n " Quartus  generate project"
ifeq ($(findstring $(HN), $(TILABHOSTS)),$(HN))
	@echo "(@tilab)"
	@cd ../quartus; ./linux_tilab.sh
else
	@echo "(not @ tilab)"
	@cd ../quartus; ./linux_web.sh
endif

#TODO: more targets plz...
$(POST_VHO) $(POST_SDO): $(QUARTUS) $(POST_VTARGETS) $(POST_SRC_VTARGETS)
	@echo " Quartus  analysis & synthesis"
	@$(QUMACRO) quartus_map $(QUOPT) | tee $(MPWD)/quartusmap.tmp
	@echo " Quartus  fitter"
	@$(QUMACRO) quartus_fit $(QUOPT)
	@echo " Quartus  assembler"
	@$(QUMACRO) quartus_asm $(QUOPT)
	@echo " Quartus  timing analyzer"
	@$(QUMACRO) quartus_tan $(QUOPT) --timing_analysis_only | tee $(MPWD)/quartustan.tmp
	@echo " Quartus  EDA netlist writer"
	@$(QUMACRO) quartus_eda $(QUOPT)
	#not nice atm :/
	@echo " CC    $(POST_VHO)"
	@cd $(D_POSTSIM); \
	vcom -work $(WORK) $(POST_VHO)
	@echo -n "  INFO  logic cells: "
	@grep 'logic cells' quartusmap.tmp | awk ' { print $$3 } '
	@grep 'Fmax ' quartustan.tmp | sed -e 's/  / /g' -e 's/Info/INFO/g' -e 's/:/ /g'
	@rm quartus*.tmp

.PHONY: clean
clean:
	rm -Rf $(D_BEHSIM) $(D_POSTSIM) $(QUARTUS)

