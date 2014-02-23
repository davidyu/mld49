#!/bin/sh

SRC=./src
ART_SRC=./src/art/src
MAP_OUT=./src/art/levels

cp ${ART_SRC}/*.tmx ${SRC}
cd ${SRC}
tmxs=$(ls *.tmx)
for tmx in ${tmxs}
do
    tmx2lua ${tmx}
done
cd -
# copy all output (.lua) to MAP_OUT
for tmx in $(ls ${SRC}/*.tmx)
do
    # strip dir
    tmx=${tmx##*/}
    # remove tmx extension
    map_long=${tmx%\.*}
    # append lua extension
    out="${map_long}.lua"
    out_short="${map_long%_map}.lua"
    cp ${SRC}/${out} ${MAP_OUT}/${out_short}
    # remove map tmx and lua files
    rm ${SRC}/${tmx} ${SRC}/${out}
done
