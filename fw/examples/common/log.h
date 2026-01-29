// SPDX-License-Identifier: MIT
// https://github.com/m-kru/c-log
// Copyright (c) 2023 Michał Kruszewski

#ifndef _LOG_H_
#define _LOG_H_

#include <stdio.h>

/*
 * The log_time struct is used to obtain a string that shall be print
 * when LOG_TIME macro is defined.
 * The string is wrapped in the structure because of 2 resons:
 *   1. To avoid allocation on the heap.
 *   2. To have clear data ownership situation.
 *
 * The str buffer has fixed size of 32 bytes. It is enough to express timestamp
 * composed of : hour, minute, second, nanosecond, day, month and year.
 * Example: "23:59:59,999999999 1 Sep 2024\0" - 30 bytes.
 * The string placed in the returned str buffer must be terminated with \0.
 */
struct log_time {
	char str[32];
};

/*
 * The log_time() function is used to obtain a string for the time when
 * LOG_TIME macro is defined. It is the user's responsibility to provide
 * implementation of this function. The recommended way is to have separate
 * file named log_time.c with the code related only with the implementation
 * of the log_time() function.
 */
struct log_time log_time(void);

#ifndef LOG_STREAM
	#define LOG_STREAM stderr
#endif

#ifndef LOG_PREFIX
	#define LOG_PREFIX
#endif

#ifdef LOG_TIME
	#define _LOG_TIME log_time()
#else
	#define _LOG_TIME {""}
#endif

#ifndef LOG_LEVEL
	#define LOG_LEVEL 3
#endif

/*
 * Define LOG_COLOR if you want the ERR, WRN, INF, DBG, and TRC abbreviations
 * to be printed in color.
 *
 * If for some reason the default colors don't suit you, for example of your
 * terminal color theme, simply modify below color macros. Here is a short
 * list with escape sequences for different colors:
 *   Black        "\x1b[30m"
 *   Bright Black "\x1b[90m"
 *   Red          "\x1b[31m"
 *   Green        "\x1b[32m"
 *   Yellow       "\x1b[33m"
 *   Blue         "\x1b[34m"
 *   Magenta      "\x1b[35m"
 *   Cyan         "\x1b[36m"
 *   White        "\x1b[37m"
 */
#ifdef LOG_COLOR
	#define LOG_COLOR_ERR       "\x1b[31m"
	#define LOG_COLOR_WRN       "\x1b[33m"
	#define LOG_COLOR_INF       "\x1b[32m"
	#define LOG_COLOR_DBG       "\x1b[34m"
	#define LOG_COLOR_TRC       "\x1b[36m"
	#define LOG_COLOR_TIME      "\x1b[90m"
	#define LOG_COLOR_FILE_LINE "\x1b[90m"
	#define LOG_COLOR_RESET     "\x1b[0m"
#else
	#define LOG_COLOR_ERR       ""
	#define LOG_COLOR_WRN       ""
	#define LOG_COLOR_INF       ""
	#define LOG_COLOR_DBG       ""
	#define LOG_COLOR_TRC       ""
	#define LOG_COLOR_TIME      ""
	#define LOG_COLOR_FILE_LINE ""
	#define LOG_COLOR_RESET     ""
#endif

