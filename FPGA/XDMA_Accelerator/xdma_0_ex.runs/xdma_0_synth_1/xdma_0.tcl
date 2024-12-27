# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param project.vivado.isBlockSynthRun true
set_msg_config -msgmgr_mode ooc_run
create_project -in_memory -part xc7vx690tffg1927-2

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.cache/wt [current_project]
set_property parent.project_path /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.xpr [current_project]
set_property XPM_LIBRARIES {XPM_CDC XPM_FIFO XPM_MEMORY} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.cache/ip [current_project]
set_property ip_cache_permissions disable [current_project]
read_ip -quiet /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.srcs/sources_1/ip/xdma_0/xdma_0.xci
set_property used_in_implementation false [get_files -all /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.srcs/sources_1/ip/xdma_0/ip_0/source/xdma_0_pcie3_ip-PCIE_X0Y0.xdc]
set_property used_in_implementation false [get_files -all /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.srcs/sources_1/ip/xdma_0/ip_0/synth/xdma_0_pcie3_ip_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.srcs/sources_1/ip/xdma_0/ip_1/xdma_v4_1_2_blk_mem_64_reg_be_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.srcs/sources_1/ip/xdma_0/ip_2/xdma_v4_1_2_blk_mem_64_noreg_be_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.srcs/sources_1/ip/xdma_0/xdma_0_board.xdc]
set_property used_in_implementation false [get_files -all /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.srcs/sources_1/ip/xdma_0/source/xdma_0_pcie3_7vx_ip.xdc]
set_property used_in_implementation false [get_files -all /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.srcs/sources_1/ip/xdma_0/synth/xdma_0_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]
set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top xdma_0 -part xc7vx690tffg1927-2 -mode out_of_context

rename_ref -prefix_all xdma_0_

# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef xdma_0.dcp
create_report "xdma_0_synth_1_synth_report_utilization_0" "report_utilization -file xdma_0_utilization_synth.rpt -pb xdma_0_utilization_synth.pb"

if { [catch {
  file copy -force /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.runs/xdma_0_synth_1/xdma_0.dcp /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.srcs/sources_1/ip/xdma_0/xdma_0.dcp
} _RESULT ] } { 
  send_msg_id runtcl-3 error "ERROR: Unable to successfully create or copy the sub-design checkpoint file."
  error "ERROR: Unable to successfully create or copy the sub-design checkpoint file."
}

if { [catch {
  write_verilog -force -mode synth_stub /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.srcs/sources_1/ip/xdma_0/xdma_0_stub.v
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a Verilog synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}

if { [catch {
  write_vhdl -force -mode synth_stub /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.srcs/sources_1/ip/xdma_0/xdma_0_stub.vhdl
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a VHDL synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}

if { [catch {
  write_verilog -force -mode funcsim /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.srcs/sources_1/ip/xdma_0/xdma_0_sim_netlist.v
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the Verilog functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}

if { [catch {
  write_vhdl -force -mode funcsim /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.srcs/sources_1/ip/xdma_0/xdma_0_sim_netlist.vhdl
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the VHDL functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}

if {[file isdir /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.ip_user_files/ip/xdma_0]} {
  catch { 
    file copy -force /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.srcs/sources_1/ip/xdma_0/xdma_0_stub.v /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.ip_user_files/ip/xdma_0
  }
}

if {[file isdir /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.ip_user_files/ip/xdma_0]} {
  catch { 
    file copy -force /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.srcs/sources_1/ip/xdma_0/xdma_0_stub.vhdl /home/guocheng/work/sdr/test/xdma_0_ex/xdma_0_ex.ip_user_files/ip/xdma_0
  }
}
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]