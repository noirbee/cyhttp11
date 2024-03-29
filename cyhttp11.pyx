# -*- coding: utf-8 -*-

cimport cyhttp11

ctypedef Py_ssize_t ssize_t

class CyHTTPException(Exception):
    ERROR_STR = {
        ERR_OFFSET_PAST_BUFFER : "Offset past end of buffer",
        ERR_OVERFLOW_AFTER_PARSE : "Buffer overflow after parsing",
        ERR_NREAD_OVERFLOW : "nread longer than length",
        ERR_BODY_OVERFLOW : "Body starts after buffer end",
        ERR_MARK_OVERFLOW : "Mark is after buffer end",
        ERR_FIELD_LEN_OVERFLOW : "Field has length longer than whole buffer",
        ERR_FIELD_START_OVERFLOW : "Field starts after buffer end",
    }

    def __str__(self):
        return "CyHTTPException : %i %s" % (self.args[0], self.ERROR_STR[self.args[0]])

cdef class HTTPHeaders(dict):

    def __contains__(self, key):
        return dict.__contains__(self, key.title())

    def __getitem__(self, key):
        return dict.__getitem__(self, key.title())

    def __setitem__(self, key, value):
        dict.__setitem__(self, key.title(), value)

    def __delitem__(self, key):
        dict.__delitem__(self, key.title())


# The parser's callbacks
cdef void _http_field(void *data, char *field, size_t flen, char *value, size_t vlen):
    result = <object>data
    result.headers[field[:flen]] = value[:vlen]

cdef void _element_cb(void *data, char *attribute, char *at, size_t length):
    result = <object>data
    setattr(result, unicode(attribute), at[:length])

cdef void _request_method(void *data, char *at, size_t length):
    result = <object>data
    result.request_method = at[:length]

cdef void _request_uri(void *data, char *at, size_t length):
    result = <object>data
    result.request_uri = at[:length]

cdef void _fragment(void *data, char *at, size_t length):
    result = <object>data
    result.fragment = at[:length]

cdef void _request_path(void *data, char *at, size_t length):
    result = <object>data
    result.request_path = at[:length]

cdef void _query_string(void *data, char *at, size_t length):
    result = <object>data
    result.query_string = at[:length]

cdef void _status_code(void *data, char *at, size_t length):
    result = <object>data
    result.status_code = int(at[:length])

cdef void _reason_phrase(void *data, char *at, size_t length):
    result = <object>data
    result.reason_phrase = at[:length]

cdef void _http_version(void *data, char *at, size_t length):
    result = <object>data
    result.http_version = at[:length]

cdef void _header_done(void *data, char *at, size_t length):
    result = <object>data
    result.body = at[:length]

cdef class HTTPParser:
        """
        This is a docstring for this class.
        """
        cdef cyhttp11.http_parser _http_parser
        cdef public HTTPHeaders headers
        cdef public bytes request_method
        cdef public bytes request_uri
        cdef public bytes fragment
        cdef public bytes request_path
        cdef public bytes query_string
        cdef public bytes http_version
        cdef public bytes body

        def __cinit__(self):
            self._http_parser.data = <void*>self
            self._http_parser.http_field = <field_cb>_http_field
            self._http_parser.request_method = <element_cb>_request_method
            self._http_parser.request_uri = <element_cb>_request_uri
            self._http_parser.fragment = <element_cb>_fragment
            self._http_parser.request_path = <element_cb>_request_path
            self._http_parser.query_string = <element_cb>_query_string
            self._http_parser.http_version = <element_cb>_http_version
            self._http_parser.header_done = <element_cb>_header_done
            self.reset()

        def execute(self, bytes):
            ret = cyhttp11.http_parser_execute(&self._http_parser,
                                                 bytes,
                                                 len(bytes),
                                                 self._http_parser.nread)
            if ret < 0:
                raise CyHTTPException(-ret)
            return ret

        def is_finished(self):
            return cyhttp11.http_parser_is_finished(&self._http_parser)

        def has_error(self):
            return cyhttp11.http_parser_has_error(&self._http_parser)

        def reset(self):
            cyhttp11.http_parser_init(&self._http_parser)
            self.headers = HTTPHeaders()
            self.request_method = b''
            self.request_uri = b''
            self.fragment = b''
            self.request_path = b''
            self.query_string = b''
            self.http_version = b''
            self.body = b''

cdef class HTTPClientParser:
        """
        This is a docstring for this class.
        """
        cdef cyhttp11.httpclient_parser _httpclient_parser
        cdef public HTTPHeaders headers
        cdef public int status_code
        cdef public bytes reason_phrase
        cdef public bytes http_version
        cdef public bytes body

        def __cinit__(self):
            self._httpclient_parser.data = <void*>self
            self._httpclient_parser.http_field = <field_cb>_http_field
            self._httpclient_parser.status_code = <element_cb>_status_code
            self._httpclient_parser.reason_phrase = <element_cb>_reason_phrase

            self._httpclient_parser.http_version = <element_cb>_http_version
            self._httpclient_parser.header_done = <element_cb>_header_done
            self.reset()

        def execute(self, bytes):
            ret = cyhttp11.httpclient_parser_execute(&self._httpclient_parser,
                                                 bytes,
                                                 len(bytes),
                                                 self._httpclient_parser.nread)
            if ret < 0:
                raise CyHTTPException(-ret)
            return ret

        def is_finished(self):
            return cyhttp11.httpclient_parser_is_finished(&self._httpclient_parser)

        def has_error(self):
            return cyhttp11.httpclient_parser_has_error(&self._httpclient_parser)

        def reset(self):
            cyhttp11.httpclient_parser_init(&self._httpclient_parser)
            self.headers = HTTPHeaders()
            self.status_code = -1
            self.reason_phrase = b''
            self.http_version = b''
            self.body = b''
