#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

#include "common.h"
#include "log.h"

char *get_line(size_t *size) {
	char *line = NULL;
	size_t len = 0;
	ssize_t n;

	n = getline(&line, &len, stdin);

	if (n == -1) {
		debug("getline failed");
		if (line != NULL)
			free(line);
		return NULL;
	}

	*size = n;
	return line;
}

char get_first_char(void) {
	size_t n;
	char *line = get_line(&n);
	if (line == NULL)
		return 0;

	const char ch = line[0];
	free(line);

	return ch;
}

int get_uint32(uint32_t *u32) {
	size_t n;
	char *line = get_line(&n);
	if (line == NULL)
		return 1;

	char *end;
	errno = 0;
	const unsigned long tmp = strtoul(line, &end, 0);

	if (errno != 0 || line == end) {
		free(line);
		return 1;
	}

	free(line);

	if (tmp > UINT32_MAX)
		return 1;

	*u32 = (uint32_t)tmp;

	return 0;
}