#ifdef LOG_SOURCE
	#ifdef LOG_TIME
		#define _log_error(fmt, ...) do {                            \
			const struct log_time time = _LOG_TIME;              \
			fprintf(                                             \
				LOG_STREAM,                                  \
				LOG_COLOR_TIME "%s"                          \
				LOG_COLOR_ERR "ERR "                         \
				LOG_COLOR_FILE_LINE "%s:%d " LOG_COLOR_RESET \
				LOG_PREFIX fmt "\n",                         \
				time.str, __FILE__, __LINE__, ## __VA_ARGS__ \
			);                                                   \
		} while (0)
		#define _log_warn(fmt, ...) do {                             \
			const struct log_time time = _LOG_TIME;              \
			fprintf(                                             \
				LOG_STREAM,                                  \
				LOG_COLOR_TIME "%s"                          \
				LOG_COLOR_WRN "WRN "                         \
				LOG_COLOR_FILE_LINE "%s:%d " LOG_COLOR_RESET \
				LOG_PREFIX fmt "\n",                         \
				time.str, __FILE__, __LINE__, ## __VA_ARGS__ \
			);                                                   \
		} while (0)
		#define _log_info(fmt, ...) do {                             \
			const struct log_time time = _LOG_TIME;              \
			fprintf(                                             \
				LOG_STREAM,                                  \
				LOG_COLOR_TIME "%s"                          \
				LOG_COLOR_INF "INF "                         \
				LOG_COLOR_FILE_LINE "%s:%d " LOG_COLOR_RESET \
				LOG_PREFIX fmt "\n",                         \
				time.str, __FILE__, __LINE__, ## __VA_ARGS__ \
			);                                               \
		} while (0)
		#define _log_debug(fmt, ...) do {                            \
			const struct log_time time = _LOG_TIME;              \
			fprintf(                                             \
				LOG_STREAM,                                  \
				LOG_COLOR_TIME "%s"                          \
				LOG_COLOR_DBG "DBG "                         \
				LOG_COLOR_FILE_LINE "%s:%d " LOG_COLOR_RESET \
				LOG_PREFIX fmt "\n",                         \
				time.str, __FILE__, __LINE__, ## __VA_ARGS__ \
			);                                               \
		} while (0)
		#define _log_trace(fmt, ...) do {                            \
			const struct log_time time = _LOG_TIME;              \
			fprintf(                                             \
				LOG_STREAM,                                  \
				LOG_COLOR_TIME "%s"                          \
				LOG_COLOR_TRC "TRC "                         \
				LOG_COLOR_FILE_LINE "%s:%d " LOG_COLOR_RESET \
				LOG_PREFIX fmt "\n",                         \
				time.str, __FILE__, __LINE__, ## __VA_ARGS__ \
			);                                                   \
		} while (0)
	#else
		#define _log_error(fmt, ...) do {                    \
			fprintf(                                     \
				LOG_STREAM,                          \
				LOG_COLOR_ERR "ERR " LOG_COLOR_RESET \
				"%s:%d "                             \
				LOG_PREFIX fmt "\n",                 \
				__FILE__, __LINE__, ## __VA_ARGS__   \
			);                                           \
		} while (0)
		#define _log_warn(fmt, ...) do {                     \
			fprintf(                                     \
				LOG_STREAM,                          \
				LOG_COLOR_WRN "WRN " LOG_COLOR_RESET \
				"%s:%d "                             \
				LOG_PREFIX fmt "\n",                 \
				__FILE__, __LINE__, ## __VA_ARGS__   \
			);                                           \
		} while (0)
		#define _log_info(fmt, ...) do {                     \
			fprintf(                                     \
				LOG_STREAM,                          \
				LOG_COLOR_INF "INF " LOG_COLOR_RESET \
				"%s:%d "                             \
				LOG_PREFIX fmt "\n",                 \
				__FILE__, __LINE__, ## __VA_ARGS__   \
			);                                           \
		} while (0)
		#define _log_debug(fmt, ...) do {                    \
			fprintf(                                     \
				LOG_STREAM,                          \
				LOG_COLOR_DBG "DBG " LOG_COLOR_RESET \
				"%s:%d "                             \
				LOG_PREFIX fmt "\n",                 \
				__FILE__, __LINE__, ## __VA_ARGS__   \
			);                                           \
		} while (0)
		#define _log_trace(fmt, ...) do {                    \
			fprintf(                                     \
				LOG_STREAM,                          \
				LOG_COLOR_TRC "TRC " LOG_COLOR_RESET \
				"%s:%d "                             \
				LOG_PREFIX fmt "\n",                 \
				__FILE__, __LINE__, ## __VA_ARGS__   \
			);                                           \
		} while (0)
	#endif
