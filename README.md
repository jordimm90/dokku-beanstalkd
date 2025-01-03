# dokku beanstalkd [![Build Status](https://img.shields.io/github/actions/workflow/status/dokku/dokku-beanstalkd/ci.yml?branch=master&style=flat-square "Build Status")](https://github.com/dokku/dokku-beanstalkd/actions/workflows/ci.yml?query=branch%3Amaster) [![IRC Network](https://img.shields.io/badge/irc-libera-blue.svg?style=flat-square "IRC Libera")](https://webchat.libera.chat/?channels=dokku)

Official beanstalkd plugin for dokku. Currently defaults to installing [beanstalkd 17.2](https://hub.docker.com/_/beanstalkd/).

## Requirements

- dokku 0.19.x+
- docker 1.8.x

## Installation

```shell
# on 0.19.x+
sudo dokku plugin:install https://github.com/dokku/dokku-beanstalkd.git beanstalkd
```

## Commands

```
beanstalkd:app-links <app>                           # list all beanstalkd service links for a given app
beanstalkd:backup <service> <bucket-name> [--use-iam] # create a backup of the beanstalkd service to an existing s3 bucket
beanstalkd:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url> # set up authentication for backups on the beanstalkd service
beanstalkd:backup-deauth <service>                   # remove backup authentication for the beanstalkd service
beanstalkd:backup-schedule <service> <schedule> <bucket-name> [--use-iam] # schedule a backup of the beanstalkd service
beanstalkd:backup-schedule-cat <service>             # cat the contents of the configured backup cronfile for the service
beanstalkd:backup-set-encryption <service> <passphrase> # set encryption for all future backups of beanstalkd service
beanstalkd:backup-set-public-key-encryption <service> <public-key-id> # set GPG Public Key encryption for all future backups of beanstalkd service
beanstalkd:backup-unschedule <service>               # unschedule the backup of the beanstalkd service
beanstalkd:backup-unset-encryption <service>         # unset encryption for future backups of the beanstalkd service
beanstalkd:backup-unset-public-key-encryption <service> # unset GPG Public Key encryption for future backups of the beanstalkd service
beanstalkd:clone <service> <new-service> [--clone-flags...] # create container <new-name> then copy data from <name> into <new-name>
beanstalkd:connect <service>                         # connect to the service via the beanstalkd connection tool
beanstalkd:create <service> [--create-flags...]      # create a beanstalkd service
beanstalkd:destroy <service> [-f|--force]            # delete the beanstalkd service/data/container if there are no links left
beanstalkd:enter <service>                           # enter or run a command in a running beanstalkd service container
beanstalkd:exists <service>                          # check if the beanstalkd service exists
beanstalkd:export <service>                          # export a dump of the beanstalkd service database
beanstalkd:expose <service> <ports...>               # expose a beanstalkd service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)
beanstalkd:import <service>                          # import a dump into the beanstalkd service database
beanstalkd:info <service> [--single-info-flag]       # print the service information
beanstalkd:link <service> <app> [--link-flags...]    # link the beanstalkd service to the app
beanstalkd:linked <service> <app>                    # check if the beanstalkd service is linked to an app
beanstalkd:links <service>                           # list all apps linked to the beanstalkd service
beanstalkd:list                                      # list all beanstalkd services
beanstalkd:logs <service> [-t|--tail] <tail-num-optional> # print the most recent log(s) for this service
beanstalkd:pause <service>                           # pause a running beanstalkd service
beanstalkd:promote <service> <app>                   # promote service <service> as BEANSTALKD_URL in <app>
beanstalkd:restart <service>                         # graceful shutdown and restart of the beanstalkd service container
beanstalkd:set <service> <key> <value>               # set or clear a property for a service
beanstalkd:start <service>                           # start a previously stopped beanstalkd service
beanstalkd:stop <service>                            # stop a running beanstalkd service
beanstalkd:unexpose <service>                        # unexpose a previously exposed beanstalkd service
beanstalkd:unlink <service> <app>                    # unlink the beanstalkd service from the app
beanstalkd:upgrade <service> [--upgrade-flags...]    # upgrade service <service> to the specified versions
```

## Usage

Help for any commands can be displayed by specifying the command as an argument to beanstalkd:help. Plugin help output in conjunction with any files in the `docs/` folder is used to generate the plugin documentation. Please consult the `beanstalkd:help` command for any undocumented commands.

### Basic Usage

### create a beanstalkd service

```shell
# usage
dokku beanstalkd:create <service> [--create-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-m|--memory MEMORY`: container memory limit in megabytes (default: unlimited)
- `-N|--initial-network INITIAL_NETWORK`: the initial network to attach the service to
- `-p|--password PASSWORD`: override the user-level service password
- `-P|--post-create-network NETWORKS`: a comma-separated list of networks to attach the service container to after service creation
- `-r|--root-password PASSWORD`: override the root-level service password
- `-S|--post-start-network NETWORKS`: a comma-separated list of networks to attach the service container to after service start
- `-s|--shm-size SHM_SIZE`: override shared memory size for beanstalkd docker container

Create a beanstalkd service named lollipop:

```shell
dokku beanstalkd:create lollipop
```

You can also specify the image and image version to use for the service. It *must* be compatible with the beanstalkd image.

```shell
export BEANSTALKD_IMAGE="beanstalkd"
export BEANSTALKD_IMAGE_VERSION="${PLUGIN_IMAGE_VERSION}"
dokku beanstalkd:create lollipop
```

You can also specify custom environment variables to start the beanstalkd service in semicolon-separated form.

```shell
export BEANSTALKD_CUSTOM_ENV="USER=alpha;HOST=beta"
dokku beanstalkd:create lollipop
```

Official Beanstalkd "$DOCKER_BIN" image ls does not include postgis extension (amongst others). The following example creates a new beanstalkd service using `postgis/postgis:13-3.1` image, which includes the `postgis` extension.

```shell
# use the appropriate image-version for your use-case
dokku beanstalkd:create postgis-database --image "postgis/postgis" --image-version "13-3.1"
```

To use pgvector instead, run the following:

```shell
# use the appropriate image-version for your use-case
dokku beanstalkd:create pgvector-database --image "pgvector/pgvector" --image-version "pg17"
```

### print the service information

```shell
# usage
dokku beanstalkd:info <service> [--single-info-flag]
```

flags:

- `--config-dir`: show the service configuration directory
- `--data-dir`: show the service data directory
- `--dsn`: show the service DSN
- `--exposed-ports`: show service exposed ports
- `--id`: show the service container id
- `--internal-ip`: show the service internal ip
- `--initial-network`: show the initial network being connected to
- `--links`: show the service app links
- `--post-create-network`: show the networks to attach to after service container creation
- `--post-start-network`: show the networks to attach to after service container start
- `--service-root`: show the service root directory
- `--status`: show the service running status
- `--version`: show the service image version

Get connection information as follows:

```shell
dokku beanstalkd:info lollipop
```

You can also retrieve a specific piece of service info via flags:

```shell
dokku beanstalkd:info lollipop --config-dir
dokku beanstalkd:info lollipop --data-dir
dokku beanstalkd:info lollipop --dsn
dokku beanstalkd:info lollipop --exposed-ports
dokku beanstalkd:info lollipop --id
dokku beanstalkd:info lollipop --internal-ip
dokku beanstalkd:info lollipop --initial-network
dokku beanstalkd:info lollipop --links
dokku beanstalkd:info lollipop --post-create-network
dokku beanstalkd:info lollipop --post-start-network
dokku beanstalkd:info lollipop --service-root
dokku beanstalkd:info lollipop --status
dokku beanstalkd:info lollipop --version
```

### list all beanstalkd services

```shell
# usage
dokku beanstalkd:list
```

List all services:

```shell
dokku beanstalkd:list
```

### print the most recent log(s) for this service

```shell
# usage
dokku beanstalkd:logs <service> [-t|--tail] <tail-num-optional>
```

flags:

- `-t|--tail [<tail-num>]`: do not stop when end of the logs are reached and wait for additional output

You can tail logs for a particular service:

```shell
dokku beanstalkd:logs lollipop
```

By default, logs will not be tailed, but you can do this with the --tail flag:

```shell
dokku beanstalkd:logs lollipop --tail
```

The default tail setting is to show all logs, but an initial count can also be specified:

```shell
dokku beanstalkd:logs lollipop --tail 5
```

### link the beanstalkd service to the app

```shell
# usage
dokku beanstalkd:link <service> <app> [--link-flags...]
```

flags:

- `-a|--alias "BLUE_DATABASE"`: an alternative alias to use for linking to an app via environment variable
- `-q|--querystring "pool=5"`: ampersand delimited querystring arguments to append to the service link
- `-n|--no-restart "false"`: whether or not to restart the app on link (default: true)

A beanstalkd service can be linked to a container. This will use native docker links via the docker-options plugin. Here we link it to our `playground` app.

> NOTE: this will restart your app

```shell
dokku beanstalkd:link lollipop playground
```

The following environment variables will be set automatically by docker (not on the app itself, so they won’t be listed when calling dokku config):

```
DOKKU_BEANSTALKD_LOLLIPOP_NAME=/lollipop/DATABASE
DOKKU_BEANSTALKD_LOLLIPOP_PORT=tcp://172.17.0.1:5432
DOKKU_BEANSTALKD_LOLLIPOP_PORT_5432_TCP=tcp://172.17.0.1:5432
DOKKU_BEANSTALKD_LOLLIPOP_PORT_5432_TCP_PROTO=tcp
DOKKU_BEANSTALKD_LOLLIPOP_PORT_5432_TCP_PORT=5432
DOKKU_BEANSTALKD_LOLLIPOP_PORT_5432_TCP_ADDR=172.17.0.1
```

The following will be set on the linked application by default:

```
BEANSTALKD_URL=beanstalkd://lollipop:SOME_PASSWORD@dokku-beanstalkd-lollipop:5432/lollipop
```

The host exposed here only works internally in docker containers. If you want your container to be reachable from outside, you should use the `expose` subcommand. Another service can be linked to your app:

```shell
dokku beanstalkd:link other_service playground
```

It is possible to change the protocol for `BEANSTALKD_URL` by setting the environment variable `BEANSTALKD_DATABASE_SCHEME` on the app. Doing so will after linking will cause the plugin to think the service is not linked, and we advise you to unlink before proceeding.

```shell
dokku config:set playground BEANSTALKD_DATABASE_SCHEME=beanstalkd2
dokku beanstalkd:link lollipop playground
```

This will cause `BEANSTALKD_URL` to be set as:

```
beanstalkd2://lollipop:SOME_PASSWORD@dokku-beanstalkd-lollipop:5432/lollipop
```

### unlink the beanstalkd service from the app

```shell
# usage
dokku beanstalkd:unlink <service> <app>
```

flags:

- `-n|--no-restart "false"`: whether or not to restart the app on unlink (default: true)

You can unlink a beanstalkd service:

> NOTE: this will restart your app and unset related environment variables

```shell
dokku beanstalkd:unlink lollipop playground
```

### set or clear a property for a service

```shell
# usage
dokku beanstalkd:set <service> <key> <value>
```

Set the network to attach after the service container is started:

```shell
dokku beanstalkd:set lollipop post-create-network custom-network
```

Set multiple networks:

```shell
dokku beanstalkd:set lollipop post-create-network custom-network,other-network
```

Unset the post-create-network value:

```shell
dokku beanstalkd:set lollipop post-create-network
```

### Service Lifecycle

The lifecycle of each service can be managed through the following commands:

### connect to the service via the beanstalkd connection tool

```shell
# usage
dokku beanstalkd:connect <service>
```

Connect to the service via the beanstalkd connection tool:

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku beanstalkd:connect lollipop
```

### enter or run a command in a running beanstalkd service container

```shell
# usage
dokku beanstalkd:enter <service>
```

A bash prompt can be opened against a running service. Filesystem changes will not be saved to disk.

> NOTE: disconnecting from ssh while running this command may leave zombie processes due to moby/moby#9098

```shell
dokku beanstalkd:enter lollipop
```

You may also run a command directly against the service. Filesystem changes will not be saved to disk.

```shell
dokku beanstalkd:enter lollipop touch /tmp/test
```

### expose a beanstalkd service on custom host:port if provided (random port on the 0.0.0.0 interface if otherwise unspecified)

```shell
# usage
dokku beanstalkd:expose <service> <ports...>
```

Expose the service on the service's normal ports, allowing access to it from the public interface (`0.0.0.0`):

```shell
dokku beanstalkd:expose lollipop 5432
```

Expose the service on the service's normal ports, with the first on a specified ip adddress (127.0.0.1):

```shell
dokku beanstalkd:expose lollipop 127.0.0.1:5432
```

### unexpose a previously exposed beanstalkd service

```shell
# usage
dokku beanstalkd:unexpose <service>
```

Unexpose the service, removing access to it from the public interface (`0.0.0.0`):

```shell
dokku beanstalkd:unexpose lollipop
```

### promote service <service> as BEANSTALKD_URL in <app>

```shell
# usage
dokku beanstalkd:promote <service> <app>
```

If you have a beanstalkd service linked to an app and try to link another beanstalkd service another link environment variable will be generated automatically:

```
DOKKU_DATABASE_BLUE_URL=beanstalkd://other_service:ANOTHER_PASSWORD@dokku-beanstalkd-other-service:5432/other_service
```

You can promote the new service to be the primary one:

> NOTE: this will restart your app

```shell
dokku beanstalkd:promote other_service playground
```

This will replace `BEANSTALKD_URL` with the url from other_service and generate another environment variable to hold the previous value if necessary. You could end up with the following for example:

```
BEANSTALKD_URL=beanstalkd://other_service:ANOTHER_PASSWORD@dokku-beanstalkd-other-service:5432/other_service
DOKKU_DATABASE_BLUE_URL=beanstalkd://other_service:ANOTHER_PASSWORD@dokku-beanstalkd-other-service:5432/other_service
DOKKU_DATABASE_SILVER_URL=beanstalkd://lollipop:SOME_PASSWORD@dokku-beanstalkd-lollipop:5432/lollipop
```

### start a previously stopped beanstalkd service

```shell
# usage
dokku beanstalkd:start <service>
```

Start the service:

```shell
dokku beanstalkd:start lollipop
```

### stop a running beanstalkd service

```shell
# usage
dokku beanstalkd:stop <service>
```

Stop the service and removes the running container:

```shell
dokku beanstalkd:stop lollipop
```

### pause a running beanstalkd service

```shell
# usage
dokku beanstalkd:pause <service>
```

Pause the running container for the service:

```shell
dokku beanstalkd:pause lollipop
```

### graceful shutdown and restart of the beanstalkd service container

```shell
# usage
dokku beanstalkd:restart <service>
```

Restart the service:

```shell
dokku beanstalkd:restart lollipop
```

### upgrade service <service> to the specified versions

```shell
# usage
dokku beanstalkd:upgrade <service> [--upgrade-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-N|--initial-network INITIAL_NETWORK`: the initial network to attach the service to
- `-P|--post-create-network NETWORKS`: a comma-separated list of networks to attach the service container to after service creation
- `-R|--restart-apps "true"`: whether or not to force an app restart (default: false)
- `-S|--post-start-network NETWORKS`: a comma-separated list of networks to attach the service container to after service start
- `-s|--shm-size SHM_SIZE`: override shared memory size for beanstalkd docker container

You can upgrade an existing service to a new image or image-version:

```shell
dokku beanstalkd:upgrade lollipop
```

Beanstalkd does not handle upgrading data for major versions automatically (eg. 11 => 12). Upgrades should be done manually. Users are encouraged to upgrade to the latest minor release for their beanstalkd version before performing a major upgrade.

While there are many ways to upgrade a beanstalkd database, for safety purposes, it is recommended that an upgrade is performed by exporting the data from an existing database and importing it into a new database. This also allows testing to ensure that applications interact with the database correctly after the upgrade, and can be used in a staging environment.

The following is an example of how to upgrade a beanstalkd database named `lollipop-11` from 11.13 to 12.8.

```shell
# stop any linked apps
dokku ps:stop linked-app

# export the database contents
dokku beanstalkd:export lollipop-11 > /tmp/lollipop-11.export

# create a new database at the desired version
dokku beanstalkd:create lollipop-12 --image-version 12.8

# import the export file
dokku beanstalkd:import lollipop-12 < /tmp/lollipop-11.export

# run any sql tests against the new database to verify the import went smoothly

# unlink the old database from your apps
dokku beanstalkd:unlink lollipop-11 linked-app

# link the new database to your apps
dokku beanstalkd:link lollipop-12 linked-app

# start the linked apps again
dokku ps:start linked-app
```

### Service Automation

Service scripting can be executed using the following commands:

### list all beanstalkd service links for a given app

```shell
# usage
dokku beanstalkd:app-links <app>
```

List all beanstalkd services that are linked to the `playground` app.

```shell
dokku beanstalkd:app-links playground
```

### create container <new-name> then copy data from <name> into <new-name>

```shell
# usage
dokku beanstalkd:clone <service> <new-service> [--clone-flags...]
```

flags:

- `-c|--config-options "--args --go=here"`: extra arguments to pass to the container create command (default: `None`)
- `-C|--custom-env "USER=alpha;HOST=beta"`: semi-colon delimited environment variables to start the service with
- `-i|--image IMAGE`: the image name to start the service with
- `-I|--image-version IMAGE_VERSION`: the image version to start the service with
- `-m|--memory MEMORY`: container memory limit in megabytes (default: unlimited)
- `-N|--initial-network INITIAL_NETWORK`: the initial network to attach the service to
- `-p|--password PASSWORD`: override the user-level service password
- `-P|--post-create-network NETWORKS`: a comma-separated list of networks to attach the service container to after service creation
- `-r|--root-password PASSWORD`: override the root-level service password
- `-S|--post-start-network NETWORKS`: a comma-separated list of networks to attach the service container to after service start
- `-s|--shm-size SHM_SIZE`: override shared memory size for beanstalkd docker container

You can clone an existing service to a new one:

```shell
dokku beanstalkd:clone lollipop lollipop-2
```

### check if the beanstalkd service exists

```shell
# usage
dokku beanstalkd:exists <service>
```

Here we check if the lollipop beanstalkd service exists.

```shell
dokku beanstalkd:exists lollipop
```

### check if the beanstalkd service is linked to an app

```shell
# usage
dokku beanstalkd:linked <service> <app>
```

Here we check if the lollipop beanstalkd service is linked to the `playground` app.

```shell
dokku beanstalkd:linked lollipop playground
```

### list all apps linked to the beanstalkd service

```shell
# usage
dokku beanstalkd:links <service>
```

List all apps linked to the `lollipop` beanstalkd service.

```shell
dokku beanstalkd:links lollipop
```

### Data Management

The underlying service data can be imported and exported with the following commands:

### import a dump into the beanstalkd service database

```shell
# usage
dokku beanstalkd:import <service>
```

Import a datastore dump:

```shell
dokku beanstalkd:import lollipop < data.dump
```

### export a dump of the beanstalkd service database

```shell
# usage
dokku beanstalkd:export <service>
```

By default, datastore output is exported to stdout:

```shell
dokku beanstalkd:export lollipop
```

You can redirect this output to a file:

```shell
dokku beanstalkd:export lollipop > data.dump
```

Note that the export will result in a file containing the binary beanstalkd export data. It can be converted to plain text using `pg_restore` as follows

```shell
pg_restore data.dump -f plain.sql
```

### Backups

Datastore backups are supported via AWS S3 and S3 compatible services like [minio](https://github.com/minio/minio).

You may skip the `backup-auth` step if your dokku install is running within EC2 and has access to the bucket via an IAM profile. In that case, use the `--use-iam` option with the `backup` command.

Backups can be performed using the backup commands:

### set up authentication for backups on the beanstalkd service

```shell
# usage
dokku beanstalkd:backup-auth <service> <aws-access-key-id> <aws-secret-access-key> <aws-default-region> <aws-signature-version> <endpoint-url>
```

Setup s3 backup authentication:

```shell
dokku beanstalkd:backup-auth lollipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
```

Setup s3 backup authentication with different region:

```shell
dokku beanstalkd:backup-auth lollipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION
```

Setup s3 backup authentication with different signature version and endpoint:

```shell
dokku beanstalkd:backup-auth lollipop AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION AWS_SIGNATURE_VERSION ENDPOINT_URL
```

More specific example for minio auth:

```shell
dokku beanstalkd:backup-auth lollipop MINIO_ACCESS_KEY_ID MINIO_SECRET_ACCESS_KEY us-east-1 s3v4 https://YOURMINIOSERVICE
```

### remove backup authentication for the beanstalkd service

```shell
# usage
dokku beanstalkd:backup-deauth <service>
```

Remove s3 authentication:

```shell
dokku beanstalkd:backup-deauth lollipop
```

### create a backup of the beanstalkd service to an existing s3 bucket

```shell
# usage
dokku beanstalkd:backup <service> <bucket-name> [--use-iam]
```

flags:

- `-u|--use-iam`: use the IAM profile associated with the current server

Backup the `lollipop` service to the `my-s3-bucket` bucket on `AWS`:`

```shell
dokku beanstalkd:backup lollipop my-s3-bucket --use-iam
```

Restore a backup file (assuming it was extracted via `tar -xf backup.tgz`):

```shell
dokku beanstalkd:import lollipop < backup-folder/export
```

### set encryption for all future backups of beanstalkd service

```shell
# usage
dokku beanstalkd:backup-set-encryption <service> <passphrase>
```

Set the GPG-compatible passphrase for encrypting backups for backups:

```shell
dokku beanstalkd:backup-set-encryption lollipop
```

### set GPG Public Key encryption for all future backups of beanstalkd service

```shell
# usage
dokku beanstalkd:backup-set-public-key-encryption <service> <public-key-id>
```

Set the `GPG` Public Key for encrypting backups:

```shell
dokku beanstalkd:backup-set-public-key-encryption lollipop
```

### unset encryption for future backups of the beanstalkd service

```shell
# usage
dokku beanstalkd:backup-unset-encryption <service>
```

Unset the `GPG` encryption passphrase for backups:

```shell
dokku beanstalkd:backup-unset-encryption lollipop
```

### unset GPG Public Key encryption for future backups of the beanstalkd service

```shell
# usage
dokku beanstalkd:backup-unset-public-key-encryption <service>
```

Unset the `GPG` Public Key encryption for backups:

```shell
dokku beanstalkd:backup-unset-public-key-encryption lollipop
```

### schedule a backup of the beanstalkd service

```shell
# usage
dokku beanstalkd:backup-schedule <service> <schedule> <bucket-name> [--use-iam]
```

flags:

- `-u|--use-iam`: use the IAM profile associated with the current server

Schedule a backup:

> 'schedule' is a crontab expression, eg. "0 3 * * *" for each day at 3am

```shell
dokku beanstalkd:backup-schedule lollipop "0 3 * * *" my-s3-bucket
```

Schedule a backup and authenticate via iam:

```shell
dokku beanstalkd:backup-schedule lollipop "0 3 * * *" my-s3-bucket --use-iam
```

### cat the contents of the configured backup cronfile for the service

```shell
# usage
dokku beanstalkd:backup-schedule-cat <service>
```

Cat the contents of the configured backup cronfile for the service:

```shell
dokku beanstalkd:backup-schedule-cat lollipop
```

### unschedule the backup of the beanstalkd service

```shell
# usage
dokku beanstalkd:backup-unschedule <service>
```

Remove the scheduled backup from cron:

```shell
dokku beanstalkd:backup-unschedule lollipop
```

### Disabling `docker image pull` calls

If you wish to disable the `docker image pull` calls that the plugin triggers, you may set the `BEANSTALKD_DISABLE_PULL` environment variable to `true`. Once disabled, you will need to pull the service image you wish to deploy as shown in the `stderr` output.

Please ensure the proper images are in place when `docker image pull` is disabled.
