FILELIST= -f ./verilog.f
TOP=tb_top

COVERAGE_OPTION = -cm line+cond+tgl+fsm+branch+assert
#autoflush for flush cache after ctrl + C
FSDB_OPTION = -ucli -i fsdb.do +fsdb+functions +fsdb+autoflush +fsdb+mda=on
DEBUG_OPTION = -debug_access+pp+dmptf

SIM_RUN_FLAGS =   $(COVERAGE_OPTION) $(FSDB_OPTION)

all : clean run_all 

run_all ra:
	-mkdir vcs_log_output
	-mkdir vcs_test_output  
	vlogan  -kdb -timescale=1ns/1ps +define+ASIC+CORE64 -sverilog -full64 -l vcs_log_output/ut.log  -error=noMPD $(FILELIST)
	vcs -kdb -lca -full64 -cm_tgl mda -top ${TOP} $(COVERAGE_OPTION) $(DEBUG_OPTION) -l vcs_log_output/vcs_elab.log +notimingcheck +lint=TFIPC-L +lint=PCWM 
	./simv $(SIM_RUN_FLAGS) +nospecify +notimingchecks -l vcs_log_output/sim_run.log 
	verdi -ssf novas.fsdb &

compile cp:
	-mkdir vcs_log_output
	-mkdir vcs_test_output  
	vlogan  -kdb -timescale=1ns/1ps +define+ASIC+CORE64 -sverilog -full64 -l vcs_log_output/ut.log  -error=noMPD $(FILELIST)
	vcs -kdb -lca -full64 -cm_tgl mda -top  ${TOP} $(COVERAGE_OPTION) $(DEBUG_OPTION) -l vcs_log_output/vcs_elab.log +notimingcheck +lint=TFIPC-L +lint=PCWM 

run_only ro: 
	./simv $(SIM_RUN_FLAGS) +nospecify +notimingchecks -l vcs_log_output/sim_run.log

compile_and_run cr:
	vcs -kdb -lca -full64 -top ${TOP} $(DEBUG_OPTION) $(COVERAGE_OPTION)
	./simv $(SIM_RUN_FLAGS)-l vcs_log_output/sim_run.log

cov: 
	verdi -cov -covdir simv.vdb &

verdi: 
	verdi -ssf novas.fsdb
urg: 
	urg -dir simv.vdb -report both

clean: 
	\rm -rf vcs_log_output *.log simv* csrc *.chain *.lock work.lib++ ucli.key 64 fplib
sim: sim.o
	g++ -std=c++0x -o sim sim.o
sim.o: sim.cpp
	g++ -std=c++0x -c -o sim.o sim.cpp