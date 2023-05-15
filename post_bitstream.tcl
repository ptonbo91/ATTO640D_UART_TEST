set origin_dir [file dirname [info script]]
cd $origin_dir

#write project tcl file to directory

write_cfgmem  -format mcs -size 64 -interface SPIx4 -loadbit {up 0x00000000 "TUVE_SYSTEM.runs/impl_1/TUVE_SYSTEM.bit" } -file "TUVE_SYSTEM.mcs" -force

write_project_tcl -all_properties -no_copy_sources -use_bd_files -dump_project_info -force {TUVE_SYSTEM.tcl}

set string1_search "set origin_dir \".\"\n"
set string2_search "create\_project \\$\{\_xil\_proj\_name\_\} \.\/\\$\{\_xil\_proj\_name\_\} \-part xa7a100tcsg324\-2I\n"

# puts $string1_search
# puts $string2_search

set string1_replace "set origin_dir \[file dirname \[info script]]\ncd \$origin_dir\n"
set string2_replace "file rename \"\${_xil_proj_name_}.srcs\" \"srcs\"\n\# Create project\ncreate_project \${_xil_proj_name_} ./ -part xa7a100tcsg324-2I -force\nfile rename \"srcs\" \"\${_xil_proj_name_}.srcs\"\n"

# puts $string1_replace
# puts $string2_replace

set _xil_proj_name_ "TUVE_SYSTEM"
variable script_file
set script_file "TUVE_SYSTEM.tcl"

set fp [open ${script_file} r]
set file_data [read $fp]
close $fp

set file_data_new [regsub $string1_search $file_data $string1_replace]

set file_data_new2 [regsub $string2_search $file_data_new $string2_replace] 

set fp [open ${script_file} w]
puts $fp $file_data_new2
close $fp


