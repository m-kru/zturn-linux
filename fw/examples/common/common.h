#ifndef _COMMON_H_
#define _COMMON_H_

#include <stdint.h>

// Read line from stdin.
// In case of any errors returns NULL.
// XXX: User is responsible for freeing the buffer.
char *get_line(size_t *size);

// Reads line from stdin and returns first char.
// In case of any errors 0 is returned.
char get_first_char(void);

// Reads uint32_t from stdin line, in case of any error returns 1.
int get_uint32(uint32_t *u32);

#endif // _COMMON_H_
