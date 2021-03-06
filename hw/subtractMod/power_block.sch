EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 2 4
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
L Device:R R1
U 1 1 5E46C87F
P 4850 3100
F 0 "R1" H 4920 3146 50  0000 L CNN
F 1 "10k" H 4920 3055 50  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 4780 3100 50  0001 C CNN
F 3 "~" H 4850 3100 50  0001 C CNN
	1    4850 3100
	1    0    0    -1  
$EndComp
$Comp
L Device:R R2
U 1 1 5E46C9F4
P 4850 4000
F 0 "R2" H 4920 4046 50  0000 L CNN
F 1 "10k" H 4920 3955 50  0000 L CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 4780 4000 50  0001 C CNN
F 3 "~" H 4850 4000 50  0001 C CNN
	1    4850 4000
	1    0    0    -1  
$EndComp
Wire Wire Line
	4850 2950 4850 2850
Wire Wire Line
	4850 2850 4400 2850
$Comp
L Amplifier_Operational:TLV6001DCK U1
U 1 1 5E46E396
P 5700 3500
F 0 "U1" H 6144 3546 50  0000 L CNN
F 1 "TLV6001DCK" H 6144 3455 50  0000 L CNN
F 2 "Package_TO_SOT_SMD:SOT-353_SC-70-5" H 5900 3500 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/tlv6001.pdf" H 5700 3500 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Texas-Instruments/TLV6001IDCKT?qs=sGAEpiMZZMtCHixnSjNA6DsogjI1ODGwCALif4qq3rk%3D" H 5700 3500 50  0001 C CNN "BOM"
	1    5700 3500
	1    0    0    -1  
$EndComp
Wire Wire Line
	4850 3400 5500 3400
Connection ~ 4850 3400
Wire Wire Line
	4850 3400 4850 3250
Wire Wire Line
	4850 2850 5700 2850
Wire Wire Line
	5700 2850 5700 3200
Connection ~ 4850 2850
Wire Wire Line
	6100 3500 6250 3500
Wire Wire Line
	5500 3600 5350 3600
Wire Wire Line
	5350 3900 6250 3900
Wire Wire Line
	5350 3600 5350 3900
Wire Wire Line
	6250 3500 6250 3900
Wire Wire Line
	5700 3800 5700 4350
Connection ~ 5700 4350
Wire Wire Line
	5700 4350 6800 4350
Wire Wire Line
	4850 3400 4850 3850
Wire Wire Line
	4850 4150 4850 4350
Connection ~ 4850 4350
Wire Wire Line
	4850 4350 5700 4350
Wire Wire Line
	5700 2850 6800 2850
Connection ~ 5700 2850
$Comp
L Connector:TestPoint TP3
U 1 1 5E476409
P 7050 2850
F 0 "TP3" V 7004 3038 50  0000 L CNN
F 1 "TestPoint" V 7095 3038 50  0000 L CNN
F 2 "TestPoint:TestPoint_Pad_3.0x3.0mm" H 7250 2850 50  0001 C CNN
F 3 "https://eu.mouser.com/datasheet/2/215/Keystone_Electronics_04082019_5190TR-5199TR-1551357.pdf" H 7250 2850 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Keystone-Electronics/5190TR?qs=sGAEpiMZZMtzcnMBgC2bs84ygu06jYzuVIMf8n14jKk%3D" V 7050 2850 50  0001 C CNN "BOM"
	1    7050 2850
	0    1    1    0   
$EndComp
$Comp
L Connector:TestPoint TP5
U 1 1 5E476A08
P 7050 4350
F 0 "TP5" V 7004 4538 50  0000 L CNN
F 1 "TestPoint" V 7095 4538 50  0000 L CNN
F 2 "TestPoint:TestPoint_Pad_3.0x3.0mm" H 7250 4350 50  0001 C CNN
F 3 "https://eu.mouser.com/datasheet/2/215/Keystone_Electronics_04082019_5190TR-5199TR-1551357.pdf" H 7250 4350 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Keystone-Electronics/5197TR?qs=sGAEpiMZZMtzcnMBgC2bs84ygu06jYzuniTo7JD0ZPM%3D" V 7050 4350 50  0001 C CNN "BOM"
	1    7050 4350
	0    1    1    0   
$EndComp
$Comp
L Device:CP C1
U 1 1 5E4770EE
P 6800 3150
F 0 "C1" H 6918 3196 50  0000 L CNN
F 1 "47u" H 6918 3105 50  0000 L CNN
F 2 "Capacitor_SMD:CP_Elec_6.3x5.9" H 6838 3000 50  0001 C CNN
F 3 "~" H 6800 3150 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Lelon/VE-470M1ETR-0605?qs=sGAEpiMZZMtZ1n0r9vR22edRdWtfW0D7lThG7OIR4Pw%3D" H 6800 3150 50  0001 C CNN "BOM"
	1    6800 3150
	1    0    0    -1  
