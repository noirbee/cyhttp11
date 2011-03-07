#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.67])
AC_INIT([cyhttp11], [0.1.0~dev], [nicolas@noirbent.fr])

AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([foreign])

# Checks for programs.
AC_PROG_CC
AC_PROG_LIBTOOL
AM_PATH_PYTHON
AC_PYTHON_DEVEL([>= 2.5])
CYTHON_CHECK_VERSION([0.14.1])

# Checks for libraries.

# Checks for header files.
AC_CHECK_HEADERS([stdlib.h string.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_SIZE_T

# Checks for library functions.
AC_CHECK_FUNCS([strtol])

AC_OUTPUT([Makefile])
