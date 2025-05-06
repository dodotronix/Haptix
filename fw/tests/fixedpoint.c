#include <stdio.h>

#define Q 16 


int mul(int x, int y){
    return (x*y + (1 << (Q-1))) >> Q;
}

int main () {

    int array [4] = {10, 30, 100, 800};
    int trans = 0;
    int b = -49152;
    int result = 0;
    float test = 0;

    printf("converting\n");

    for(int i=0; i<4; ++i){
       trans = ((array[i] - 512) << 6);
       result = mul(trans, b);
       test = (float)result / (1 << 6);
       printf("a: %i, b: %i, result: %i, %f\n", trans, b, result, test);
    }

    return 0;
}
