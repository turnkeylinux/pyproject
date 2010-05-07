#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>

void
clean_environ(void)
{
	static char def_IFS[] = "IFS= \t\n";
	static char def_PATH[] = "PATH=/sbin:/bin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin";
	static char def_CDPATH[] = "CDPATH=.";
	static char def_ENV[] = "ENV=:";

        char **p;
        extern char **environ;

        for (p = environ; *p; p++) {
                if (strncmp(*p, "LD_", 3) == 0)
                        **p = 'X';
                else if (strncmp(*p, "_RLD", 4) == 0)
                        **p = 'X';
                else if (strncmp(*p, "PYTHON", 6) == 0)
                        **p = 'X';
                else if (strncmp(*p, "IFS=", 4) == 0)
                        *p = def_IFS;
                else if (strncmp(*p, "CDPATH=", 7) == 0)
                        *p = def_CDPATH;
                else if (strncmp(*p, "ENV=", 4) == 0)
                        *p = def_ENV;
        }
        putenv(def_PATH);
}

int main()
{
	clean_environ();
	execl("/usr/bin/ipython", "ipython", NULL);
}
