#include <stdio.h>
#include <inttypes.h>

#include "afbd/main.h"

int main(int argc, char *argv[]) {
	printf("afbd main bus ID is 0x%" PRIX32 "\n", afbd_main_ID);

	return 0;
}