#else
	#ifdef LOG_TIME
		#define _log_error(fmt, ...) do {                    \
			const struct log_time time = _LOG_TIME;      \
			fprintf(                                     \
				LOG_STREAM,                          \
				LOG_COLOR_TIME "%s"                  \
				LOG_COLOR_ERR "ERR " LOG_COLOR_RESET \
				LOG_PREFIX fmt "\n",                 \
				time.str, ## __VA_ARGS__             \
			);                                           \
		} while (0)
		#define _log_warn(fmt, ...) do {                     \
			const struct log_time time = _LOG_TIME;      \
			fprintf(                                     \
				LOG_STREAM,                          \
				LOG_COLOR_TIME "%s"                  \
				LOG_COLOR_WRN "WRN " LOG_COLOR_RESET \
				LOG_PREFIX fmt "\n",                 \
				time.str, ## __VA_ARGS__             \
			);                                           \
		} while (0)
		#define _log_info(fmt, ...) do {                     \
			const struct log_time time = _LOG_TIME;      \
			fprintf(                                     \
				LOG_STREAM,                          \
				LOG_COLOR_TIME "%s"                  \
				LOG_COLOR_INF "INF " LOG_COLOR_RESET \
				LOG_PREFIX fmt "\n",                 \
				time.str, ## __VA_ARGS__             \
			);                                           \
		} while (0)
		#define _log_debug(fmt, ...) do {                    \
			const struct log_time time = _LOG_TIME;      \
			fprintf(                                     \
				LOG_STREAM,                          \
				LOG_COLOR_TIME "%s"                  \
				LOG_COLOR_DBG "DBG " LOG_COLOR_RESET \
				LOG_PREFIX fmt "\n",                 \
				time.str, ## __VA_ARGS__             \
			);                                           \
		} while (0)
		#define _log_trace(fmt, ...) do {                    \
			const struct log_time time = _LOG_TIME;      \
			fprintf(                                     \
				LOG_STREAM,                          \
				LOG_COLOR_TIME "%s"                  \
				LOG_COLOR_TRC "TRC " LOG_COLOR_RESET \
				LOG_PREFIX fmt "\n",                 \
				time.str, ## __VA_ARGS__             \
			);                                           \
		} while (0)
	#else
		#define _log_error(fmt, ...) do {                    \
			fprintf(                                     \
				LOG_STREAM,                          \
				LOG_COLOR_ERR "ERR " LOG_COLOR_RESET \
				LOG_PREFIX fmt "\n",                 \
				## __VA_ARGS__                       \
			);                                           \
		} while (0)
		#define _log_warn(fmt, ...) do {                     \
			fprintf(                                     \
				LOG_STREAM,                          \
				LOG_COLOR_WRN "WRN " LOG_COLOR_RESET \
				LOG_PREFIX fmt "\n",                 \
				## __VA_ARGS__                       \
			);                                           \
		} while (0)
		#define _log_info(fmt, ...) do {                     \
			fprintf(                                     \
				LOG_STREAM,                          \
				LOG_COLOR_INF "INF " LOG_COLOR_RESET \
				LOG_PREFIX fmt "\n",                 \
				## __VA_ARGS__                       \
			);                                           \
		} while (0)
		#define _log_debug(fmt, ...) do {                    \
			fprintf(                                     \
				LOG_STREAM,                          \
				LOG_COLOR_DBG "DBG " LOG_COLOR_RESET \
				LOG_PREFIX fmt "\n",                 \
				## __VA_ARGS__                       \
			);                                           \
		} while (0)
		#define _log_trace(fmt, ...) do {                    \
			fprintf(                                     \
				LOG_STREAM,                          \
				LOG_COLOR_TRC "TRC " LOG_COLOR_RESET \
				LOG_PREFIX fmt "\n",                 \
				## __VA_ARGS__                       \
			);                                           \
		} while (0)
	#endif
#endif

#if LOG_LEVEL == 0
	#define error(...)
	#define warn(...)
	#define info(...)
	#define debug(...)
	#define trace(...)
#elif LOG_LEVEL == 1
	#define error _log_error
	#define warn(...)
	#define info(...)
	#define debug(...)
	#define trace(...)
#elif LOG_LEVEL == 2
	#define error _log_error
	#define warn  _log_warn
	#define info(...)
	#define debug(...)
	#define trace(...)
#elif LOG_LEVEL == 3
	#define error _log_error
	#define warn  _log_warn
	#define info  _log_info
	#define debug(...)
	#define trace(...)
#elif LOG_LEVEL == 4
	#define error _log_error
	#define warn  _log_warn
	#define info  _log_info
	#define debug _log_debug
	#define trace(...)
#elif LOG_LEVEL == 5
	#define error _log_error
	#define warn  _log_warn
	#define info  _log_info
	#define debug _log_debug
	#define trace _log_trace
#else
	#error "Invalid LOG_LEVEL, valid log levels are:\
 0 - no logs,\
 1 - only error,\
 2 - error and warn\
 3 - error, warn and info\
 4 - error, warn, info and debug\
 5 - error, warn, info, debug and trace."
#endif

#endif // _LOG_H_
