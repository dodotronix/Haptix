#include <Adafruit_MCP3008.h>

#define BUFFER_SIZE 600

Adafruit_MCP3008 adc;

volatile uint8_t trigger = 0;
volatile uint8_t done = 0;

volatile int cnt = 0;
volatile int test [BUFFER_SIZE];

void setup() {
  cli();           // disable all interrupts
  TCCR1A = 0;           // Init Timer1A
  TCCR1B = 0;           // Init Timer1B
  TCCR1B |= B00000001;  // Prescaler = 1
  TCNT1 = 63135;        // Timer Preloading
  TIMSK1 |= B00000001;  // Enable Timer Overflow Interrupt
  sei();             // enable all interrupts

  Serial.begin(115200);
  while (!Serial);

  Serial.println("Haptix test\n");
  adc.begin(10);
}

ISR(TIMER1_OVF_vect){
  TCNT1 = 63135; // Timer Preloading
  if(!done) trigger = 1;
}

void loop() {
  if(trigger && !done) {
    trigger = 0;
    adc.readADC(1);
    adc.readADC(2);
    test[cnt++] = adc.readADC(0);
    if(cnt >= BUFFER_SIZE){
      cnt = 0;
      done = 1;
    }
  }

  if(done) {
    for(int i=0; i<BUFFER_SIZE; ++i){
        Serial.println(test[i]); //Serial.print("\t");
        //Serial.print("["); Serial.print(i); Serial.println("]");
    }
    delay(2000);
    done = 0;
  }

}
