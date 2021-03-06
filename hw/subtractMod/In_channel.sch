EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 4 4
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text Notes 2250 1050 0    50   ~ 0
SensorA
$Comp
L Device:C C3
U 1 1 5E5E2D2C
P 6250 3050
F 0 "C3" H 6365 3096 50  0000 L CNN
F 1 "C" H 6365 3005 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric" H 6288 2900 50  0001 C CNN
F 3 "~" H 6250 3050 50  0001 C CNN
	1    6250 3050
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR021
U 1 1 5E5E7232
P 6250 3200
F 0 "#PWR021" H 6250 2950 50  0001 C CNN
F 1 "GND" H 6255 3027 50  0000 C CNN
F 2 "" H 6250 3200 50  0001 C CNN
F 3 "" H 6250 3200 50  0001 C CNN
	1    6250 3200
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR019
U 1 1 5E5EFD15
P 3200 1750
F 0 "#PWR019" H 3200 1500 50  0001 C CNN
F 1 "GND" H 3205 1577 50  0000 C CNN
F 2 "" H 3200 1750 50  0001 C CNN
F 3 "" H 3200 1750 50  0001 C CNN
	1    3200 1750
	1    0    0    -1  
$EndComp
$Comp
L Amplifier_Difference:AD8276 U3
U 1 1 5E5F75CD
P 3050 1450
F 0 "U3" H 3250 1250 50  0000 L CNN
F 1 "AD8276" H 3150 1350 50  0000 L CNN
F 2 "Package_SO:SOIC-8_3.9x4.9mm_P1.27mm" H 3050 1450 50  0001 C CNN
F 3 "https://www.analog.com/media/en/technical-documentation/data-sheets/AD8276_8277.pdf" H 3050 1450 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Analog-Devices/AD8276ARZ?qs=sGAEpiMZZMv9Q1JI0Mo%2FtSQmcggxWXiF" H 3050 1450 50  0001 C CNN "BOM"
	1    3050 1450
	1    0    0    -1  
$EndComp
Wire Wire Line
	2500 1550 2750 1550
$Comp
L power:+5V #PWR015
U 1 1 5E5B2F2F
P 2950 1000
F 0 "#PWR015" H 2950 850 50  0001 C CNN
F 1 "+5V" H 2965 1173 50  0000 C CNN
F 2 "" H 2950 1000 50  0001 C CNN
F 3 "" H 2950 1000 50  0001 C CNN
	1    2950 1000
	1    0    0    -1  
$EndComp
$Comp
L power:-5V #PWR016
U 1 1 5E5B3872
P 2950 1900
F 0 "#PWR016" H 2950 2000 50  0001 C CNN
F 1 "-5V" H 2965 2073 50  0000 C CNN
F 2 "" H 2950 1900 50  0001 C CNN
F 3 "" H 2950 1900 50  0001 C CNN
	1    2950 1900
	-1   0    0    1   
$EndComp
Wire Wire Line
	2950 1150 2950 1000
Wire Wire Line
	2950 1750 2950 1900
Wire Wire Line
	3050 1750 3200 1750
Wire Wire Line
	3050 1150 3050 1050
Wire Wire Line
	3050 1050 3450 1050
Wire Wire Line
	3450 1450 3350 1450
Text Label 3850 2750 0    50   ~ 0
sensA_out
Text Label 3900 1450 2    50   ~ 0
sensA_out
Connection ~ 3450 1450
Text Notes 2300 5450 0    50   ~ 0
SensorB
$Comp
L power:GND #PWR020
U 1 1 5E5E8C9C
P 3250 6150
F 0 "#PWR020" H 3250 5900 50  0001 C CNN
F 1 "GND" H 3255 5977 50  0000 C CNN
F 2 "" H 3250 6150 50  0001 C CNN
F 3 "" H 3250 6150 50  0001 C CNN
	1    3250 6150
	1    0    0    -1  
