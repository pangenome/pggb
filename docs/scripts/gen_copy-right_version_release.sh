#!/bin/bash

VERSION_LINE_NMBR=$(grep -n "version =" conf.py | cut -f1 -d :)
RELEASE_LINE_NMBR=$(grep -n "release =" conf.py | cut -f1 -d :)
COPYRIGHT_LINE_NMBR=$(grep -n "copyright =" conf.py | cut -f1 -d :)

TAG=$(git tag | tail -n 1)
COMMIT=$(git describe --always)

sed -i ""$VERSION_LINE_NMBR"s/.*/version = '"$TAG"'/" conf.py
sed -i ""$RELEASE_LINE_NMBR"s/.*/release = '"$COMMIT"'/" conf.py
sed -i ""$COPYRIGHT_LINE_NMBR"s/.*/copyright = '2022, Erik Garrison, .... Revision "$TAG"-"$COMMIT"'/" conf.py
