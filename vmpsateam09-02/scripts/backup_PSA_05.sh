#!/usr/bin/env bash
set -euo pipefail
umask 077

export PGPASSFILE=/run/secrets/rendered/psa-admin.pgpass

backup_root=/var/backup/postgresql
backup_dir="$backup_root/$(date -u +%Y-%m-%dT%H-%M-%SZ)"

mkdir -p "$backup_dir"

# Back up every database while PostgreSQL keeps running.
echo "Starting backup: $backup_dir"
pg_basebackup \
  --host=127.0.0.1 \
  --username=postgres \
  --no-password \
  --pgdata="$backup_dir" \
  --format=tar \
  --wal-method=stream \
  --checkpoint=spread \
  --verbose

# Mark the backup complete only after verification succeeds.
pg_verifybackup --no-parse-wal "$backup_dir"
echo "Backup completed: $backup_dir"

# Keep seven days of complete backups. Leave failed backups for inspection.
find "$backup_root" -maxdepth 1 -type d \
  -name '20*Z' -mtime +7 -exec rm -r -- {} +
