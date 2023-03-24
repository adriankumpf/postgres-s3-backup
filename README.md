# docker-postgres-s3-archive

Taken from [InAnimaTe/docker-postgres-s3-archive](https://github.com/InAnimaTe/docker-postgres-s3-archive), this image has the necessary utilities for you to perform postgres backups to S3.

The idea is here is to provide an easy ready-to-go way to dump an entire postgresql database, compress it, encrypt it, and push it to Amazon S3.

## Usage

```
docker build --build-arg POSTGRES_VERSION=15 -t postgres-backup .
docker run -it --network=container:postgres --env-file .env --rm --name postgres-backup postgres-backup
```

To perform continues backups schedule a cron job:

```crontab
0 2 * * * docker run -itd --network=container:postgres --env-file .env --rm --name postgres-backup postgres-backup
```

## Features:

- Symmetric Encryption via `gpg`
- Compression via `xz` (lzma2)
- Extreme configurability via environment variables :)

## Environment variables

### _Required_

- `AWS_ACCESS_KEY_ID` - AWS S3 access key.
- `AWS_SECRET_ACCESS_KEY` - AWS S3 secret key.
- `BUCKET` - AWS S3 bucket (and folder) to store the backup. i.e. `s3://herpderpbucket/folder`
- `SYMMETRIC_PASSPHRASE` - The gpg symmetric passphrase to use to encrypt your file.

### _Optional_

- `PGHOST/PGPORT` - Two variables which can be set to specify the usage of a different container or postgres server (meaning you aren't linking). (default: HOST and PORT of the container you link.)
- `PGUSER` - The database user to connect as (default: `postgres`)

  > We assume the user provided has full access without a password needed. Please make sure this exists and your server allows this user to login from the same network segment.

- `NAME_PREFIX` - A prefix in front of the date i.e. `jira-data-dir-backup` (default: `database-archive`)
- `GPG_COMPRESSION_LEVEL` - The compression level for gpg to use (0-9). (default: `0`; _not recommended since we're using xz_)
- `XZ_COMPRESSION_LEVEL` - The compression level for xz (lzma2) to use (0-9). (default: `9`; _this is the best compression level_)
- `CIPHER_ALGO` - The cipher for gpg to utilize when encrypting your archive. (default: `aes256`)
- `EXTENSION` - The extension to use for the backup file i.e. `tgz,tar.xz,bz2` (default: `.psql.xz.gpg`)
- `AWSCLI_OPTIONS` - Provide some arguments to awscli (default: `--sse`) See [here](http://docs.aws.amazon.com/cli/latest/reference/s3/cp.html) for possibilities.
- `EXCLUDED_DATABASES` - The postgres databases (comma-separated) which should be excluded from the backup. (default: none)

> All other [aws-cli](https://github.com/aws/aws-cli) variables are also supported.

## A few notes

- Use spaces in your buckets, prefix, or extension _at your own risk_!
