#include <stdio.h>
#include <stdlib.h>

// Q1.15 format macros
#define Q 15 
#define ADC_WIDTH 10
#define ONE_Q 32767 
#define TO_FLOAT( x ) ( ( (float)x ) / ( 1UL << Q ) )
#define ADC_TO_Q115( x ) ( (x - 512) << (Q - ADC_WIDTH) )

#define ZERO_SCORE_LAGS 4
#define ZERO_SCORE_ALPHA 328 // 0.01
#define ZERO_SCORE_NOISE  983 // 0.03
#define ZERO_SCORE_THRES (4UL << Q)

// static debugging
#define DATA_LENGTH 11

typedef struct {
    int buffer[ZERO_SCORE_LAGS];
    int avg;
    int var;
    int filtered;
    unsigned char head;
} ZSD_t; // zero-score detector

// input format q1.15 -> sqrt() -> q1.15
int sqrt_lut [256] = {
  0, 181, 256, 314, 362, 405, 443, 479, 512, 543, 572,
  600, 627, 653, 677, 701, 724, 746, 768, 789, 810, 830,
  849, 868, 887, 905, 923, 941, 958, 975, 991, 1008, 1024,
  1040, 1056, 1071, 1086, 1101, 1116, 1130, 1145, 1159, 1173, 1187,
  1201, 1214, 1228, 1241, 1254, 1267, 1280, 1293, 1305, 1318, 1330,
  1342, 1355, 1367, 1379, 1390, 1402, 1414, 1425, 1437, 1448, 1459,
  1471, 1482, 1493, 1504, 1515, 1525, 1536, 1547, 1557, 1568, 1578,
  1588, 1599, 1609, 1619, 1629, 1639, 1649, 1659, 1669, 1679, 1688,
  1698, 1708, 1717, 1727, 1736, 1746, 1755, 1764, 1774, 1783, 1792,
  1801, 1810, 1819, 1828, 1837, 1846, 1855, 1864, 1872, 1881, 1890,
  1899, 1907, 1916, 1924, 1933, 1941, 1950, 1958, 1966, 1975, 1983,
  1991, 1999, 2008, 2016, 2024, 2032, 2040, 2048, 2056, 2064, 2072,
  2080, 2088, 2095, 2103, 2111, 2119, 2126, 2134, 2142, 2149, 2157,
  2165, 2172, 2180, 2187, 2195, 2202, 2210, 2217, 2224, 2232, 2239,
  2246, 2254, 2261, 2268, 2275, 2283, 2290, 2297, 2304, 2311, 2318,
  2325, 2332, 2339, 2346, 2353, 2360, 2367, 2374, 2381, 2388, 2395,
  2401, 2408, 2415, 2422, 2429, 2435, 2442, 2449, 2455, 2462, 2469,
  2475, 2482, 2489, 2495, 2502, 2508, 2515, 2521, 2528, 2534, 2541,
  2547, 2554, 2560, 2566, 2573, 2579, 2585, 2592, 2598, 2604, 2611,
  2617, 2623, 2629, 2636, 2642, 2648, 2654, 2660, 2667, 2673, 2679,
  2685, 2691, 2697, 2703, 2709, 2715, 2721, 2727, 2733, 2739, 2745,
  2751, 2757, 2763, 2769, 2775, 2781, 2787, 2793, 2798, 2804, 2810,
  2816, 2822, 2828, 2833, 2839, 2845, 2851, 2856, 2862, 2868, 2874,
  2879, 2885, 2891 
};

int fsqrt(int x){
    if (x > 255) {
        return sqrt_lut[255]; 
    } else {
        return sqrt_lut[x];
    }
}

// NOTE pramater a can be bigger 
// than one up to certain extend
// this is intended to be used 
// in the detector function
int fmul(uint32_t a, int b){
  // TODO add missing overflow exception
  uint32_t tmp = (a*b + (1UL << (Q-1)));
  return (int)(tmp >> Q);
}

void detector_init(ZSD_t *d){
    d->head = 0;
    d->avg = 0;
    d->var = 0;
    d->filtered = 0;
    memset(d->buffer, 0, sizeof(d->buffer));
}

int detector_update( ZSD_t *d, int value){
    int delta = value;
    int event = 0;
    Serial.print("value: ");
    Serial.println(delta);

    // save previous states before updating
    int last = d->buffer[d->head];
    int last_avg = d->avg;

    // classification
    int input = delta - d->avg;

    int limit = fmul(ZERO_SCORE_THRES, fsqrt(d->var));
    int ema_a = fmul(ZERO_SCORE_ALPHA, delta);
    int ema_b = fmul((ONE_Q - ZERO_SCORE_ALPHA), d->filtered);

    Serial.print("input: ");
    Serial.print(input);
    Serial.print(", ");
    Serial.print("limit: ");
    Serial.print(limit);
    Serial.print(", ");
    Serial.print("ema_a: ");
    Serial.print(ema_a);
    Serial.print(", ");
    Serial.print("ema_b: ");
    Serial.println(ema_b);

    if ((abs(input) > limit) && (limit > 0)){
       if (input > ZERO_SCORE_NOISE) event = 1;
       d->filtered = ema_a + ema_b;
    } else {
       d->filtered = delta;
    }

    // update average and variance
    d->avg += ((d->filtered - last) >> 2); // NOTE don't forget to change it
    
    int a = d->filtered - last;
    int b = d->filtered - d->avg + last - last_avg;
    d->var += fmul(a, b) >> 2;

    Serial.print("filtered: ");
    Serial.print(d->filtered);
    Serial.print(", ");
    Serial.print("avg: ");
    Serial.print(d->avg);
    Serial.print(", ");
    Serial.print("var: ");
    Serial.print(d->var);
    Serial.print(", ");
    Serial.print("stddev: ");
    Serial.println(fsqrt(d->var));

    // update circular buffer
    d->buffer[d->head] = d->filtered;
    d->head = (d->head + 1) & (ZERO_SCORE_LAGS - 1);

    return event;
}

// global variables
int data [DATA_LENGTH] = {400, 580, 600, 800, 1000, 1020, 200, 300, 443, 700, 100};
int index = 0;
int tmp = 0;
ZSD_t detector;

void setup() {

  // initialize console
  Serial.begin(115200);
  while (!Serial);

  Serial.println("Running Haptix test\n");

  // initialize detector
  detector_init(&detector);
}

void loop() {
  if(index < DATA_LENGTH){
    tmp = ADC_TO_Q115(data[index]);
    detector_update(&detector, tmp); 
    ++index;
  }
}
