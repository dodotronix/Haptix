EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 3 4
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Device:R_POT_TRIM RV2
U 1 1 5E56AC13
P 5100 3500
F 0 "RV2" V 5000 3550 50  0000 R CNN
F 1 "R_POT_TRIM" V 4900 3700 50  0000 R CNN
F 2 "Potentiometer_SMD:Potentiometer_Bourns_3314J_Vertical" H 5100 3500 50  0001 C CNN
F 3 "~" H 5100 3500 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Bourns/3314J-2-105E?qs=sGAEpiMZZMvygUB3GLcD7g2uut0mCOdNBBUJ5VY5B4c%3D" V 5100 3500 50  0001 C CNN "BOM"
	1    5100 3500
	0    1    1    0   
$EndComp
Text HLabel 4800 3500 0    50   Input ~ 0
chan1_in
Text HLabel 4800 4250 0    50   Input ~ 0
chan2_in
$Comp
L power:+5V #PWR09
U 1 1 5E6C55A9
P 8900 2450
F 0 "#PWR09" H 8900 2300 50  0001 C CNN
F 1 "+5V" H 8915 2623 50  0000 C CNN
F 2 "" H 8900 2450 50  0001 C CNN
F 3 "" H 8900 2450 50  0001 C CNN
	1    8900 2450
	1    0    0    -1  
$EndComp
$Comp
L power:-5V #PWR010
U 1 1 5E6C5C13
P 8900 3350
F 0 "#PWR010" H 8900 3450 50  0001 C CNN
F 1 "-5V" H 8915 3523 50  0000 C CNN
F 2 "" H 8900 3350 50  0001 C CNN
F 3 "" H 8900 3350 50  0001 C CNN
	1    8900 3350
	-1   0    0    1   
$EndComp
Wire Wire Line
	8900 3200 8900 3350
Wire Wire Line
	8900 2600 8900 2450
$Comp
L Device:R_POT_TRIM RV3
U 1 1 5E6CC548
P 6050 4350
F 0 "RV3" V 5950 4400 50  0000 R CNN
F 1 "R_POT_TRIM" V 5850 4550 50  0000 R CNN
F 2 "Potentiometer_SMD:Potentiometer_Bourns_3314J_Vertical" H 6050 4350 50  0001 C CNN
F 3 "~" H 6050 4350 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Bourns/3314J-2-105E?qs=sGAEpiMZZMvygUB3GLcD7g2uut0mCOdNBBUJ5VY5B4c%3D" V 6050 4350 50  0001 C CNN "BOM"
	1    6050 4350
	0    1    -1   0   
$EndComp
$Comp
L power:+5V #PWR05
U 1 1 5E6D1680
P 5800 4200
F 0 "#PWR05" H 5800 4050 50  0001 C CNN
F 1 "+5V" H 5815 4373 50  0000 C CNN
F 2 "" H 5800 4200 50  0001 C CNN
F 3 "" H 5800 4200 50  0001 C CNN
	1    5800 4200
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR04
U 1 1 5E6D5F38
P 5350 4450
F 0 "#PWR04" H 5350 4200 50  0001 C CNN
F 1 "GND" H 5355 4277 50  0000 C CNN
F 2 "" H 5350 4450 50  0001 C CNN
F 3 "" H 5350 4450 50  0001 C CNN
	1    5350 4450
	1    0    0    -1  
$EndComp
Wire Wire Line
	6850 4000 7000 4000
$Comp
L dodo-analog:LMP2011 IC1
U 1 1 5E58CEBD
P 5500 3900
F 0 "IC1" H 5550 4265 50  0000 C CNN
F 1 "LMP2011" H 5550 4174 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-23-5" H 5500 3550 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/lmp2011.pdf" H 5500 3900 50  0001 C CNN
	1    5500 3900
	1    0    0    -1  
$EndComp
$Comp
L dodo-analog:LMP2011 IC1
U 2 1 5E58D522
P 8900 2900
F 0 "IC1" V 8946 2822 50  0000 R CNN
F 1 "LMP2011" V 8855 2822 50  0000 R CNN
F 2 "Package_TO_SOT_SMD:SOT-23-5" H 8900 2550 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/lmp2011.pdf" H 8900 2900 50  0001 C CNN
	2    8900 2900
	0    -1   -1   0   