$EndComp
$Comp
L Amplifier_Difference:AD8276 U4
U 1 1 5E5E8CA2
P 3100 5850
F 0 "U4" H 3300 5650 50  0000 L CNN
F 1 "AD8276" H 3200 5750 50  0000 L CNN
F 2 "Package_SO:SOIC-8_3.9x4.9mm_P1.27mm" H 3100 5850 50  0001 C CNN
F 3 "https://www.analog.com/media/en/technical-documentation/data-sheets/AD8276_8277.pdf" H 3100 5850 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Analog-Devices/AD8276ARZ?qs=sGAEpiMZZMv9Q1JI0Mo%2FtSQmcggxWXiF" H 3100 5850 50  0001 C CNN "BOM"
	1    3100 5850
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR017
U 1 1 5E5E8CAA
P 3000 5400
F 0 "#PWR017" H 3000 5250 50  0001 C CNN
F 1 "+5V" H 3015 5573 50  0000 C CNN
F 2 "" H 3000 5400 50  0001 C CNN
F 3 "" H 3000 5400 50  0001 C CNN
	1    3000 5400
	1    0    0    -1  
$EndComp
$Comp
L power:-5V #PWR018
U 1 1 5E5E8CB0
P 3000 6300
F 0 "#PWR018" H 3000 6400 50  0001 C CNN
F 1 "-5V" H 3015 6473 50  0000 C CNN
F 2 "" H 3000 6300 50  0001 C CNN
F 3 "" H 3000 6300 50  0001 C CNN
	1    3000 6300
	-1   0    0    1   
$EndComp
Wire Wire Line
	3000 5550 3000 5400
Wire Wire Line
	3000 6150 3000 6300
Wire Wire Line
	3100 6150 3250 6150
Wire Wire Line
	3100 5550 3100 5450
Wire Wire Line
	3100 5450 3500 5450
Wire Wire Line
	3500 5850 3400 5850
Text Label 3950 5850 2    50   ~ 0
sensB_out
Wire Wire Line
	3500 5850 3950 5850
Connection ~ 3500 5850
$Comp
L Device:C C4
U 1 1 5E5F6005
P 6300 5150
F 0 "C4" H 6415 5196 50  0000 L CNN
F 1 "C" H 6415 5105 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric" H 6338 5000 50  0001 C CNN
F 3 "~" H 6300 5150 50  0001 C CNN
	1    6300 5150
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR022
U 1 1 5E5F600F
P 6300 5300
F 0 "#PWR022" H 6300 5050 50  0001 C CNN
F 1 "GND" H 6305 5127 50  0000 C CNN
F 2 "" H 6300 5300 50  0001 C CNN
F 3 "" H 6300 5300 50  0001 C CNN
	1    6300 5300
	1    0    0    -1  
$EndComp
Wire Wire Line
	6300 4850 6300 5000
Wire Wire Line
	4750 4850 4700 4850
Text Label 3950 4850 0    50   ~ 0
sensB_out
$Comp
L power:-5V #PWR026
U 1 1 5E625B4E
P 8500 1850
F 0 "#PWR026" H 8500 1950 50  0001 C CNN
F 1 "-5V" H 8515 2023 50  0000 C CNN
F 2 "" H 8500 1850 50  0001 C CNN
F 3 "" H 8500 1850 50  0001 C CNN
	1    8500 1850
	-1   0    0    1   
$EndComp
$Comp
L power:+5V #PWR025
U 1 1 5E62848E
P 8500 1050
F 0 "#PWR025" H 8500 900 50  0001 C CNN
F 1 "+5V" H 8515 1223 50  0000 C CNN
F 2 "" H 8500 1050 50  0001 C CNN
F 3 "" H 8500 1050 50  0001 C CNN
	1    8500 1050
	1    0    0    -1  
$EndComp
Wire Wire Line
	8500 1750 8500 1850
Wire Wire Line
	8500 1150 8500 1050
Text Notes 5850 3650 0    50   ~ 0
Fcutoff \n(0; 100) [Hz]
Text Notes 5900 5750 0    50   ~ 0
Fcutoff \n(0; 100) [Hz]
Text HLabel 7750 2750 2    50   Output ~ 0
chan1_out
Text HLabel 7800 4850 2    50   Output ~ 0
chan2_out
Wire Wire Line
	3450 1450 3900 1450
