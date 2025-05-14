#include <stdio.h>
#include <stdlib.h>

// Q1.15 format macros
#define Q 15 
#define ADC_WIDTH 10
#define ONE_Q 32767 
#define TO_FLOAT( x ) ( ( (float)x ) / ( 1UL << Q ) )
#define ADC_TO_Q115( x ) ( (x - 512) << (Q - ADC_WIDTH) )

#define ZERO_SCORE_LAGS 64
#define ZERO_SCORE_DIV 6

#define ZERO_SCORE_EXTEND 2
#define ZERO_SCORE_ALPHA 328 // 0.01
#define ZERO_SCORE_NOISE  983 // 0.03
#define ZERO_SCORE_THRES (4UL << Q)
#define SQRT_PRECISION 8

// static debugging
#define DATA_LENGTH 11

// the avg is window sum, you have to do the 
// bit shift to get the real average value
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

  if (index > 255) {
    Serial.print("(LUT SQRT Overflow) ");
    return sqrt_lut[255]; 
  } else {
    return sqrt_lut[index];
  }
}

// NOTE pramater a can be bigger 
// than one up to certain extend
// this is intended to be used 
// in the detector function
int fmul(int32_t a, int16_t b){

  int32_t tmp = a*b;
  Serial.print("fmul a: ");
  Serial.print(a);
  Serial.print(", ");
  Serial.print("fmul b: ");
  Serial.print(b);
  // Serial.print(", ");
  // Serial.print("tmp: ");
  // Serial.print(tmp);

  tmp += (tmp >= 0) ? (1 << (Q - 1)) : -(1 << (Q - 1));

  Serial.print(", ");
  Serial.print("fmul rounding: ");
  Serial.print(tmp);
  Serial.print(", ");
  Serial.print("fmul result: ");

  // NOTE: due to the C/C++ signed/unsigned type implementation 
  // shifting negative number will never reach 0 but always -1, 
  // therefore we have to check the condition manually, by
  // checking the abs() of the vaule
  if(!(abs(tmp) >> Q)) {
    Serial.println(0);
    return 0;
  }

  tmp >>= Q;

  // saturation
  if (tmp > ONE_Q) {
    Serial.println(tmp);
    return (int) ONE_Q;
  } else if (tmp < -(ONE_Q + 1)) {
    Serial.println(tmp);
    return (int) -(ONE_Q + 1);
  }

  Serial.println(tmp);
  return (int)tmp;
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
    Serial.print("value: ");
    Serial.println(value);

    // classification
    int input = abs(value - (d->avg >> ZERO_SCORE_DIV));
    int limit = fmul(ZERO_SCORE_THRES, fsqrt(d->var));

    Serial.print("limit: ");
    Serial.print(limit);
    Serial.print(", ");
    Serial.print("input: ");
    Serial.println(input);

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

    Serial.print("aa: ");
    Serial.print(aa);
    Serial.print(", ");
    Serial.print("bb: ");
    Serial.print(bb);
    Serial.print(", ");
    Serial.print("extend aa: ");
    Serial.print(aa << ZERO_SCORE_EXTEND);
    Serial.print(", ");
    Serial.print("extend bb: ");
    Serial.println(bb << ZERO_SCORE_EXTEND);

    Serial.print("filtered: ");
    Serial.print(d->filtered);
    Serial.print(", ");
    Serial.print("avg: ");
    Serial.print(d->avg >> ZERO_SCORE_DIV);
    Serial.print(", ");
    Serial.print("var: ");
    Serial.println(d->var);
    Serial.print("stddev: ");
    Serial.println(fsqrt(d->var));
    Serial.println("");

    // update circular buffer
    d->buffer[d->head] = d->filtered;
    d->head = (d->head + 1) & (ZERO_SCORE_LAGS - 1);

    return event;
}

// global variables
int data [DATA_LENGTH] = {-1904, -1909, -1914, -1921, -1929, -1939, 
                          -1950, -1960, -1968, -1977, -1980};
int index = 0;
int tmp = 0;
ZSD_t detector;

void setup() {
  // calculations
  int aa = 27;
  int bb = -7;

  // initialize console
  Serial.begin(115200);
  while (!Serial);

  Serial.println("Running Haptix test\n");

  // initialize detector
  detector_init(&detector);
}

void loop() {
  if(index < DATA_LENGTH){
    //tmp = ADC_TO_Q115(data[index]);
    detector_update(&detector, data[index]); 
    ++index;
  }
}
