#include <stdio.h>
#include <unistd.h>

int main() {
    int counter = 1; 

    while(1) {
        printf("%d\n", counter);
        counter++; 
         sleep(1);
    }

    return 0; 
}
