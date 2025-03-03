read_file -type verilog $env(PKG_SRCS) $env(HDL_SRCS)
if {$env(SRAM_LIB) != ""} {
    read_file -type gateslibdb $env(SRAM_LIB)
}
read_file -type awl lint.awl

set_option top top
set_option enable_gateslib_autocompile yes
set_option language_mode verilog
set_option enableSV09 yes
set_option enable_save_restore no
set_option mthresh 2000000000
set_option sgsyn_loop_limit 2000000000

current_goal Design_Read -top top

current_goal lint/lint_turbo_rtl -top top

set_parameter checkfullstruct true

run_goal

# help -rules STARC05-2.11.3.1
