#!/bin/sh

SRC=src
ART_SRC=src/art/src
MAP_OUT=src/art/levels

CUR=$(pwd)
cd ${SRC}
zip -r automaton.love * -x art/src/*
cd ${CUR}
mv ${SRC}/automaton.love ${CUR}/
