#define YELLOW 6
#define BLUE 7
#define TIMER_PERIOD 58015 // Ts = 470us

#define Q 15 
#define ONE_Q 32767
#define ADC_WIDTH 10
#define ADC_TO_Q115( x ) ( (x - 512) << (Q - ADC_WIDTH) )

#define BUTTER_SIZE 3
#define BUFFER_SIZE 8
#define BUFFER_MASK (BUFFER_SIZE) - 1
#define OFFSET_MEAS_LENGTH 4 // i can go up to 16

#define ZERO_SCORE_EXTEND 2
#define ZERO_SCORE_ALPHA 328 // 0.01
#define ZERO_SCORE_NOISE  983 // 0.03
#define ZERO_SCORE_THRES (4UL << Q)
#define SQRT_PRECISION 8

// needs to be power of 2
#define ZERO_SCORE_LAGS 64
// NOTE don't forget to change DIV, 
// if you change the ZERO_SCORE_LAGS
#define ZERO_SCORE_DIV 6

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

// input format q1.(15 + 2*EXTEND + DIV - PRECISION) -> sqrt() -> q1.15
int sqrt_lut [256] = {
  0, 91, 128, 157, 181, 202, 222, 239, 256, 272, 286, 300,
  314, 326, 339, 351, 362, 373, 384, 395, 405, 415, 425, 434,
  443, 453, 462, 470, 479, 487, 496, 504, 512, 520, 528, 535,
  543, 551, 558, 565, 572, 580, 587, 594, 600, 607, 614, 621,
  627, 634, 640, 646, 653, 659, 665, 671, 677, 683, 689, 695,
  701, 707, 713, 718, 724, 730, 735, 741, 746, 752, 757, 763,
  768, 773, 779, 784, 789, 794, 799, 804, 810, 815, 820, 825,
  830, 834, 839, 844, 849, 854, 859, 863, 868, 873, 878, 882,
  887, 891, 896, 901, 905, 910, 914, 919, 923, 927, 932, 936,
   941, 945,  949,   954,  958,  962,  966,  971,  975,  979,  983,  987,
   991,  996, 1000, 1004, 1008, 1012, 1016, 1020, 1024, 1028, 1032, 1036,
  1040, 1044, 1048, 1052, 1056, 1059, 1063, 1067, 1071, 1075, 1079, 1082,
  1086, 1090, 1094, 1097, 1101, 1105, 1109, 1112, 1116, 1120, 1123, 1127,
  1130, 1134, 1138, 1141, 1145, 1148, 1152, 1156, 1159, 1163, 1166, 1170,
  1173, 1177, 1180, 1184, 1187, 1190, 1194, 1197, 1201, 1204, 1208, 1211,
  1214, 1218, 1221, 1224, 1228, 1231, 1234, 1238, 1241, 1244, 1248, 1251,
  1254, 1257, 1261, 1264, 1267, 1270, 1274, 1277, 1280, 1283, 1286, 1290,
  1293, 1296, 1299, 1302, 1305, 1308, 1312, 1315, 1318, 1321, 1324, 1327,
  1330, 1333, 1336, 1339, 1342, 1346, 1349, 1352, 1355, 1358, 1361, 1364,
  1367, 1370, 1373, 1376, 1379, 1382, 1385, 1387, 1390, 1393, 1396, 1399,
  1402, 1405, 1408, 1411, 1414, 1417, 1420, 1422, 1425, 1428, 1431, 1434,
  1437, 1440, 1442, 1445
};

int fsqrt(int x){
  int index = (x >> SQRT_PRECISION);
    if (x > 255) return sqrt_lut[255]; 
    else return sqrt_lut[x];
}

// NOTE pramater a can be bigger 
// than one up to certain extend
// this is intended to be used 
// in the detector function
int fmul(int32_t a, int16_t b){
  int32_t tmp = a*b;
  tmp += (tmp >= 0) ? (1 << (Q - 1)) : -(1 << (Q - 1));

  // NOTE: due to the C/C++ signed/unsigned type implementation 
  // shifting negative number will never reach 0 but always -1, 
  // therefore we have to check the condition manually, by
  // checking the abs() of the vaule
  if(!(abs(tmp) >> Q)) {
    return 0;
  }

  tmp >>= Q;

  // saturation
  if (tmp > ONE_Q) {
    return (int) ONE_Q;
  } else if (tmp < -(ONE_Q + 1)) {
    return (int) -(ONE_Q + 1);
  }

  return (int)tmp;
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
    int event = 0;

    // classification
    int input = abs(value - (d->avg >> ZERO_SCORE_DIV));
    int limit = fmul(ZERO_SCORE_THRES, fsqrt(d->var));

    if ((input > limit) && (limit > 0)){
      d->filtered += fmul(ZERO_SCORE_ALPHA, (value - d->filtered));

      if ((value > (d->avg >> ZERO_SCORE_DIV)) && (value > ZERO_SCORE_NOISE))
        event = 1;

    } else {
       d->filtered = value;
    }

    // save previous states before updating
    int l_avg = d->avg;
    int aa = d->filtered - d->buffer[d->head];

    // update average and variance
    d->avg += aa;
    int c = ((d->avg + l_avg) >> ZERO_SCORE_DIV);
    int bb = d->filtered - c + d->buffer[d->head];
    d->var += fmul((aa << ZERO_SCORE_EXTEND), (bb << ZERO_SCORE_EXTEND));

    // variance cannot be negative
    if (d->var < 0)
      d->var = 0;

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

  Serial.println("[INFO] Haptix initialization sequence");
  Serial.println("");

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

  Serial.print("[INFO] offset force: ");
  Serial.println((int)offset[0]);
  Serial.print("[INFO] offset acceleration: ");
  Serial.println((int)offset[1]);

  // initialize input buffer
  Serial.println("[INFO] Initialize Butterworth filter");
  butter_init(&force, (int)offset[0], ONE_Q, 3);
  butter_init(&accel, (int)offset[1], FACTOR, 0);

  // initialize edge detector
  Serial.println("[INFO] Initialize detector");
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
    //if(event && !active) active = 1;
    //else if(abs(signal) < 10) active = 0; 
    if(signal > 300) active = 1;
    else active = 0;

    // activate indicator
    if(active) digitalWrite(BLUE, HIGH);
    else digitalWrite(BLUE, LOW);

    digitalWrite(YELLOW, LOW);
  }
}
