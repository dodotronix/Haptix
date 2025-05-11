#include <stdio.h>
#include <Adafruit_MCP3008.h>

#define YELLOW 6
#define BLUE 7
#define BUTTER_SIZE 2
#define BUFFER_SIZE 8
#define BUFFER_MASK (BUFFER_SIZE) - 1
#define OFFSET_MEAS_LENGTH 10

#define ALPHA 0.01f
#define BETA 0.08f


typedef struct {
    float in[BUFFER_SIZE];
    float out[BUFFER_SIZE];
    float offset;
    float ema;
    float ema2;
    float var;
    float gradient;
    float factor;
    int channel;
    int delay;
    int head;
} BF_t; // input filter circular buffer

const float a[2] = {1.0, -0.8677558};
const float b[2] = {0.0661221, 0.0661221};

Adafruit_MCP3008 adc;
BF_t force;
int touched;

volatile uint8_t trigger = 0;

void butter_init(BF_t *filter, int channel, int delay, float factor, unsigned char *trigger){
    filter->channel = channel;
    filter->offset = 0;
    filter->head = 0;
    filter->ema = 0;
    filter->ema2 = 0;
    filter->var = 0;
    filter->gradient = 0;
    filter->factor = factor;
    filter->delay = delay;
    memset(filter->in, 0, sizeof(filter->in));
    memset(filter->out, 0, sizeof(filter->out));

    // calculate offset 
#if OFFSET_MEAS_LENGTH
    for(int i=0; i<OFFSET_MEAS_LENGTH; ++i)
        while(!*trigger); // wait for data ready
        *trigger = 0;
        filter->offset += (float)adc.readADC(filter->channel);
    filter->offset /= OFFSET_MEAS_LENGTH;
#endif

    printf("offset: %f\n", filter->offset);
}

float butter_get_nth(BF_t *filter, unsigned char n) {
  unsigned char index = (filter->head - n) & BUFFER_MASK;
  return filter->out[index];
}

// butterworth filter function 
void butter_push(BF_t *filter) {
    // shift in the new value
    filter->head = (filter->head + 1) & BUFFER_MASK;
    float obtained = (float)adc.readADC(filter->channel) - filter->offset;
    filter->in[filter->head] = filter->factor * obtained;
    printf("filter input: %f\n", filter->in[filter->head]);

    float result = 0; 
    //printf("%f\n", filter->in[0]);

    for (int i = 0; i < BUTTER_SIZE; ++i) {
        int idx = (filter->head - filter->delay - i) & BUFFER_MASK;
        //printf("a%i %i %f\n", i, idx, filter->in[idx]);
        result += b[i] * filter->in[idx];
    }

    for (int i = 1; i < BUTTER_SIZE; ++i) {
        int idx = (filter->head - i) & BUFFER_MASK;
        //printf("b%i %i %f\n", i, idx, filter->out[idx]);
        result -= a[i] * filter->out[idx];
    }

    // update ema, ema2 and var
    filter->ema = ALPHA*(result) + (1 - ALPHA)*(filter->ema);
    //printf("EMA: %f\n", filter->ema);
    filter->ema2 = BETA*(result*result) + (1 - BETA)*(filter->ema2);
    //printf("EMA2: %f\n", filter->ema2);
    filter->var = filter->ema2 - (filter->ema)*(filter->ema);
    //printf("VAR: %f\n", filter->var);
    filter->gradient = result - butter_get_nth(filter, 2);
    //printf("gradient: %f\n", filter->gradient);

    filter->out[filter->head] = result;
    printf("filter out: %f\n\n", result);
}

uint8_t detector(BF_t *sens0, volatile uint8_t *trigger) {
  if (!(*trigger))
    return 0;

  *trigger = 0;
  butter_push(sens0);

  //simple detect threshold
  if(butter_get_nth(sens0, 0) > 20)
    return 1;
  return 0;
}

void setup() {
  cli();
  TCCR1A = 0;           // Init Timer1A
  TCCR1B = 0;           // Init Timer1B
  TCCR1B |= B00000001;  // Prescaler = 1
  TCNT1 = 63135;        // Timer Preloading
  TIMSK1 |= B00000001;  // Enable Timer Overflow Interrupt
  sei();

  // set pin 
  pinMode(YELLOW, OUTPUT);
  pinMode(BLUE, OUTPUT);
  digitalWrite(YELLOW, HIGH);

  Serial.begin(115200);
  while (!Serial);

  Serial.println("Running Haptix proof-of-concept program\n");
  adc.begin(10);

  //initialize
  butter_init(&force, 0, 0, 1, &trigger);

  digitalWrite(BLUE, HIGH);
  digitalWrite(YELLOW, LOW);
}

ISR(TIMER1_OVF_vect){
  TCNT1 = 63135; // Timer Preloading
  trigger = 1;
}

void loop() {
    if(touched){
      digitalWrite(YELLOW, HIGH);
      digitalWrite(BLUE, LOW);
    } else {
      digitalWrite(YELLOW, LOW);
      digitalWrite(BLUE, HIGH);
    }
}