$EndComp
$Comp
L Device:CP C2
U 1 1 5E477A23
P 6800 4000
F 0 "C2" H 6682 3954 50  0000 R CNN
F 1 "47u" H 6682 4045 50  0000 R CNN
F 2 "Capacitor_SMD:CP_Elec_6.3x5.9" H 6838 3850 50  0001 C CNN
F 3 "~" H 6800 4000 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Lelon/VE-470M1ETR-0605?qs=sGAEpiMZZMtZ1n0r9vR22edRdWtfW0D7lThG7OIR4Pw%3D" H 6800 4000 50  0001 C CNN "BOM"
	1    6800 4000
	-1   0    0    1   
$EndComp
Wire Wire Line
	6800 2850 6800 3000
Wire Wire Line
	6800 3850 6800 3500
Wire Wire Line
	6800 4150 6800 4350
Connection ~ 6800 4350
Connection ~ 6800 2850
Wire Wire Line
	6250 3500 6800 3500
Connection ~ 6250 3500
Connection ~ 6800 3500
Wire Wire Line
	6800 3500 6800 3300
Wire Wire Line
	6250 3950 6250 3900
Connection ~ 6250 3900
Wire Wire Line
	6800 4350 7000 4350
$Comp
L power:-5V #PWR03
U 1 1 5E50AA96
P 7000 4350
F 0 "#PWR03" H 7000 4450 50  0001 C CNN
F 1 "-5V" H 7015 4523 50  0000 C CNN
F 2 "" H 7000 4350 50  0001 C CNN
F 3 "" H 7000 4350 50  0001 C CNN
	1    7000 4350
	1    0    0    -1  
$EndComp
Connection ~ 7000 4350
Wire Wire Line
	7000 4350 7050 4350
$Comp
L power:+5V #PWR02
U 1 1 5E5A81A0
P 7000 2850
F 0 "#PWR02" H 7000 2700 50  0001 C CNN
F 1 "+5V" H 7015 3023 50  0000 C CNN
F 2 "" H 7000 2850 50  0001 C CNN
F 3 "" H 7000 2850 50  0001 C CNN
	1    7000 2850
	1    0    0    -1  
$EndComp
Connection ~ 7000 2850
Wire Wire Line
	7000 2850 7050 2850
Wire Wire Line
	6800 2850 7000 2850
$Comp
L Connector:TestPoint TP4
U 1 1 5E5B9717
P 7050 3500
F 0 "TP4" V 7004 3688 50  0000 L CNN
F 1 "TestPoint" V 7095 3688 50  0000 L CNN
F 2 "TestPoint:TestPoint_Pad_3.0x3.0mm" H 7250 3500 50  0001 C CNN
F 3 "https://eu.mouser.com/datasheet/2/215/Keystone_Electronics_04082019_5190TR-5199TR-1551357.pdf" H 7250 3500 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Keystone-Electronics/5191TR?qs=sGAEpiMZZMtzcnMBgC2bs84ygu06jYzuxnC5p8Orm3U%3D" V 7050 3500 50  0001 C CNN "BOM"
	1    7050 3500
	0    1    1    0   
$EndComp
Wire Wire Line
	6800 3500 7050 3500
$Comp
L power:GND #PWR01
U 1 1 5E5BBB21
P 6250 3950
F 0 "#PWR01" H 6250 3700 50  0001 C CNN
F 1 "GND" H 6255 3777 50  0000 C CNN
F 2 "" H 6250 3950 50  0001 C CNN
F 3 "" H 6250 3950 50  0001 C CNN
	1    6250 3950
	1    0    0    -1  
$EndComp
Wire Wire Line
	4400 4350 4850 4350
Wire Wire Line
	4400 2850 4400 3500
Wire Wire Line
	4400 3600 4400 4350
$Comp
L Connector:Screw_Terminal_01x02 J3
U 1 1 5E58694F
P 4200 3600
F 0 "J3" H 4118 3275 50  0000 C CNN
F 1 "Screw_Terminal_01x02" H 4118 3366 50  0000 C CNN
F 2 "TerminalBlock_Phoenix:TerminalBlock_Phoenix_MKDS-1,5-2_1x02_P5.00mm_Horizontal" H 4200 3600 50  0001 C CNN
F 3 "~" H 4200 3600 50  0001 C CNN
F 4 "https://eu.mouser.com/ProductDetail/Molex/39773-0002?qs=sGAEpiMZZMvZTcaMAxB2AHpdXjUJWjdtLXxXrTFbGKtdTXrI6XNfww%3D%3D" H 4200 3600 50  0001 C CNN "BOM"
	1    4200 3600
	-1   0    0    1   
$EndComp
$EndSCHEMATC
