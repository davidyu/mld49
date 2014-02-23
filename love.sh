#!/bin/sh

SRC=src
ART_SRC=src/art/src
MAP_OUT=src/art/levels

CUR=$(pwd)
zip -r automaton.love ${CUR}/${SRC}/*
