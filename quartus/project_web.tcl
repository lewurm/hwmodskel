package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "calc"]} {
		puts "Project calc is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists calc]} {
		project_open -revision calc calc
	} else {
		project_new -revision calc calc
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY Stratix
	set_global_assignment -name DEVICE EP1S10F672C6
	set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim (VHDL)"
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
	set_global_assignment -name USE_GENERATED_PHYSICAL_CONSTRAINTS OFF -section_id eda_blast_fpga
	set_global_assignment -name MISC_FILE "calc.dpf"
	set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
	set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED WITH WEAK PULL-UP"
	set_global_assignment -name RESERVE_ASDO_AFTER_CONFIGURATION "AS INPUT TRI-STATED"

	set_global_assignment -name TOP_LEVEL_ENTITY foo
	set_global_assignment -name VHDL_FILE ../../src/gen_pkg.vhd
	set_global_assignment -name VHDL_FILE ../../src/foo.vhd

	set_location_assignment PIN_N3 -to sys_clk
	set_location_assignment PIN_AF17 -to sys_res_n

	set_global_assignment -name FMAX_REQUIREMENT "33.33 MHz" -section_id sys_clk
	set_instance_assignment -name CLOCK_SETTINGS sys_clk -to sys_clk

	set_global_assignment -name LL_ROOT_REGION ON -section_id "Root Region"
	set_global_assignment -name LL_MEMBER_STATE LOCKED -section_id "Root Region"
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
