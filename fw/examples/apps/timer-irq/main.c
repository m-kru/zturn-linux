#include <errno.h>
#include <fcntl.h>
#include <inttypes.h>
#include <poll.h>
#include <stdio.h>
#include <time.h>
#include <unistd.h>

#include <sys/eventfd.h>
#include <sys/ioctl.h>

#include "common/common.h"
#include "common/log.h"
#include "common/panic.h"

#define SET_EVENTFD _IOW('a', '1', int)

static int dev_fd;
static int efd;
static struct pollfd poll_fds[2];

int main(int, char **) {
	dev_fd = open("/dev/ex-timer-irq", O_RDWR);
	if (dev_fd < 0)
		panic("cannot open device file");

	efd = eventfd(0, EFD_NONBLOCK);
	if (efd == -1)
		panic_errno("can't create event file descriptor");

	// Pass the event fd to the kernel
	if (ioctl(dev_fd, SET_EVENTFD, &efd) < 0)
		panic_errno("calling ioctl failed");

	// Setup poll structures
	poll_fds[0].fd = STDIN_FILENO;
	poll_fds[0].events = POLLIN;
	poll_fds[1].fd = efd;
	poll_fds[1].events = POLLIN;

	printf("please provide counter period in ms, 0 means disable counter\n");
	printf("to exit, provide any uint32_t invalid literal\n");

	while (1) {
		// Block until one of the fds is ready
		int ret = poll(poll_fds, 2, -1);
		if (ret < 0)
			panic_errno("poll failed");

		// Check if stdin has data
		if (poll_fds[0].revents & POLLIN) {
			uint32_t period_in_ms;
			int err = get_uint32(&period_in_ms);
			if (err)
				break;

			const int n = write(dev_fd, &period_in_ms, 4);
			if (n != 4)
				panic("write to device failed");
		}

		// Check if eventfd has been signaled
		if (poll_fds[1].revents & POLLIN) {
			uint64_t cnt;
			const int n = read(efd, &cnt, sizeof(cnt));
			if (n < 0)
				panic("reading eventfd failed");
			printf("timer irq!, evetnfd count = %" PRIu64 "\n", cnt);
		}
	};

	close(dev_fd);

	return 0;
}
