#! /usr/bin/python
# -*- coding: utf-8 -*-

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

ext_modules = [Extension('cyhttp11', ['cyhttp11.pyx', 'cyhttp11.pxd',
                                      'http11_parser.c', 'httpclient_parser.c'])]

setup(
    name = 'cyhttp11',
    description = "Cython binding to Mongrel's http11 parser",
    cmdclass = {'build_ext': build_ext},
    ext_modules = ext_modules,
)
