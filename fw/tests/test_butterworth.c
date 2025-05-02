#include <stdio.h>
#include <string.h>

#define BUFFER_SIZE 8
#define BUFFER_MASK (BUFFER_SIZE) - 1
#define BUTTER_SIZE 2

typedef struct {
    float in[BUFFER_SIZE];
    float out[BUFFER_SIZE];
    unsigned char delay;
    unsigned char head;
} BF_t; // input filter circular buffer

// deterministic filter constants
const float a[2] = {1.0f, 2.0f};
const float b[2] = {3.0f, 4.0f};

// simulated data stream
float dstream[10] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
BF_t my_filter; 

void butter_init(BF_t *filter, unsigned char delay){
  filter->head = 0;
  filter->delay = delay;
  memset(filter->in, 0, sizeof(filter->in));
  memset(filter->out, 0, sizeof(filter->out));
}

float butter_get_nth(BF_t *filter, unsigned char n) {
  unsigned char index = (filter->head - n) & BUFFER_MASK;
  return filter->out[index];
}

// butterworth filter function 
void butter_push(BF_t *filter, float value) {
    // shift in the new value
    filter->head = (filter->head + 1) & BUFFER_MASK;
    filter->in[filter->head] = value;

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

    filter->out[filter->head] = result;
}

int main(){

    // init filter
    butter_init(&my_filter, 0);

    // simulate incoming data
    for(int i=0; i<10; ++i){
        printf("filter input: %f\n", dstream[i]);
        butter_push(&my_filter, dstream[i]); 
        printf("filter out: %f\n\n", butter_get_nth(&my_filter, 0));
    }

    return 0;
}