Wire Wire Line
	3500 5450 3500 5600
Wire Wire Line
	3450 1050 3450 1250
NoConn ~ 6100 4850
$Comp
L Device:R_POT_TRIM RV?
U 1 1 5E5F5FFE
P 5950 4850
AR Path="/5E5F5FFE" Ref="RV?"  Part="1" 
AR Path="/5E58DC75/5E5F5FFE" Ref="RV5"  Part="1" 
F 0 "RV5" H 5880 4896 50  0000 R CNN
F 1 "R_POT_TRIM" H 5880 4805 50  0000 R CNN
F 2 "Potentiometer_SMD:Potentiometer_Bourns_3314J_Vertical" H 5950 4850 50  0001 C CNN
F 3 "~" H 5950 4850 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Bourns/3314J-2-105E?qs=sGAEpiMZZMvygUB3GLcD7g2uut0mCOdNBBUJ5VY5B4c%3D" H 5950 4850 50  0001 C CNN "BOM"
	1    5950 4850
	0    -1   -1   0   
$EndComp
Connection ~ 6300 4850
Wire Wire Line
	6300 4600 6300 4850
Wire Wire Line
	5950 4700 5950 4600
Wire Wire Line
	5950 4600 6300 4600
NoConn ~ 6050 2750
$Comp
L Device:R_POT_TRIM RV?
U 1 1 5E5BF320
P 5900 2750
AR Path="/5E5BF320" Ref="RV?"  Part="1" 
AR Path="/5E58DC75/5E5BF320" Ref="RV4"  Part="1" 
F 0 "RV4" H 5830 2796 50  0000 R CNN
F 1 "R_POT_TRIM" H 5830 2705 50  0000 R CNN
F 2 "Potentiometer_SMD:Potentiometer_Bourns_3314J_Vertical" H 5900 2750 50  0001 C CNN
F 3 "https://eu.mouser.com/datasheet/2/54/3314-776736.pdf" H 5900 2750 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Bourns/3314J-2-105E?qs=sGAEpiMZZMvygUB3GLcD7g2uut0mCOdNBBUJ5VY5B4c%3D" H 5900 2750 50  0001 C CNN "BOM"
	1    5900 2750
	0    1    -1   0   
$EndComp
Wire Wire Line
	5900 2500 6250 2500
Wire Wire Line
	5900 2600 5900 2500
$Comp
L Connector:TestPoint TP7
U 1 1 5E60832E
P 3450 1250
F 0 "TP7" V 3404 1438 50  0000 L CNN
F 1 "TestPoint" V 3495 1438 50  0000 L CNN
F 2 "TestPoint:TestPoint_Pad_3.0x3.0mm" H 3650 1250 50  0001 C CNN
F 3 "https://eu.mouser.com/datasheet/2/215/Keystone_Electronics_04082019_5190TR-5199TR-1551357.pdf" H 3650 1250 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Keystone-Electronics/5194TR?qs=sGAEpiMZZMtzcnMBgC2bs84ygu06jYzulkX4bJ%2F%252Bd0s%3D" V 3450 1250 50  0001 C CNN "BOM"
	1    3450 1250
	0    1    1    0   
$EndComp
Connection ~ 3450 1250
Wire Wire Line
	3450 1250 3450 1450
$Comp
L Connector:TestPoint TP8
U 1 1 5E60982E
P 3500 5600
F 0 "TP8" V 3454 5788 50  0000 L CNN
F 1 "TestPoint" V 3545 5788 50  0000 L CNN
F 2 "TestPoint:TestPoint_Pad_3.0x3.0mm" H 3700 5600 50  0001 C CNN
F 3 "https://eu.mouser.com/datasheet/2/215/Keystone_Electronics_04082019_5190TR-5199TR-1551357.pdf" H 3700 5600 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Keystone-Electronics/5194TR?qs=sGAEpiMZZMtzcnMBgC2bs84ygu06jYzulkX4bJ%2F%252Bd0s%3D" V 3500 5600 50  0001 C CNN "BOM"
	1    3500 5600
	0    1    1    0   