$EndComp
$Comp
L Amplifier_Difference:AD8276 U2
U 1 1 5E591F84
P 6550 4000
F 0 "U2" H 6750 3800 50  0000 L CNN
F 1 "AD8276" H 6650 3900 50  0000 L CNN
F 2 "Package_SO:SOIC-8_3.9x4.9mm_P1.27mm" H 6550 4000 50  0001 C CNN
F 3 "https://www.analog.com/media/en/technical-documentation/data-sheets/AD8276_8277.pdf" H 6550 4000 50  0001 C CNN
	1    6550 4000
	1    0    0    -1  
$EndComp
$Comp
L power:-5V #PWR07
U 1 1 5E5A11BC
P 6450 4450
F 0 "#PWR07" H 6450 4550 50  0001 C CNN
F 1 "-5V" H 6465 4623 50  0000 C CNN
F 2 "" H 6450 4450 50  0001 C CNN
F 3 "" H 6450 4450 50  0001 C CNN
	1    6450 4450
	-1   0    0    1   
$EndComp
$Comp
L power:+5V #PWR06
U 1 1 5E5A24A4
P 6450 3550
F 0 "#PWR06" H 6450 3400 50  0001 C CNN
F 1 "+5V" H 6465 3723 50  0000 C CNN
F 2 "" H 6450 3550 50  0001 C CNN
F 3 "" H 6450 3550 50  0001 C CNN
	1    6450 3550
	1    0    0    -1  
$EndComp
Wire Wire Line
	6450 3700 6450 3550
Wire Wire Line
	6450 4450 6450 4350
Wire Wire Line
	6550 3700 6550 3600
Wire Wire Line
	6550 3600 7000 3600
Wire Wire Line
	7000 3600 7000 3750
Connection ~ 7000 4000
Wire Wire Line
	5900 4350 5800 4350
Wire Wire Line
	5800 4350 5800 4200
Wire Wire Line
	6050 4200 6050 4100
Wire Wire Line
	6050 4100 6250 4100
Wire Wire Line
	6200 4350 6450 4350
Connection ~ 6450 4350
Wire Wire Line
	6450 4350 6450 4300
$Comp
L power:GND #PWR08
U 1 1 5E5C4C9F
P 6750 4400
F 0 "#PWR08" H 6750 4150 50  0001 C CNN
F 1 "GND" H 6755 4227 50  0000 C CNN
F 2 "" H 6750 4400 50  0001 C CNN
F 3 "" H 6750 4400 50  0001 C CNN
	1    6750 4400
	1    0    0    -1  
$EndComp
Wire Wire Line
	6550 4300 6750 4300
Wire Wire Line
	6750 4300 6750 4400
$Comp
L Connector:TestPoint TP6
U 1 1 5E716044
P 7000 3750
F 0 "TP6" V 6954 3938 50  0000 L CNN
F 1 "TestPoint" V 7045 3938 50  0000 L CNN
F 2 "TestPoint:TestPoint_Pad_3.0x3.0mm" H 7200 3750 50  0001 C CNN
F 3 "https://eu.mouser.com/datasheet/2/215/Keystone_Electronics_04082019_5190TR-5199TR-1551357.pdf" H 7200 3750 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Keystone-Electronics/5194TR?qs=sGAEpiMZZMtzcnMBgC2bs84ygu06jYzulkX4bJ%2F%252Bd0s%3D" V 7000 3750 50  0001 C CNN "BOM"
	1    7000 3750
	0    1    1    0   
$EndComp
Connection ~ 7000 3750
Wire Wire Line
	7000 3750 7000 4000
$Comp
L Device:R_POT_TRIM RV?
U 1 1 5E72B223
P 7900 4000
AR Path="/5E72B223" Ref="RV?"  Part="1" 
AR Path="/5E58DC75/5E72B223" Ref="RV?"  Part="1" 
AR Path="/5E5C48E0/5E72B223" Ref="RV?"  Part="1" 
AR Path="/5E5C53D8/5E72B223" Ref="RV?"  Part="1" 
AR Path="/5E556D6F/5E72B223" Ref="RV6"  Part="1" 
F 0 "RV6" H 7830 4046 50  0000 R CNN
F 1 "R_POT_TRIM" H 7830 3955 50  0000 R CNN
F 2 "Potentiometer_SMD:Potentiometer_Bourns_3314J_Vertical" H 7900 4000 50  0001 C CNN
F 3 "~" H 7900 4000 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Bourns/3314J-2-105E?qs=sGAEpiMZZMvygUB3GLcD7g2uut0mCOdNBBUJ5VY5B4c%3D" H 7900 4000 50  0001 C CNN "BOM"
	1    7900 4000
	0    1    -1   0   
