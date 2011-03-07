ACLOCAL_AMFLAGS = -I m4

pyexec_LTLIBRARIES = cyhttp11.la
cyhttp11_la_SOURCES = http11_parser.h httpclient_parser.h http11_common.h
cyhttp11_la_CPPFLAGS = ${AM_CPPFLAGS} ${PYTHON_CPPFLAGS}
cyhttp11_la_CFLAGS = ${AM_CFLAGS} -fno-strict-aliasing
cyhttp11_la_LDFLAGS = -avoid-version -module

nodist_cyhttp11_la_SOURCES = cyhttp11.c http11_parser.c httpclient_parser.c

EXTRA_DIST = LICENSE LICENSE.mongrel2 README.rst \
	cyhttp11.pyx cyhttp11.pxd http11_parser.rl httpclient_parser.rl http11_common.rl \
	${BUILT_SOURCES}

BUILT_SOURCES = cyhttp11.c http11_parser.c httpclient_parser.c
CLEANFILES = cyhttp11.c http11_parser.c httpclient_parser.c

.rl.c: Makefile $<
	ragel -G2 -C $< -o $@

cyhttp11.c: Makefile cyhttp11.pyx cyhttp11.pxd
	cython --verbose cyhttp11.pyx
