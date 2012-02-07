/**
 *
 * Copyright (c) 2010, Zed A. Shaw and Mongrel2 Project Contributors.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *
 *     * Neither the name of the Mongrel2 Project, Zed A. Shaw, nor the names
 *       of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written
 *       permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "httpclient_parser.h"
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#define LEN(AT, FPC) (FPC - buffer - parser->AT)
#define MARK(M,FPC) (parser->M = (FPC) - buffer)
#define PTR_TO(F) (buffer + parser->F)


/** machine **/
%%{
    machine httpclient_parser;

    include http_parser_common "http11_common.rl";

    action reason_phrase {
        if(parser->reason_phrase != NULL)
            parser->reason_phrase(parser->data, PTR_TO(mark), LEN(mark, fpc));
    }

    action status_code {
        parser->status = strtol(PTR_TO(mark), NULL, 10);

        if(parser->status_code != NULL)
            parser->status_code(parser->data, PTR_TO(mark), LEN(mark, fpc));
    }

    Reason_Phrase = (any -- CRLF)+ >mark %reason_phrase;
    Status_Code = digit+ >mark %status_code;

    Status_Line = HTTP_Version " " Status_Code " " Reason_Phrase :> CRLF;

    Response = 	Status_Line (message_header)* (CRLF @done);

main := Response;

}%%

/** Data **/
%% write data;

int httpclient_parser_init(httpclient_parser *parser)  {
  int cs = 0;

  %% write init;

  parser->cs = cs;
  parser->body_start = 0;
  parser->mark = 0;
  parser->nread = 0;
  parser->field_len = 0;
  parser->field_start = 0;

  return(1);
}


/** exec **/
ssize_t httpclient_parser_execute(httpclient_parser *parser, const char *buffer, size_t len, size_t off)
{
  if(len == 0) return 0;

  const char *p, *pe;
  int cs = parser->cs;

  if(off > len)
    return -ERR_OFFSET_PAST_BUFFER;

  p = buffer+off;
  pe = buffer+len;

  %% write exec;

  if(p > pe)
    return -ERR_OVERFLOW_AFTER_PARSE;

  if (!httpclient_parser_has_error(parser)) {
      parser->cs = cs;
  }

  parser->nread += p - (buffer + off);

  if(parser->nread > len)
    return -ERR_NREAD_OVERFLOW;
  if(parser->body_start > len)
    return -ERR_BODY_OVERFLOW;
  if(parser->mark >= len)
    return -ERR_MARK_OVERFLOW;
  if(parser->field_len > len)
    return -ERR_FIELD_LEN_OVERFLOW;
  if(parser->field_start >= len)
    return -ERR_FIELD_START_OVERFLOW;

  return(parser->nread);
}

int httpclient_parser_finish(httpclient_parser *parser)
{
  if (httpclient_parser_has_error(parser) ) {
    return -1;
  } else if (httpclient_parser_is_finished(parser) ) {
    return 1;
  } else {
    return 0;
  }
}

int httpclient_parser_has_error(httpclient_parser *parser) {
  return parser->cs == httpclient_parser_error;
}

int httpclient_parser_is_finished(httpclient_parser *parser) {
  return parser->cs >= httpclient_parser_first_final;
}
