#include <errno.h>
#include <inttypes.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdint.h>
#include <sys/mman.h>
#include <time.h>
#include <unistd.h>

#include "common/common.h"
#include "common/log.h"
#include "common/panic.h"

#include "afbd/afbd.h"
#include "afbd/main.h"
#include "afbd/linux-mmap-iface.h"

#define AFBD_IFACE &afbd_iface
afbd_iface_t afbd_iface;

#define MAP_SIZE (4 * AFBD_main_OWN_ALIGNED_SIZE)

int uio_fd;

typedef enum {
	ACTION_PROMPT,
	ID_READ,
	TEST_WRITE,
	TEST_READ,
	EXIT,
} state_t;

static state_t state = ACTION_PROMPT;

static void action_prompt(void)
{
	printf("What would you like to do?\n");
	printf("  1. Read ID.\n");
	printf("  2. Test write.\n");
	printf("  3. Test read.\n");
	printf("  4. Exit.\n");
	printf("Please input valid number ... \n");

	const char ch = get_first_char();

	switch (ch) {
	case '1':
		state = ID_READ;
		break;
	case '2':
		state = TEST_WRITE;
		break;
	case '3':
		state = TEST_READ;
		break;
	case '4':
		state = EXIT;
		break;
	}
}

static void id_read(void)
{
	struct timespec start, end;
	int err = clock_gettime(CLOCK_MONOTONIC, &start);
	if (err)
		panic_errno("can't get start time");

	uint32_t id;
	err = afbd_read(main_ID, &id);
	if (err)
		panic("reading id failed");

	err = clock_gettime(CLOCK_MONOTONIC, &end);
	if (err)
		panic_errno("can't get end time");

	const long s = end.tv_sec - start.tv_sec;
	const long ns = s * 1000000000 + (end.tv_nsec - start.tv_nsec);

	info("read took %ld ns", ns);

	printf("got id: 0x%" PRIx32 ", want id: 0x%" PRIx32 "\n", id, afbd_main_ID);

	state = ACTION_PROMPT;
}

static void test_write(void)
{
	printf("Please provide value to write (uint32_t) ...\n");

	uint32_t val;
	int err = get_uint32(&val);
	if (err) {
		error("provided invalid uint32_t literal");
		goto quit;
	}

	struct timespec start, end;
	err = clock_gettime(CLOCK_MONOTONIC, &start);
	if (err)
		panic_errno("can't get start time");

	afbd_write(main_write_read_test, val);

	err = clock_gettime(CLOCK_MONOTONIC, &end);
	if (err)
		panic_errno("can't get end time");

	const long s = end.tv_sec - start.tv_sec;
	const long ns = s * 1000000000 + (end.tv_nsec - start.tv_nsec);

	info("write took %ld ns", ns);

quit:
	state = ACTION_PROMPT;
}

static void test_read(void)
{
	struct timespec start, end;
	int err = clock_gettime(CLOCK_MONOTONIC, &start);
	if (err)
		panic_errno("can't get start time");

	uint32_t val;
	err = afbd_read(main_write_read_test, &val);
	if (err)
		panic("reading write read test reg failed");

	err = clock_gettime(CLOCK_MONOTONIC, &end);
	if (err)
		panic_errno("can't get end time");

	const long s = end.tv_sec - start.tv_sec;
	const long ns = s * 1000000000 + (end.tv_nsec - start.tv_nsec);

	info("read took %ld ns", ns);

	printf("read: %" PRIu32 "\n", val);

	state = ACTION_PROMPT;
}

int main(int, char**)
{
	uio_fd = open("/dev/uio0", O_RDWR);
	if (uio_fd < 0)
		panic("can't open uio device");

	void *map = mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, uio_fd, 0);
	if (map == MAP_FAILED)
		panic("can't map memory");

	afbd_iface = afbd_linux_mmap_iface(map);

	while (1) {
		switch (state) {
		case ACTION_PROMPT:
			action_prompt();
			break;
		case ID_READ:
			id_read();
			break;
		case TEST_WRITE:
			test_write();
			break;
		case TEST_READ:
			test_read();
			break;
		case EXIT:
			exit(0);
		default:
			panic("invalid state %d", state);
		}
	}


	munmap(map, MAP_SIZE);
	close(uio_fd);
	return 0;
}
