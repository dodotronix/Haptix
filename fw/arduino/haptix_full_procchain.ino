#define YELLOW 6
#define BLUE 7
#define TIMER_PERIOD 59135 

#define Q 15 
#define ONE_Q 32767
#define ADC_WIDTH 10
#define ADC_TO_Q115( x ) ( (x - 512) << (Q - ADC_WIDTH) )

#define BUTTER_SIZE 3
#define BUFFER_SIZE 8
#define BUFFER_MASK (BUFFER_SIZE) - 1
#define OFFSET_MEAS_LENGTH 4 // i can go up to 16

#define ZERO_SCORE_LAGS 4
#define ZERO_SCORE_ALPHA 328 // 0.01
#define ZERO_SCORE_NOISE  983 // 0.03
#define ZERO_SCORE_THRES (4UL << Q)

#define FACTOR 18350 // 0.56
// #define FACTOR 32767 // ~1

#include <stdio.h>
#include <stdlib.h>
#include <Adafruit_MCP3008.h>

// constants (LPF freq. cutoff 120Hz)
const int a[3] = {32767, -48349, 19232};
const int b[3] = {913, 1826, 913};

typedef struct {
    int in[BUFFER_SIZE];
    int out[BUFFER_SIZE];
    int offset;
    int factor;
    uint8_t dly;
    uint8_t head;
} BF_t; // input filter circular buffer

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
    if (x > 255) return sqrt_lut[255]; 
    else return sqrt_lut[x];
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

void butter_init(BF_t *filter, int offset, int factor, uint8_t dly){
    filter->head = 0;
    filter->dly = dly;
    filter->factor = factor;
    filter->offset = offset;
    memset(filter->in, 0, sizeof(filter->in));
    memset(filter->out, 0, sizeof(filter->out));
}

int butter_get_nth(BF_t *filter, unsigned char n) {
  unsigned char index = (filter->head - n) & BUFFER_MASK;
  return filter->out[index];
}

// butterworth filter function 
int butter_push(BF_t *filter, int value) {
    // shift in the new value
    filter->head = (filter->head + 1) & BUFFER_MASK;
    int obtained = value - filter->offset;
    filter->in[filter->head] = fmul(filter->factor, obtained);

    uint32_t result = 0; 
    for (int i = 0; i < BUTTER_SIZE; ++i) {
        int idx = (filter->head - filter->dly - i) & BUFFER_MASK;
        result += fmul(b[i], filter->in[idx]);
    }

    for (int i = 1; i < BUTTER_SIZE; ++i) {
        int idx = (filter->head - i) & BUFFER_MASK;
        result -= fmul(a[i], filter->out[idx]);
    }

    filter->out[filter->head] = result;
    return result;
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

    // save previous states before updating
    int last = d->buffer[d->head];
    int last_avg = d->avg;

    // classification
    int input = delta - d->avg;

    int limit = fmul(ZERO_SCORE_THRES, fsqrt(d->var));
    int ema_a = fmul(ZERO_SCORE_ALPHA, delta);
    int ema_b = fmul((ONE_Q - ZERO_SCORE_ALPHA), d->filtered);

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

    // update circular buffer
    d->buffer[d->head] = d->filtered;
    d->head = (d->head + 1) & (ZERO_SCORE_LAGS - 1);

    return event;
}

Adafruit_MCP3008 adc;
volatile uint8_t trigger = 0;
int measured[2] = {0, 0};
int signal, event, active;
BF_t force, accel;
ZSD_t detector;

void setup() {

  uint32_t offset[2] = {0, 0};
  active = 0;

  cli();
  TCCR1A = 0;           // Init Timer1A
  TCCR1B = 0;           // Init Timer1B
  TCCR1B |= B00000001;  // Prescaler = 1
  TCNT1 = TIMER_PERIOD;        // Timer Preloading
  TIMSK1 |= B00000001;  // Enable Timer Overflow Interrupt
  sei();

  Serial.begin(115200);
  while (!Serial);

  Serial.println("Haptix initialization sequence\n");

  // set pins 
  pinMode(YELLOW, OUTPUT);
  pinMode(BLUE, OUTPUT);

  // initialize ADC
  adc.begin(10);

// find offset
#if OFFSET_MEAS_LENGTH
    for(int i=0; i<OFFSET_MEAS_LENGTH; ++i) {
      while(!trigger); //wait for trigger
      measured[0] = adc.readADC(0);
      measured[1] = adc.readADC(1);
      offset[0] += ADC_TO_Q115(measured[0]);
      offset[1] += ADC_TO_Q115(measured[1]);
    }

    // rounding and division
    offset[0] = ((offset[0] + (1 << 1)) >> 2);
    offset[1] = ((offset[1] + (1 << 1)) >> 2);
#endif

  // initialize input buffer
  butter_init(&force, (int)offset[0], ONE_Q, 3);
  butter_init(&accel, (int)offset[1], FACTOR, 0);

  // initialize edge detector
  detector_init(&detector); 
}

ISR(TIMER1_OVF_vect){
  TCNT1 = TIMER_PERIOD; // Timer Preloading
  trigger = 1;
}

void loop() {
  if(trigger){
    trigger = 0;
    digitalWrite(YELLOW, HIGH);

    // measure new samples 
    measured[0] = adc.readADC(0);
    measured[1] = adc.readADC(1);

    // processing chain
    signal = butter_push(&force, ADC_TO_Q115(measured[0]));
    signal -= butter_push(&accel, ADC_TO_Q115(measured[1]));
    event = detector_update(&detector, signal);

    // toggle active state until the 
    // signal sinks close to the zero 
    if(event && !active) active = 1;
    else if(abs(signal) < 10) active = 0; 

    // activate indicator
    if(active) digitalWrite(BLUE, HIGH);
    else digitalWrite(BLUE, LOW);

    digitalWrite(YELLOW, LOW);
  }
}
