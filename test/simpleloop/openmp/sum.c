#include <stdio.h>
#include <omp.h>

int main() {
    int n = 10000;
    double sum = 0.0;

    #pragma omp parallel for reduction(+:sum) num_threads(8)
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            for (int k = 0; k < n; k++) {
                sum += i * j * 0.1 * k * 0.01;
            }
        }
        printf("Thread %d is working on i = %d\n", omp_get_thread_num(), i);
    }

    printf("Sum: %f\n", sum);
    return 0;
}
