// 1) start the digilent analog discovery power supply +-5V 
// 2) don't forget to check, if all the grounds have shortest
// track to the AD3 extension board with BENC connectors
// 3) run the program

#define YELLOW 6
#define BLUE 7
#define TIMER_PERIOD 58015 // Ts = 470us

#define Q 15 
#define ONE_Q 32767
#define ADC_WIDTH 9 // NOTE multiply your signal by pow2
#define ADC_TO_Q115( x ) ( (x - 512) << (Q - ADC_WIDTH) )

#define BUTTER_SIZE 3
#define BUFFER_SIZE 8
#define BUFFER_MASK (BUFFER_SIZE) - 1
#define OFFSET_MEAS_LENGTH 4 // i can go up to 16
#define DLY 3

#define ZERO_SCORE_EXTEND 2
#define ZERO_SCORE_ALPHA 2621 // 0.08
#define ZERO_SCORE_NOISE  2620 // 0.08
#define ZERO_SCORE_THRES (2UL << Q)
#define ZERO_SCORE_OFFSET 200

// this defines the conversion steps of the sqrt if
// you change it, you have to regenerate the LUT
#define SQRT_PRECISION 6

// needs to be power of 2
#define ZERO_SCORE_LAGS 64
// NOTE don't forget to change DIV, 
// if you change the ZERO_SCORE_LAGS
#define ZERO_SCORE_DIV 6

#define FACTOR 20316 // 0.62
// #define FACTOR 32767 // ~1

#include <stdio.h>
#include <stdlib.h>
#include <Adafruit_MCP3008.h>

// constants (LPF freq. cutoff 120Hz)
const int32_t a[3] = {32767, -48349, 19232};
const int32_t b[3] = {913, 1826, 913};

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
    0,  45,  64,  78,  91, 101, 111, 120, 128, 136,
  143, 150, 157, 163, 169, 175, 181, 187, 192, 197,
  202, 207, 212, 217, 222, 226, 231, 235, 239, 244,
  248, 252, 256, 260, 264, 268, 272, 275, 279, 283,
  286, 290, 293, 297, 300, 304, 307, 310, 314, 317,
  320, 323, 326, 329, 333, 336, 339, 342, 345, 348,
  351, 353, 356, 359, 362, 365, 368, 370, 373, 376,
  379, 381, 384, 387, 389, 392, 395, 397, 400, 402,
  405, 407, 410, 412, 415, 417, 420, 422, 425, 427,
  429, 432, 434, 436, 439, 441, 443, 446, 448, 450,
  453, 455, 457, 459, 462, 464, 466, 468, 470, 472,
  475, 477, 479, 481, 483, 485, 487, 490, 492, 494,
  496, 498, 500, 502, 504, 506, 508, 510, 512, 514,
  516, 518, 520, 522, 524, 526, 528, 530, 532, 534,
  535, 537, 539, 541, 543, 545, 547, 549, 551, 552,
  554, 556, 558, 560, 562, 563, 565, 567, 569, 571,
  572, 574, 576, 578, 580, 581, 583, 585, 587, 588,
  590, 592, 594, 595, 597, 599, 600, 602, 604, 605,
  607, 609, 611, 612, 614, 616, 617, 619, 621, 622,
  624, 625, 627, 629, 630, 632, 634, 635, 637, 638,
  640, 642, 643, 645, 646, 648, 650, 651, 653, 654,
  656, 657, 659, 660, 662, 664, 665, 667, 668, 670,
  671, 673, 674, 676, 677, 679, 680, 682, 683, 685,
  686, 688, 689, 691, 692, 694, 695, 697, 698, 700,
  701, 703, 704, 705, 707, 708, 710, 711, 713, 714,
  716, 717, 718, 720, 721, 723
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

    int result = 0; 
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

void detector_update( ZSD_t *d, int *event, int value){

    // classification
    int input = abs(value - (d->avg >> ZERO_SCORE_DIV));
    int limit = fmul(ZERO_SCORE_THRES, fsqrt(d->var)) + ZERO_SCORE_OFFSET;

    if (input > limit){
      d->filtered += fmul(ZERO_SCORE_ALPHA, (value - d->filtered));

      if ((value > (d->avg >> ZERO_SCORE_DIV)) && (input > ZERO_SCORE_NOISE) && !(*event))
        *event = 1;

    } else {
       d->filtered = value;

       // NOTE since it's a demo, we use 
       // static value to reset the event 
       // variable
       if((value < 1000) && (*event)) 
         *event = 0;
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
}

Adafruit_MCP3008 adc;
volatile uint8_t trigger = 0;
int measured[2] = {0, 0};
int signal, event;
BF_t force, accel;
ZSD_t detector;

void setup() {

  int32_t offset[2] = {0, 0};
  event = 0;

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
  butter_init(&force, (int)offset[0], ONE_Q, DLY);
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
    detector_update(&detector, &event, signal);

    // toggle active state until the 
    // signal sinks close to the zero 
    // if(signal > 100) event = 1;
    // else event = 0;

    // activate indicator
    if(event) digitalWrite(BLUE, HIGH);
    else digitalWrite(BLUE, LOW);

    digitalWrite(YELLOW, LOW);
  }
}
