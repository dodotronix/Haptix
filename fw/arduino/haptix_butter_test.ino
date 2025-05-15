#include <stdio.h>
#include <stdlib.h>

#define BUTTER_SIZE 3
#define BUFFER_SIZE 8
#define BUFFER_MASK (BUFFER_SIZE) - 1
#define OFFSET_MEAS_LENGTH 4 // i can go up to 16

#define Q 15 
#define ONE_Q 32767
#define ADC_WIDTH 10
#define TO_FLOAT( x ) ( ( (float)x ) / ( 1UL << Q ) )
#define ADC_TO_Q115( x ) ( (x - 512) << (Q - ADC_WIDTH) )

// NOTE factor is unsigned 
// 16-bit positive number
// #define FACTOR 36700 // 0.56
#define FACTOR 32767 // ~1

// static debugging
#define DATA_LENGTH 12

// constants
const int32_t a[3] = {32767, -49354, 19856};
const int32_t b[3] = {817, 1635, 817};

typedef struct {
    int in[BUFFER_SIZE];
    int out[BUFFER_SIZE];
    int offset;
    int factor;
    uint8_t dly;
    uint8_t head;
} BF_t; // input filter circular buffer

int get_adc_data(int *index, int *data) {
  int tmp = ADC_TO_Q115(data[(*index)++]);
  Serial.print("adc data: ");
  Serial.println(tmp);
  return tmp;
}

// NOTE pramater a can be bigger 
// than one up to certain extend
// this is intended to be used 
// in the detector function
int fmul(int32_t a, int16_t b){
  Serial.print("input a: ");
  Serial.print(a);
  Serial.print(", ");
  Serial.print("input b: ");
  Serial.print(b);
  Serial.print(", ");
 
  int32_t tmp = a*b;
  tmp += (tmp >= 0) ? (1 << (Q - 1)) : -(1 << (Q - 1));

  Serial.print("tmp: ");
  Serial.println(tmp);

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
void butter_push(BF_t *filter, int value) {
    // shift in the new value
    filter->head = (filter->head + 1) & BUFFER_MASK;
    int obtained = value - filter->offset;
    filter->in[filter->head] = fmul(filter->factor, obtained);


    Serial.print("factor: ");
    Serial.print(filter->factor);
    Serial.print(", ");
    Serial.print("value: ");
    Serial.print(value);
    Serial.print(", ");
    Serial.print("obtained: ");
    Serial.print(obtained);
    Serial.print(", ");
    Serial.print("filter in: ");
    Serial.println(filter->in[filter->head]);

    int32_t result = 0; 
    for (int i = 0; i < BUTTER_SIZE; ++i) {
        int idx = (filter->head - filter->dly - i) & BUFFER_MASK;
        result += fmul(b[i], filter->in[idx]);
    }

    for (int i = 1; i < BUTTER_SIZE; ++i) {
        int idx = (filter->head - i) & BUFFER_MASK;
        result -= fmul(a[i], filter->out[idx]);
    }

    filter->out[filter->head] = result;
    Serial.print("output: ");
    Serial.println(filter->out[filter->head]);
    Serial.println("");
}

// global variables
int data [DATA_LENGTH] = {512, 400, 580, 600, 800, 1000, 1020, 200, 300, 443, 700, 100};
int index = 0;
int tmp = 0;

BF_t sensor;
int trigger = 1; // for tests, we don't have to wait for timer

void setup() {
  int32_t offset = 0;
  int tmp;

  // initialize console
  Serial.begin(115200);
  while (!Serial);

  Serial.println("Running Haptix test\n");

// find offset
#if OFFSET_MEAS_LENGTH
    for(int i=0; i<OFFSET_MEAS_LENGTH; ++i) {
      Serial.println("waiting for next sample ...");

      while(!trigger); //wait for trigger
      tmp = get_adc_data(&index, data);
      offset += tmp;
    }

    // rounding and division
    offset = ((offset + (1 << 1)) >> 2);
#endif

  Serial.print("offset: ");
  Serial.println((int)offset);

  // initialize buffer with 2nd order butterworth filter 
  butter_init(&sensor, 0, FACTOR, 0);
}

void loop() {
  if(index < DATA_LENGTH){
    tmp = get_adc_data(&index, data);
    butter_push(&sensor, tmp); 
  }
}
