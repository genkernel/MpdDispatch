/* libmpdclient
   (c) 2003-2010 The Music Player Daemon Project
   This project's homepage is: http://www.musicpd.org

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

   - Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

   - Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include <mpd/send.h>

#include "isend.h"
#include "internal.h"
#include "sync.h"

#include <stdarg.h>
#include <limits.h>
#include <stdio.h>

/* (bits+1)/3 (plus the sign character) */
enum {
	INTLEN = (sizeof(int) * CHAR_BIT + 1) / 3 + 1,
	LONGLONGLEN = (sizeof(long long) * CHAR_BIT + 1) / 3 + 1,
};

/**
 * Checks whether it is possible to send a command now.
 */
static bool
send_check(struct mpd_connection *connection)
{
	assert(connection != NULL);

	if (mpd_error_is_defined(&connection->error))
		return false;

	if (connection->receiving) {
		mpd_error_code(&connection->error, MPD_ERROR_STATE);
		mpd_error_message(&connection->error,
				  "Cannot send a new command while "
				  "receiving another response");
		return false;
	}

	return true;
}

bool
mpd_send_command(struct mpd_connection *connection, const char *command, ...)
{
	va_list ap;
	bool success;

	if (!send_check(connection))
		return false;

	va_start(ap, command);

	success = mpd_sync_send_command_v(connection->async,
					  mpd_connection_timeout(connection),
					  command, ap);

	va_end(ap);

	if (!success) {
		mpd_connection_sync_error(connection);
		return false;
	}

	if (!connection->sending_command_list) {
		/* the caller might expect that we have flushed the
		   output buffer when this function returns */
		if (!mpd_flush(connection))
			return false;

		connection->receiving = true;
	} else if (connection->sending_command_list_ok)
		++connection->command_list_remaining;

	return true;
}

bool
mpd_send_command2(struct mpd_connection *connection, const char *command)
{
	bool success;

	if (!send_check(connection))
		return false;

	success = mpd_sync_send_command(connection->async,
					mpd_connection_timeout(connection),
					command, NULL);
	if (!success) {
		mpd_connection_sync_error(connection);
		return false;
	}

	return true;
}

bool
mpd_send_int_command(struct mpd_connection *connection, const char *command,
		     int arg)
{
	char arg_string[INTLEN];

	snprintf(arg_string, sizeof(arg_string), "%i", arg);
	return mpd_send_command(connection, command, arg_string, NULL);
}

bool
mpd_send_int2_command(struct mpd_connection *connection, const char *command,
		      int arg1, int arg2)
{
	char arg1_string[INTLEN], arg2_string[INTLEN];

	snprintf(arg1_string, sizeof(arg1_string), "%i", arg1);
	snprintf(arg2_string, sizeof(arg2_string), "%i", arg2);
	return mpd_send_command(connection, command,
				arg1_string, arg2_string, NULL);
}

bool
mpd_send_int3_command(struct mpd_connection *connection, const char *command,
		      int arg1, int arg2, int arg3)
{
	char arg1_string[INTLEN], arg2_string[INTLEN], arg3_string[INTLEN];

	snprintf(arg1_string, sizeof(arg1_string), "%i", arg1);
	snprintf(arg2_string, sizeof(arg2_string), "%i", arg2);
	snprintf(arg3_string, sizeof(arg3_string), "%i", arg3);
	return mpd_send_command(connection, command,
				arg1_string, arg2_string, arg3_string, NULL);
}

bool
mpd_send_float_command(struct mpd_connection *connection, const char *command,
		       float arg)
{
	char arg_string[INTLEN];

	snprintf(arg_string, sizeof(arg_string), "%f", arg);
	return mpd_send_command(connection, command, arg_string, NULL);
}

bool
mpd_send_s_u_command(struct mpd_connection *connection, const char *command,
		     const char *arg1, unsigned arg2)
{
	char arg2_string[INTLEN];

	snprintf(arg2_string, sizeof(arg2_string), "%u", arg2);
	return mpd_send_command(connection, command,
				arg1, arg2_string, NULL);
}

bool
mpd_send_range_command(struct mpd_connection *connection, const char *command,
                       unsigned arg1, unsigned arg2)
{
	char arg_string[INTLEN*2+1];

	snprintf(arg_string, sizeof arg_string, "%u:%u", arg1, arg2);
	return mpd_send_command(connection, command, arg_string, NULL);
}

bool
mpd_send_range_u_command(struct mpd_connection *connection,
			 const char *command,
			 unsigned start, unsigned end, unsigned arg2)
{
	char arg1_string[INTLEN*2+1], arg2_string[INTLEN];

	snprintf(arg1_string, sizeof arg1_string, "%u:%u", start, end);
	snprintf(arg2_string, sizeof(arg2_string), "%i", arg2);
	return mpd_send_command(connection, command,
				arg1_string, arg2_string, NULL);
}

bool
mpd_send_ll_command(struct mpd_connection *connection, const char *command,
		    long long arg)
{
	char arg_string[LONGLONGLEN];

#ifdef WIN32
	snprintf(arg_string, sizeof(arg_string), "%ld", (long)arg);
#else
	snprintf(arg_string, sizeof(arg_string), "%lld", arg);
#endif
	return mpd_send_command(connection, command, arg_string, NULL);
}

bool
mpd_flush(struct mpd_connection *connection)
{
	if (!mpd_sync_flush(connection->async,
			    mpd_connection_timeout(connection))) {
		mpd_connection_sync_error(connection);
		return false;
	}

	return true;
}
