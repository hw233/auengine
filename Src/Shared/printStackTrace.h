#ifndef _PRINTSTACKTRACE_H
#define _PRINTSTACKTRACE_H

/**
 * Prints formatted call stack to the user defined buffer,
 * always terminating the buffer with 0.
 * Uses stack frame to find out the caller function address and
 * the map file to find out the function name.
 */
extern SERVER_DECL void printStackTrace(char* buffer, int bufferSize);
extern SERVER_DECL void printStackTrace();
extern SERVER_DECL void arcAssertFailed(const char* fname, int line, const char* expr);

#endif // _PRINTSTACKTRACE_H
