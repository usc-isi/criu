#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>

void *task1(void *arg) {
    int counter = 1;
    while (1) {
        printf("Thread 1 - Count: %d\n", counter++);
    }
    return NULL;
}

void *task2(void *arg) {
    int counter = 1;
    while (1) {
        printf("Thread 2 - Count: %d\n", counter++);
    }
    return NULL;
}

int main() {
    pthread_t thread1, thread2;
    int ret1, ret2;
    int counter = 1;

    // Create the threads
    ret1 = pthread_create(&thread1, NULL, task1, NULL);
    ret2 = pthread_create(&thread2, NULL, task2, NULL);

    if (ret1 || ret2) {
        fprintf(stderr, "Error creating threads\n");
        return 1;
    }

    while (1)
    {
        printf("Main Thread - Count: %d\n", counter++);
    }
    
    return 0;
}
