#!/bin/bash
# Renderoi PokeStock-demovideon: puhdas valiaikainen MySQL + vhs
set -e
V=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$V/.." && pwd)
B=/usr/local/mysql/bin
D=$(mktemp -d); S=$(mktemp -d)
pkill -f "datadir=$S/data" 2>/dev/null || true; sleep 1
rm -rf "$D" "$S"; mkdir -p "$D" "$S/data"
cp -r "$REPO/database" "$D/"; cp "$V/alustus.sh" "$V/rivimaarat.sql" "$D/"
$B/mysqld --no-defaults --initialize-insecure --datadir=$S/data --basedir=/usr/local/mysql >/dev/null 2>&1
$B/mysqld --no-defaults --datadir=$S/data --basedir=/usr/local/mysql --socket=$S/sock --port=3398 --mysqlx=OFF --pid-file=$S/pid >$S/log 2>&1 &
for i in $(seq 30); do [ -S $S/sock ] && break; sleep 1; done
cd "$D"
python3 "$V/tee_tape.py" "$REPO" "$HOME/Videos/pokestock_demo.mp4"
DEMO_SOCK=$S/sock vhs "$HOME/Videos/pokestock_demo.tape"
kill "$(cat $S/pid)"
ffprobe -v error -show_entries format=duration -of csv=p=0 "$HOME/Videos/pokestock_demo.mp4"
