#include "criu.h"
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
#include "lib.h"
#include <stdio.h>


int main(int argc, char *argv[])
{
	int ret, fd, pid;
	const char *dirName = "output";

	fd = open("./output", O_DIRECTORY);
	if (fd < 0) {
		perror("Can't open images dir. Please check if it exists.");
		return 1;
	}

	criu_init_opts();
	criu_set_service_binary("/mnt/criu/criu");
	criu_set_images_dir_fd(fd);
	criu_set_log_level(CRIU_LOG_DEBUG);
	criu_set_shell_job(true);
	criu_set_log_file("restore.log");

	printf("--- Restore from images dir: %s ---\n", dirName);

	pid = criu_restore();
	printf("--- Restored pid is: %d ---\n", pid);

	if (pid <= 0) {
		what_err_ret_mean(pid);
		exit(1);
	}
	
	return 0;
}