$EndComp
Connection ~ 3500 5600
Wire Wire Line
	3500 5600 3500 5850
$Comp
L Connector:TestPoint TP12
U 1 1 5E61D78A
P 6500 4600
F 0 "TP12" H 6558 4718 50  0000 L CNN
F 1 "TestPoint" H 6558 4627 50  0000 L CNN
F 2 "TestPoint:TestPoint_Pad_3.0x3.0mm" H 6700 4600 50  0001 C CNN
F 3 "https://eu.mouser.com/datasheet/2/215/Keystone_Electronics_04082019_5190TR-5199TR-1551357.pdf" H 6700 4600 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Keystone-Electronics/5194TR?qs=sGAEpiMZZMtzcnMBgC2bs84ygu06jYzulkX4bJ%2F%252Bd0s%3D" H 6500 4600 50  0001 C CNN "BOM"
	1    6500 4600
	1    0    0    -1  
$EndComp
$Comp
L Connector:TestPoint TP10
U 1 1 5E61E3D0
P 5450 4600
F 0 "TP10" H 5508 4718 50  0000 L CNN
F 1 "TestPoint" H 5508 4627 50  0000 L CNN
F 2 "TestPoint:TestPoint_Pad_3.0x3.0mm" H 5650 4600 50  0001 C CNN
F 3 "https://eu.mouser.com/datasheet/2/215/Keystone_Electronics_04082019_5190TR-5199TR-1551357.pdf" H 5650 4600 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Keystone-Electronics/5194TR?qs=sGAEpiMZZMtzcnMBgC2bs84ygu06jYzulkX4bJ%2F%252Bd0s%3D" H 5450 4600 50  0001 C CNN "BOM"
	1    5450 4600
	1    0    0    -1  
$EndComp
Wire Wire Line
	5350 4850 5450 4850
Wire Wire Line
	5450 4850 5450 4600
Wire Wire Line
	5450 4850 5800 4850
Connection ~ 5450 4850
Wire Wire Line
	6300 4850 6850 4850
Wire Wire Line
	6500 4600 6300 4600
Connection ~ 6300 4600
Wire Wire Line
	6250 2500 6250 2750
$Comp
L Connector:TestPoint TP11
U 1 1 5E64BAE5
P 6400 2500
F 0 "TP11" H 6458 2618 50  0000 L CNN
F 1 "TestPoint" H 6458 2527 50  0000 L CNN
F 2 "TestPoint:TestPoint_Pad_3.0x3.0mm" H 6600 2500 50  0001 C CNN
F 3 "https://eu.mouser.com/datasheet/2/215/Keystone_Electronics_04082019_5190TR-5199TR-1551357.pdf" H 6600 2500 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Keystone-Electronics/5194TR?qs=sGAEpiMZZMtzcnMBgC2bs84ygu06jYzulkX4bJ%2F%252Bd0s%3D" H 6400 2500 50  0001 C CNN "BOM"
	1    6400 2500
	1    0    0    -1  
$EndComp
$Comp
L Connector:TestPoint TP9
U 1 1 5E64D5DF
P 5350 2500
F 0 "TP9" H 5408 2618 50  0000 L CNN
F 1 "TestPoint" H 5408 2527 50  0000 L CNN
F 2 "TestPoint:TestPoint_Pad_3.0x3.0mm" H 5550 2500 50  0001 C CNN
F 3 "https://eu.mouser.com/datasheet/2/215/Keystone_Electronics_04082019_5190TR-5199TR-1551357.pdf" H 5550 2500 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Keystone-Electronics/5194TR?qs=sGAEpiMZZMtzcnMBgC2bs84ygu06jYzulkX4bJ%2F%252Bd0s%3D" H 5350 2500 50  0001 C CNN "BOM"
	1    5350 2500
	1    0    0    -1  
