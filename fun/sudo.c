#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

#define MAX_LEN 100

int main(int ac, char **av) {
	char buffer[MAX_LEN];
	buffer[0] = 0;
	int offset = 0;
	int i = ac;
	while(av++,--i) {
		int toWrite = MAX_LEN-offset;
		int written = snprintf(buffer+offset, toWrite, "%s ", *av);
		if(toWrite < written)
			break;
		offset += written;
	}
	
	setuid(0);
	if (ac > 1)
		system(buffer);
	else
		system("zsh");
}