$EndComp
$Comp
L Device:C C?
U 1 1 5E72B229
P 8350 4300
AR Path="/5E5C48E0/5E72B229" Ref="C?"  Part="1" 
AR Path="/5E5C53D8/5E72B229" Ref="C?"  Part="1" 
AR Path="/5E556D6F/5E72B229" Ref="C5"  Part="1" 
F 0 "C5" H 8465 4346 50  0000 L CNN
F 1 "C" H 8465 4255 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric" H 8388 4150 50  0001 C CNN
F 3 "~" H 8350 4300 50  0001 C CNN
	1    8350 4300
	1    0    0    -1  
$EndComp
Wire Wire Line
	7900 3850 7900 3800
Wire Wire Line
	7900 3800 8350 3800
Wire Wire Line
	8350 3800 8350 4000
NoConn ~ 8050 4000
$Comp
L power:GND #PWR?
U 1 1 5E72B235
P 8350 4450
AR Path="/5E5C53D8/5E72B235" Ref="#PWR?"  Part="1" 
AR Path="/5E556D6F/5E72B235" Ref="#PWR027"  Part="1" 
F 0 "#PWR027" H 8350 4200 50  0001 C CNN
F 1 "GND" H 8355 4277 50  0000 C CNN
F 2 "" H 8350 4450 50  0001 C CNN
F 3 "" H 8350 4450 50  0001 C CNN
	1    8350 4450
	1    0    0    -1  
$EndComp
Wire Wire Line
	8600 4000 8350 4000
Connection ~ 8350 4000
Wire Wire Line
	8350 4000 8350 4150
$Comp
L Connector:TestPoint TP?
U 1 1 5E72B23E
P 8600 4000
AR Path="/5E5C53D8/5E72B23E" Ref="TP?"  Part="1" 
AR Path="/5E556D6F/5E72B23E" Ref="TP13"  Part="1" 
F 0 "TP13" V 8554 4188 50  0000 L CNN
F 1 "TestPoint" V 8645 4188 50  0000 L CNN
F 2 "TestPoint:TestPoint_Pad_3.0x3.0mm" H 8800 4000 50  0001 C CNN
F 3 "https://eu.mouser.com/datasheet/2/215/Keystone_Electronics_04082019_5190TR-5199TR-1551357.pdf" H 8800 4000 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Keystone-Electronics/5194TR?qs=sGAEpiMZZMtzcnMBgC2bs84ygu06jYzulkX4bJ%2F%252Bd0s%3D" V 8600 4000 50  0001 C CNN "BOM"
	1    8600 4000
	0    1    1    0   
$EndComp
Wire Wire Line
	7000 4000 7750 4000
Wire Wire Line
	5850 3900 5900 3900
Wire Wire Line
	5900 3900 5900 3500
Wire Wire Line
	5900 3500 5250 3500
Connection ~ 5900 3900
Wire Wire Line
	5900 3900 6250 3900
Wire Wire Line
	5250 3800 5100 3800
Wire Wire Line
	5100 3800 5100 3650
Wire Wire Line
	4950 3500 4800 3500
$Comp
L Device:R_POT_TRIM RV?
U 1 1 5E56A0C9
P 5100 4250
AR Path="/5E56A0C9" Ref="RV?"  Part="1" 
AR Path="/5E556D6F/5E56A0C9" Ref="RV1"  Part="1" 
F 0 "RV1" H 5030 4204 50  0000 R CNN
F 1 "R_POT_TRIM" H 5030 4295 50  0000 R CNN
F 2 "Potentiometer_SMD:Potentiometer_Bourns_3314J_Vertical" H 5100 4250 50  0001 C CNN
F 3 "~" H 5100 4250 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Bourns/3314J-2-105E?qs=sGAEpiMZZMvygUB3GLcD7g2uut0mCOdNBBUJ5VY5B4c%3D" H 5100 4250 50  0001 C CNN "BOM"
	1    5100 4250
	0    -1   -1   0   
$EndComp
Wire Wire Line
	5350 4450 5350 4250
Wire Wire Line
	5350 4250 5250 4250
Wire Wire Line
	5100 4100 5100 4000
Wire Wire Line
	5100 4000 5250 4000
Wire Wire Line
	4950 4250 4800 4250
$EndSCHEMATC