$EndComp
Wire Wire Line
	6250 2750 6750 2750
Connection ~ 6250 2750
Wire Wire Line
	6250 2750 6250 2900
Wire Wire Line
	6400 2500 6250 2500
Connection ~ 6250 2500
Wire Wire Line
	5300 2750 5350 2750
Wire Wire Line
	5350 2500 5350 2750
Connection ~ 5350 2750
Wire Wire Line
	5350 2750 5750 2750
$Comp
L power:+5V #PWR013
U 1 1 5E66D10A
P 2500 6350
F 0 "#PWR013" H 2500 6200 50  0001 C CNN
F 1 "+5V" H 2515 6523 50  0000 C CNN
F 2 "" H 2500 6350 50  0001 C CNN
F 3 "" H 2500 6350 50  0001 C CNN
	1    2500 6350
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR011
U 1 1 5E66E702
P 2700 6050
F 0 "#PWR011" H 2700 5800 50  0001 C CNN
F 1 "GND" H 2705 5877 50  0000 C CNN
F 2 "" H 2700 6050 50  0001 C CNN
F 3 "" H 2700 6050 50  0001 C CNN
	1    2700 6050
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR014
U 1 1 5E67BF37
P 2500 1950
F 0 "#PWR014" H 2500 1800 50  0001 C CNN
F 1 "+5V" H 2515 2123 50  0000 C CNN
F 2 "" H 2500 1950 50  0001 C CNN
F 3 "" H 2500 1950 50  0001 C CNN
	1    2500 1950
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR012
U 1 1 5E67BF3D
P 2700 1650
F 0 "#PWR012" H 2700 1400 50  0001 C CNN
F 1 "GND" H 2705 1477 50  0000 C CNN
F 2 "" H 2700 1650 50  0001 C CNN
F 3 "" H 2700 1650 50  0001 C CNN
	1    2700 1650
	1    0    0    -1  
$EndComp
$Comp
L Connector:Screw_Terminal_01x04 J2
U 1 1 5E6A0306
P 2200 1600
F 0 "J2" H 2118 1175 50  0000 C CNN
F 1 "Screw_Terminal_01x04" H 2118 1266 50  0000 C CNN
F 2 "TerminalBlock_Phoenix:TerminalBlock_Phoenix_MKDS-1,5-4-5.08_1x04_P5.08mm_Horizontal" H 2200 1600 50  0001 C CNN
F 3 "~" H 2200 1600 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Phoenix-Contact/1725672?qs=sGAEpiMZZMvZTcaMAxB2AF3qQv3QF5c1cqzdDV%2FmZgo%3D" H 2200 1600 50  0001 C CNN "BOM"
	1    2200 1600
	-1   0    0    1   
$EndComp
$Comp
L Connector:Screw_Terminal_01x04 J1
U 1 1 5E6BB6E3
P 2200 6000
F 0 "J1" H 2118 5575 50  0000 C CNN
F 1 "Screw_Terminal_01x04" H 2118 5666 50  0000 C CNN
F 2 "TerminalBlock_Phoenix:TerminalBlock_Phoenix_MKDS-1,5-4-5.08_1x04_P5.08mm_Horizontal" H 2200 6000 50  0001 C CNN
F 3 "~" H 2200 6000 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Phoenix-Contact/1725672?qs=sGAEpiMZZMvZTcaMAxB2AF3qQv3QF5c1cqzdDV%2FmZgo%3D" H 2200 6000 50  0001 C CNN "BOM"
	1    2200 6000
	-1   0    0    1   
