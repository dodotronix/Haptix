#include <stdio.h>
#include <string.h>

#define BUFFER_SIZE 8
#define BUFFER_MASK (BUFFER_SIZE) - 1
#define BUTTER_SIZE 2
#define ZERO_SCORE_LAG 50

#define OFFSET_MEAS_LENGTH 2

#define ALPHA 0.01f
#define BETA 0.08f
#define GAMA 0.01f

// simulation
#define ADC_DATA_LENGTH 10

typedef struct {
    int data[ADC_DATA_LENGTH];
    int index;
} VirtADC_t;


typedef struct {
    float in[BUFFER_SIZE];
    float out[BUFFER_SIZE];
    float offset;
    float ema;
    float ema2;
    float var;
    float gradient;
    float factor;
    // TODO this should be 
    // replaced by int 
    // channel on arduino
    VirtADC_t *inst; 
    unsigned char delay;
    unsigned char head;
} BF_t; // input filter circular buffer

// deterministic filter constants
const float a[2] = {1.0f, 2.0f};
const float b[2] = {3.0f, 4.0f};

// simulated data stream
int dstream[ADC_DATA_LENGTH] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};

VirtADC_t channel1;
BF_t my_filter; 
ZSD_t detector;

void adc_init(VirtADC_t *inst, int *array, int num){
    inst->index = 0;
    for(int i=0; i<num; ++i)
        inst->data[i] = array[i];
}

float get_adc_data(VirtADC_t *inst){
    return inst->data[inst->index++];
}

void butter_init(BF_t *filter, VirtADC_t *inst, 
                 unsigned char delay, float factor){
    filter->inst = inst;
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
        // TODO here we going to wait for the trigger signal
        filter->offset += (float)get_adc_data(filter->inst); 
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
    float obtained = (float)get_adc_data(filter->inst) - filter->offset;
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
    printf("EMA: %f\n", filter->ema);
    filter->ema2 = BETA*(result*result) + (1 - BETA)*(filter->ema2);
    printf("EMA2: %f\n", filter->ema2);
    filter->var = filter->ema2 - (filter->ema)*(filter->ema);
    printf("VAR: %f\n", filter->var);
    filter->gradient = result - butter_get_nth(filter, 2);
    printf("gradient: %f\n", filter->gradient);

    filter->out[filter->head] = result;
    printf("filter out: %f\n\n", result);
}

void detector_init(ZSD_t *detector, float threshold){
    detector->threshold = threshold;
    detector->ema = 0;
    detector->ready = 0;
    detector->head = 0;
    detector->avgFilter = 0;
    detector->stdFilter = 0;
    memset(detector->filtered, 0, sizeof(detector->filtered));
}

int detector_update(ZSD_t *d, BF_t *f){
    // fill the buffers with data first
    float from_filter = butter_get_nth(f, 0);
    float accept_band = d->threshold * d->stdFilter; 
    float zero_score = from_filter - d->avgFilter;
    
    if(){

    } else {

    }

    
    return 0;
}



// TODO add a second sensor as parameter
//int adaptive_filter(BF_t *filter, float threshold){
//
//    static float ema = 0; 
//    static float ema2 = 0; 
//    static float var = 0; 
//
//    // kalman constants
//    static float r = 10;
//    static float q = 1;
//
//    // kalman initial vars 
//    static float P = 0;
//    static float x_est = 0;
//
//    static float avgFilter [10] = []; 
//
//    float sample = butter_get_nth(filter, 0);
//    printf("kalman P: %f\n", P);
//    printf("klaman in: %f\n", sample);
//
//    // prediction
//    float x_pred = x_est; 
//    float P_pred = P + q;
//
//    //update
//    float K = P_pred/(P_pred + r);
//    x_est = x_pred + K*(sample - x_pred);
//    P = (1 - K)*P_pred;
//    printf("klaman out: %f\n", x_est);
//
//    // zero-score detection
//    ema = alpha*x_est + (1 - alpha)*ema;
//    ema2 = alpha*(x_est*x_est) + (1 - alpha)*ema2;
//    var = ema2 - (ema*ema);
//    printf("kalman out EMA: %f\n", ema);
//    printf("kalman out EMA2: %f\n", ema2);
//    printf("kalman out VAR: %f\n\n", var);
//
//    // zero-score detection
//    if(detector_update())
//        return 1;
//
//    return 0;
//}

int main(){
    int event = 0;
    // int virtual ADC
    adc_init(&channel1, dstream, ADC_DATA_LENGTH); 

    // init filter
    butter_init(&my_filter, &channel1, 2, 0.6);

    // init detector
    detector_init(&detector, 3.5)

    // simulate incoming data
    for(int i=0; i<(ADC_DATA_LENGTH-OFFSET_MEAS_LENGTH); ++i){
        butter_push(&my_filter); 
        event = detector_update(&detector, &my_filter);
        //event = adaptive_filter(&my_filter, 4, 0.01);
        if(event) printf("EVENT DETECTED\n\n");
    }

    return 0;
}
