# -*- coding: utf-8 -*-

cimport cyhttp11

# The parser's callbacks
cdef void _http_field(void *data, char *field, size_t flen, char *value, size_t vlen):
    result = <object>data
    result.headers[field[:flen]] = value[:vlen]

cdef void _element_cb(void *data, char *attribute, char *at, size_t length):
    result = <object>data
    setattr(result, attribute, at[:length])

cdef void _request_method(void *data, char *at, size_t length):
    _element_cb(data, 'request_method', at, length)

cdef void _request_uri(void *data, char *at, size_t length):
    _element_cb(data, 'request_uri', at, length)

cdef void _fragment(void *data, char *at, size_t length):
    _element_cb(data, 'fragment', at, length)

cdef void _request_path(void *data, char *at, size_t length):
    _element_cb(data, 'request_path', at, length)

cdef void _query_string(void *data, char *at, size_t length):
    _element_cb(data, 'query_string', at, length)

cdef void _http_version(void *data, char *at, size_t length):
    _element_cb(data, 'http_version', at, length)

cdef void _header_done(void *data, char *at, size_t length):
    _element_cb(data, 'body', at, length)

cdef class HttpParser:
        """
        This is a docstring for this class.
        """
        cdef cyhttp11.http_parser _http_parser
        cdef public dict headers
        cdef public str request_method
        cdef public str request_uri
        cdef public str fragment
        cdef public str request_path
        cdef public str query_string
        cdef public str http_version
        cdef public str body

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
            return cyhttp11.http_parser_execute(&self._http_parser,
                                                 bytes,
                                                 len(bytes),
                                                 self._http_parser.nread)

        def is_finished(self):
            return cyhttp11.http_parser_is_finished(&self._http_parser)

        def has_error(self):
            return cyhttp11.http_parser_has_error(&self._http_parser)

        def reset(self):
            cyhttp11.http_parser_init(&self._http_parser)
            self.headers = {}
            self.request_method = ''
            self.request_uri = ''
            self.fragment = ''
            self.request_path = ''
            self.query_string = ''
            self.http_version = ''
            self.body = ''

