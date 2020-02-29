EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 4
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Sheet
S 4850 4800 2050 950 
U 5E46B34F
F0 "power_block" 50
F1 "power_block.sch" 50
$EndSheet
$Sheet
S 6300 1900 1450 2300
U 5E556D6F
F0 "offset_control" 50
F1 "offset_ctrl.sch" 50
F2 "chan1_in" I L 6300 2850 50 
F3 "chan2_in" I L 6300 3300 50 
$EndSheet
$Sheet
S 4200 1900 1500 2300
U 5E58DC75
F0 "Input_channel" 50
F1 "In_channel.sch" 50
F2 "chan1_out" O R 5700 2850 50 
F3 "chan2_out" O R 5700 3300 50 
$EndSheet
Wire Wire Line
	5700 2850 6300 2850
Wire Wire Line
	5700 3300 6300 3300
$EndSCHEMATC
