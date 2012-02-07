#ifndef _http11_common_h
#define _http11_common_h

#include <sys/types.h>

typedef void (*element_cb)(void *data, const char *at, size_t length);
typedef void (*field_cb)(void *data, const char *field, size_t flen, const char *value, size_t vlen);

enum cyhttp_errors {
    ERR_OFFSET_PAST_BUFFER = 1,
    ERR_OVERFLOW_AFTER_PARSE,
    ERR_NREAD_OVERFLOW,
    ERR_BODY_OVERFLOW,
    ERR_MARK_OVERFLOW,
    ERR_FIELD_LEN_OVERFLOW,
    ERR_FIELD_START_OVERFLOW
};
#endif
