#!/bin/bash -e

set -o pipefail

export PGHOST=${PGHOST:-$POSTGRES_PORT_5432_TCP_ADDR}
export PGPORT=${PGPORT:-$POSTGRES_PORT_5432_TCP_PORT}

: ${PGHOST:?"--link or hostname to a PostgreSQL container or server is not set"}
: ${PGPORT:?"--link or port to a PostgreSQL container or server is not set"}
: ${AWS_ACCESS_KEY_ID:?"AWS_ACCESS_KEY_ID not specified"}
: ${AWS_SECRET_ACCESS_KEY:?"AWS_SECRET_ACCESS_KEY not specified"}
: ${BUCKET:?"BUCKET not specified"}
: ${SYMMETRIC_PASSPHRASE:?"SYMMETRIC_PASSPHRASE not specified"}

export PGUSER=${PGUSER:-postgres}
XZ_COMPRESSION_LEVEL=${XZ_COMPRESSION_LEVEL:-9}
CIPHER_ALGO=${CIPHER_ALGO:-aes256}
GPG_COMPRESSION_LEVEL=${GPG_COMPRESSION_LEVEL:-0}
NAME_PREFIX=${NAME_PREFIX:-database-archive}
EXTENSION=${EXTENSION:-.psql.xz.gpg}
AWSCLI_OPTIONS=${AWSCLI_OPTIONS:---sse}
EXCLUDED_DATABASES=${EXCLUDED_DATABASES:-}

IFS=',' read -ra DBS <<< "$EXCLUDED_DATABASES"
PG_EXCLUDED_DATABASES=""
for i in "${DBS[@]}"; do
  PG_EXCLUDED_DATABASES="$PG_EXCLUDED_DATABASES --exclude-database=${i}"
done

BACKUP="${NAME_PREFIX}_$(date +"%Y-%m-%d_%H-%M")${EXTENSION}"
echo "Set backup file name to: $BACKUP"
echo "Starting database backup.."
echo "Excluded databases: $EXCLUDED_DATABASES"
pg_dumpall ${PG_EXCLUDED_DATABASES}| xz "-${XZ_COMPRESSION_LEVEL}" -zf - | gpg --no-tty --batch --pinentry-mode loopback --command-fd 0 -c --cipher-algo "${CIPHER_ALGO}" -z "${GPG_COMPRESSION_LEVEL}" --passphrase "${SYMMETRIC_PASSPHRASE}" | aws s3 cp - "${BUCKET}/${BACKUP}" "${AWSCLI_OPTIONS}"
echo "Backup finished!"
