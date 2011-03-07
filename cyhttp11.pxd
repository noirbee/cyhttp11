# -*- coding: utf-8 -*-

cdef extern from 'http11_common.h':

        ctypedef void (*element_cb)(void *data, char *at, size_t length)
        ctypedef void (*field_cb)(void *data, char *field, size_t flen, char *value, size_t vlen)

cdef extern from 'http11_parser.h':

        struct http_parser:
                # These are "private" http_parser declarations, we
                # should not need them.
                # int cs
                # size_t body_start
                # int content_len

                # This is the exception, we need it to support
                # hassle-free calls to execute()
                size_t nread

                # size_t mark
                # size_t field_start
                # size_t field_len
                # size_t query_start

                void *data

                field_cb http_field
                element_cb request_method
                element_cb request_uri
                element_cb fragment
                element_cb request_path
                element_cb query_string
                element_cb http_version
                element_cb header_done

        int http_parser_init(http_parser *parser)
        # I don't think we need this function
        # int http_parser_finish(http_parser *parser)
        size_t http_parser_execute(http_parser *parser, char *data, size_t len, size_t off)
        bint http_parser_has_error(http_parser *parser)
        bint http_parser_is_finished(http_parser *parser)

cdef extern from 'httpclient_parser.h':

        struct httpclient_parser:
                # These are "private" http_parser declarations, we
                # should not need them.
                # int cs
                # size_t body_start
                # int content_len

                # This is the exception, we need it to support
                # hassle-free calls to execute()
                size_t nread

                # size_t mark
                # size_t field_start
                # size_t field_len
                # size_t query_start

                void *data

                field_cb http_field
                element_cb reason_phrase
                element_cb status_code
                element_cb http_version
                element_cb header_done

        int httpclient_parser_init(httpclient_parser *parser)
        # I don't think we need this function
        # int httpclient_parser_finish(httpclient_parser *parser)
        size_t httpclient_parser_execute(httpclient_parser *parser, char *data, size_t len, size_t off)
        bint httpclient_parser_has_error(httpclient_parser *parser)
        bint httpclient_parser_is_finished(httpclient_parser *parser)

