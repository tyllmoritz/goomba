#!/bin/sh
rm GBABIN/*.o
rm *.lst
for f in *.c; do rm "${f%c}s"; done &>/dev/null
rm minilzo.s
