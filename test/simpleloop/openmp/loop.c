#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <omp.h>
int main(int argc, char *argv[])
{
	omp_set_num_threads(2);
	// Beginning of parallel region
#pragma omp parallel
	{
		int i = 0;
		while (1) {
			printf("Thread  %d says %d\n", omp_get_thread_num(), i++);
			for (int j = 0; j < 1000000; j++)
				;
		}
	}
	// Ending of parallel region
}