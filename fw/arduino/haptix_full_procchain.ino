#define YELLOW 6
#define BLUE 7
#define TIMER_PERIOD 59135 

#define BUTTER_SIZE 3
#define BUFFER_SIZE 8
#define BUFFER_MASK (BUFFER_SIZE) - 1
#define OFFSET_MEAS_LENGTH 4 // i can go up to 16

#define Q 15 
#define ONE_Q 32767
#define ADC_WIDTH 10
#define ADC_TO_Q115( x ) ( (x - 512) << (Q - ADC_WIDTH) )

#define FACTOR 18350 // 0.56
// #define FACTOR 32767 // ~1

#include <stdio.h>
#include <stdlib.h>
#include <Adafruit_MCP3008.h>

// constants
const int a[3] = {32767, 3277, 328};
const int b[3] = {16384, 1638, 164};

typedef struct {
    int in[BUFFER_SIZE];
    int out[BUFFER_SIZE];
    int offset;
    int factor;
    uint8_t dly;
    uint8_t head;
} BF_t; // input filter circular buffer

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

Adafruit_MCP3008 adc;
volatile uint8_t trigger = 0;
int measured[2] = {0, 0};
int signal = 0;
BF_t force, accel;

void setup() {

  uint32_t offset[2] = {0, 0};

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
}

ISR(TIMER1_OVF_vect){
  TCNT1 = TIMER_PERIOD; // Timer Preloading
  trigger = 1;
}

void loop() {
  if(trigger){
    trigger = 0;
    digitalWrite(YELLOW, HIGH);
    measured[0] = adc.readADC(0);
    measured[1] = adc.readADC(1);
    signal = butter_push(&force, ADC_TO_Q115(measured[0]));
    signal -= butter_push(&accel, ADC_TO_Q115(measured[1]));

    if(signal > 328) digitalWrite(BLUE, HIGH);
    else digitalWrite(BLUE, LOW);

    digitalWrite(YELLOW, LOW);
  }
}