$EndComp
$Comp
L Device:LED D1
U 1 1 5E6EBD07
P 8050 1600
F 0 "D1" V 8089 1483 50  0000 R CNN
F 1 "LED" V 7998 1483 50  0000 R CNN
F 2 "LED_SMD:LED_0603_1608Metric" H 8050 1600 50  0001 C CNN
F 3 "https://eu.mouser.com/datasheet/2/109/Dialight_CBI_data_599-0603_Apr2018-1370611.pdf" H 8050 1600 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Dialight/599-0010-007F?qs=sGAEpiMZZMseGfSY3csMkdgyOOAg6kv2lGy%2FbkJhIAObtuLERQeGuQ%3D%3D" V 8050 1600 50  0001 C CNN "BOM"
	1    8050 1600
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R5
U 1 1 5E6ED880
P 8050 1200
F 0 "R5" H 8120 1246 50  0000 L CNN
F 1 "R" H 8120 1155 50  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 7980 1200 50  0001 C CNN
F 3 "~" H 8050 1200 50  0001 C CNN
	1    8050 1200
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR024
U 1 1 5E6EEF02
P 8050 1900
F 0 "#PWR024" H 8050 1650 50  0001 C CNN
F 1 "GND" H 8055 1727 50  0000 C CNN
F 2 "" H 8050 1900 50  0001 C CNN
F 3 "" H 8050 1900 50  0001 C CNN
	1    8050 1900
	1    0    0    -1  
$EndComp
Wire Wire Line
	8050 1900 8050 1750
$Comp
L power:+5V #PWR023
U 1 1 5E6F273E
P 8050 950
F 0 "#PWR023" H 8050 800 50  0001 C CNN
F 1 "+5V" H 8065 1123 50  0000 C CNN
F 2 "" H 8050 950 50  0001 C CNN
F 3 "" H 8050 950 50  0001 C CNN
	1    8050 950 
	1    0    0    -1  
$EndComp
Wire Wire Line
	8050 1050 8050 950 
Wire Wire Line
	8050 1450 8050 1350
Wire Wire Line
	7450 4850 7650 4850
Wire Wire Line
	7650 4850 7650 4150
Connection ~ 7650 4850
Wire Wire Line
	7650 4850 7800 4850
$Comp
L Device:R R9
U 1 1 5E60171A
P 5950 4150
F 0 "R9" V 5743 4150 50  0000 C CNN
F 1 "0R" V 5834 4150 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 5880 4150 50  0001 C CNN
F 3 "~" H 5950 4150 50  0001 C CNN
	1    5950 4150
	0    1    1    0   
$EndComp
Wire Wire Line
	6100 4150 7650 4150
$Comp
L Device:R R7
U 1 1 5E606FAE
P 4550 4850
F 0 "R7" V 4343 4850 50  0000 C CNN
F 1 "0R" V 4434 4850 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 4480 4850 50  0001 C CNN
F 3 "~" H 4550 4850 50  0001 C CNN
	1    4550 4850
	0    1    1    0   
$EndComp
Wire Wire Line
	4400 4850 4350 4850
Wire Wire Line
	4350 4850 4350 4150
Wire Wire Line
	4350 4150 5800 4150
Connection ~ 4350 4850
Wire Wire Line
	4350 4850 3950 4850
$Comp
L Device:R R8
U 1 1 5E6271F0
P 5950 2050
F 0 "R8" V 5743 2050 50  0000 C CNN
F 1 "0R" V 5834 2050 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 5880 2050 50  0001 C CNN
F 3 "~" H 5950 2050 50  0001 C CNN
	1    5950 2050
	0    1    1    0   
$EndComp
$Comp
L Device:R R6
U 1 1 5E62A18C
P 4500 2750
F 0 "R6" V 4293 2750 50  0000 C CNN
F 1 "0R" V 4384 2750 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 4430 2750 50  0001 C CNN
F 3 "~" H 4500 2750 50  0001 C CNN
	1    4500 2750
	0    1    1    0   
$EndComp
Wire Wire Line
	3850 2750 4300 2750
Wire Wire Line
	4300 2750 4300 2050
Wire Wire Line
	4300 2050 5800 2050
Connection ~ 4300 2750
Wire Wire Line
	4300 2750 4350 2750
Wire Wire Line
	7350 2750 7500 2750
Wire Wire Line
	6100 2050 7500 2050
Wire Wire Line
	7500 2050 7500 2750
Connection ~ 7500 2750
Wire Wire Line
	7500 2750 7750 2750
Wire Wire Line
	4650 2750 4700 2750
