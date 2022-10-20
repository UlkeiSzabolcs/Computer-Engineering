#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(){
    FILE *f;
    f = fopen("RandomNumbers.txt", "w");
    int rand_num;
    srand(time(0));
    for(int i = 0; i < 600; i++){
        rand_num = rand();
        rand_num = rand() % 200;
        fprintf(f, "%d ", rand_num);
    }
    fclose(f);
}