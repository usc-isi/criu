#include "criu.h"
#include "lib.h"
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <limits.h>
#include <stdio.h>
#include <errno.h>
#include <signal.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>


int main(int argc, char *argv[])
{
	int ret, fd, pid;
	int counter = 0;
	const char *dirName = "output";
	struct stat st = { 0 };

	// Check if directory exists
	if (stat(dirName, &st) == -1) {
		// Directory doesn't exist, create it
		if (mkdir(dirName, 0700) != 0) {
			perror("Failed to create directory");
			return 1;
		}
		printf("Directory '%s' created.\n", dirName);
	} else {
		printf("Directory '%s' already exists.\n", dirName);
	}

	fd = open("./output", O_DIRECTORY);
	if (fd < 0) {
		perror("Can't open images dir");
		return 1;
	}

	criu_init_opts();
	criu_set_service_binary("/mnt/criu/criu");
	criu_set_images_dir_fd(fd);
	criu_set_log_level(CRIU_LOG_DEBUG);
    criu_set_shell_job(true);
    pid = getpid();
    printf("current pid = %d\n", pid);
    criu_set_log_file("dump.log");
    // criu_set_pid(pid);
    criu_set_leave_running(true);
		

	while (1) {
		counter++;
		printf("CRIU Testing counter = %d\n", counter);
        sleep(1);
		if (counter == 3) {
            printf("Start checkpointing...\n");
            ret = criu_dump();
            if (ret < 0) {
                what_err_ret_mean(ret);
                exit(1);
            }
            if (ret == 0)
            {
                printf("Success! :) Checkpoint saved to directory: %s \n", dirName);
            }
                
	    }

        if (counter == 5){
            criu_set_leave_running(false);
            printf("Start checkpointing...\n");
            ret = criu_dump();
            if (ret < 0) {
                what_err_ret_mean(ret);
                exit(1);
            }
            if (ret == 0)
            {
                printf("Success! :) Checkpoint saved to directory: %s \n", dirName);
            }
        }
    }

    return 0;
}