Wire Wire Line
	2400 1600 2700 1600
Wire Wire Line
	2700 1600 2700 1650
Wire Wire Line
	2400 1700 2400 1950
Wire Wire Line
	2400 1950 2500 1950
Wire Wire Line
	2500 1400 2400 1400
Wire Wire Line
	2500 1400 2500 1550
Wire Wire Line
	2400 1500 2550 1500
Wire Wire Line
	2550 1500 2550 1350
Wire Wire Line
	2550 1350 2750 1350
Wire Wire Line
	2400 6100 2400 6350
Wire Wire Line
	2400 6350 2500 6350
Wire Wire Line
	2700 6050 2700 6000
Wire Wire Line
	2700 6000 2400 6000
Wire Wire Line
	2800 5950 2550 5950
Wire Wire Line
	2550 5950 2550 5800
Wire Wire Line
	2550 5800 2400 5800
Wire Wire Line
	2800 5750 2600 5750
Wire Wire Line
	2600 5750 2600 5900
Wire Wire Line
	2600 5900 2400 5900
$Comp
L dodo-analog:AD8244 IC2
U 1 1 5E7AC8AD
P 4950 2750
F 0 "IC2" H 5000 3115 50  0000 C CNN
F 1 "AD8244" H 5000 3024 50  0000 C CNN
F 2 "Package_SO:MSOP-10_3x3mm_P0.5mm" H 4950 2750 50  0001 C CNN
F 3 "https://www.analog.com/media/en/technical-documentation/data-sheets/AD8244.pdf" H 4950 2750 50  0001 C CNN
	1    4950 2750
	1    0    0    -1  
$EndComp
$Comp
L dodo-analog:AD8244 IC2
U 2 1 5E7B346D
P 5000 4850
F 0 "IC2" H 5050 5215 50  0000 C CNN
F 1 "AD8244" H 5050 5124 50  0000 C CNN
F 2 "Package_SO:MSOP-10_3x3mm_P0.5mm" H 5000 4850 50  0001 C CNN
F 3 "https://www.analog.com/media/en/technical-documentation/data-sheets/AD8244.pdf" H 5000 4850 50  0001 C CNN
	2    5000 4850
	1    0    0    -1  
$EndComp
$Comp
L dodo-analog:AD8244 IC2
U 3 1 5E7B8431
P 7100 4850
F 0 "IC2" H 7150 5215 50  0000 C CNN
F 1 "AD8244" H 7150 5124 50  0000 C CNN
F 2 "Package_SO:MSOP-10_3x3mm_P0.5mm" H 7100 4850 50  0001 C CNN
F 3 "https://www.analog.com/media/en/technical-documentation/data-sheets/AD8244.pdf" H 7100 4850 50  0001 C CNN
	3    7100 4850
	1    0    0    -1  
$EndComp
$Comp
L dodo-analog:AD8244 IC2
U 4 1 5E7BD73A
P 7000 2750
F 0 "IC2" H 7050 3115 50  0000 C CNN
F 1 "AD8244" H 7050 3024 50  0000 C CNN
F 2 "Package_SO:MSOP-10_3x3mm_P0.5mm" H 7000 2750 50  0001 C CNN
F 3 "https://www.analog.com/media/en/technical-documentation/data-sheets/AD8244.pdf" H 7000 2750 50  0001 C CNN
	4    7000 2750
	1    0    0    -1  
$EndComp
$Comp
L dodo-analog:AD8244 IC2
U 5 1 5E7BDEF2
P 8500 1450
F 0 "IC2" V 8454 1538 50  0000 L CNN
F 1 "AD8244" V 8545 1538 50  0000 L CNN
F 2 "Package_SO:MSOP-10_3x3mm_P0.5mm" H 8500 1450 50  0001 C CNN
F 3 "https://www.analog.com/media/en/technical-documentation/data-sheets/AD8244.pdf" H 8500 1450 50  0001 C CNN
	5    8500 1450
	0    1    1    0   
$EndComp
$EndSCHEMATC
