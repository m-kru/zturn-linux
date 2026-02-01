#include <errno.h>
#include <inttypes.h>
#include <stdio.h>
#include <time.h>
#include <fcntl.h>
#include <unistd.h>

#include "common/common.h"
#include "common/log.h"
#include "common/panic.h"

static int dev_fd;

typedef enum {
	ACTION_PROMPT,
	SWITCHES_READ,
	LEDS_WRITE,
	EXIT,
} state_t;

static state_t state = ACTION_PROMPT;

static void action_prompt(void) {
	printf("What would you like to do?\n");
	printf("  1. Read switches state.\n");
	printf("  2. Write led state.\n");
	printf("  3. Exit.\n");
	printf("Please input valid number ... \n");

	const char ch = get_first_char();

	switch (ch) {
	case '1':
		state = SWITCHES_READ;
		break;
	case '2':
		state = LEDS_WRITE;
		break;
	case '3':
		state = EXIT;
		break;
	}
}

static void switches_read(void) {
	struct timespec start, end;
	int err = clock_gettime(CLOCK_MONOTONIC, &start);
	if (err)
		panic_errno("can't get start time");

	uint32_t switches;
	const size_t n = read(dev_fd, &switches, 4);
	if (n != 4)
		panic("reading switches state failed");

	err = clock_gettime(CLOCK_MONOTONIC, &end);
	if (err)
		panic_errno("can't get end time");

	const long s = end.tv_sec - start.tv_sec;
	const long ns = end.tv_nsec - start.tv_nsec;
	const long us = s * 1000000 + ns / 1000;

	info("read took %ld us", us);

	printf("switches state: 0x%" PRIx32 "\n", switches);

	state = ACTION_PROMPT;
}

static void leds_write(void) {
	printf("Please provide new leds state (uint32_t) ...\n");

	uint32_t leds;
	int err = get_uint32(&leds);
	if (err) {
		error("provided invalid uint32_t literal");
		goto quit;
	}

	struct timespec start, end;
	err = clock_gettime(CLOCK_MONOTONIC, &start);
	if (err)
		panic_errno("can't get start time");

	// TODO: Implement write here.

	err = clock_gettime(CLOCK_MONOTONIC, &end);
	if (err)
		panic_errno("can't get end time");

	const long s = end.tv_sec - start.tv_sec;
	const long ns = end.tv_nsec - start.tv_nsec;
	const long us = s * 1000000 + ns / 1000;

	info("write took %ld us", us);

quit:
	state = ACTION_PROMPT;
}

int main(int, char **) {
	dev_fd = open("/dev/ex-gpio", O_RDWR);
	if (dev_fd < 0)
		panic("cannot open device file");

	while (1) {
		switch (state) {
		case ACTION_PROMPT:
			action_prompt();
			break;
		case SWITCHES_READ:
			switches_read();
			break;
		case LEDS_WRITE:
			leds_write();
			break;
		case EXIT:
			exit(0);
		default:
			panic("invalid state %d", state);
		}
	}

	close(dev_fd);

	return 0;
}
