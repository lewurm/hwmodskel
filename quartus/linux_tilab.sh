#!/bin/sh
unset LS_COLORS
mkdir -p calc
cd calc
quartus_sh -t ../project_tilab.tcl
cd ..
