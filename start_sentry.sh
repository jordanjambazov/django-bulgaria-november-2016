export REPOSITORY=sentry-onpremise


docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)


make build


docker run \
  --detach \
  --name sentry-redis \
  redis:3.2-alpine


docker run \
  --detach \
  --name sentry-postgres \
  --env POSTGRES_PASSWORD=secret \
  --env POSTGRES_USER=sentry \
  postgres:9.5


docker run \
  --detach \
  --name sentry-smtp \
  tianon/exim4


export SENTRY_SECRET_KEY=`docker run --rm ${REPOSITORY} config generate-secret-key`


docker run --rm -it \
  --link sentry-redis:redis \
  --link sentry-postgres:postgres \
  --link sentry-smtp:smtp \
  --env SENTRY_SECRET_KEY=${SENTRY_SECRET_KEY} \
  sentry-onpremise upgrade


docker run \
  --link sentry-redis:redis \
  --link sentry-postgres:postgres \
  --link sentry-smtp:smtp \
  --env SENTRY_SECRET_KEY=${SENTRY_SECRET_KEY} \
  --detach \
  --name sentry-web-01 \
  --publish 9000:9000 \
  sentry-onpremise \
  run web


docker run \
  --link sentry-redis:redis \
  --link sentry-postgres:postgres \
  --link sentry-smtp:smtp \
  --env SENTRY_SECRET_KEY=${SENTRY_SECRET_KEY} \
  --detach \
  --name sentry-worker-01 \
  sentry-onpremise \
  run worker


docker run \
  --link sentry-redis:redis \
  --link sentry-postgres:postgres \
  --link sentry-smtp:smtp \
  --env SENTRY_SECRET_KEY=${SENTRY_SECRET_KEY} \
  --detach \
  --name sentry-cron \
  sentry-onpremise \
  run cron
