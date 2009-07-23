#include <stdio.h>
#include <unistd.h>
#include <libgen.h>
#include <string.h>

#ifndef MODULE_PATH
#error "no MODULE_PATH defined"
#endif

int main(int argc, char **argv)
{
	int i;
	char *argv_copy[argc + 5];

	argv_copy[0] = basename(argv[0]);
	argv_copy[1] = "-O";
	argv_copy[2] = "-E";
	argv_copy[3] = MODULE_PATH;
	

	for(i = 1; i < argc; i++) {
		argv_copy[i + 3] = strdup(argv[i]);
	}
	argv_copy[i + 3] = NULL;

	execv("/usr/bin/python", argv_copy);
	perror("execv");
}
