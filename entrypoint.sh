#!/bin/bash
set -e

chown -R openclaw:openclaw /data
chmod 700 /data

if [ ! -d /data/.linuxbrew ]; then
  cp -a /home/linuxbrew/.linuxbrew /data/.linuxbrew
fi

rm -rf /home/linuxbrew/.linuxbrew
ln -sfn /data/.linuxbrew /home/linuxbrew/.linuxbrew

# PostgreSQL setup
PG_VERSION=15
PGDATA=/data/pgdata

if [ ! -f "$PGDATA/PG_VERSION" ]; then
  mkdir -p "$PGDATA"
  chown postgres:postgres "$PGDATA"
  gosu postgres /usr/lib/postgresql/$PG_VERSION/bin/initdb -D "$PGDATA" --encoding=UTF8 --locale=C
fi

gosu postgres /usr/lib/postgresql/$PG_VERSION/bin/pg_ctl start -D "$PGDATA" -l /data/pg.log -w -t 30

# Create honcho db/user if not exists
gosu postgres psql -c "CREATE DATABASE honcho;" 2>/dev/null || true
gosu postgres psql -c "CREATE USER honcho WITH PASSWORD 'honcho';" 2>/dev/null || true
gosu postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE honcho TO honcho;" 2>/dev/null || true

exec gosu openclaw node src/server.js
