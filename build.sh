#!/bin/sh

GIT_ROOT=$(git rev-parse --show-toplevel)
BB_ROOT="$HOME/Program files/Atari2600/bB"

cd "$GIT_ROOT/bin"
rm *

sh "$BB_ROOT/2600basic.sh" ../shiroge.bas

mv ../shiroge.bas.* .

stella shiroge.bas.bin
