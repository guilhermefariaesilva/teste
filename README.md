# Infra-app

An app to apply SRE tests.

## Basic instructions

To run in development, just run:

```sh
docker-compose up
```

```sh
docker-compose build
docker-compose run web ruby -Itest "test/*"
```
