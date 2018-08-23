# Serverless as a Docker container

Docker image with [Serverless Framework](https://serverless.com/) + [AWS CLI](https://aws.amazon.com/cli/)

Use this image to deploy a serverless.yml without installing Serverless or Node or NPM.

## Languages available

- Python 3.6

In future we anticipate needing multiple tags for our Serverless deploy images, each tag for a particular language. For now the `latest` Docker tag (which is the default one) has the Python 3.6 image.

## Local Setup

You will need to checkout this repository and build the Docker image on your local.

1. `git checkout git@github.com:sleepio/docker-serverless.git`
2. `cd docker-serverless`
3. `docker build -t serverless:latest .`
4. `cd /your/serverless/compatible/project/dir`
5. Proceed to either the Docker Usage section or the Docker Compose Usage section below, depending on whether you are using Docker Compose or not

## Docker Usage

```bash
docker run --rm -v $(pwd):/opt/workspace -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} -e GIT_TOKEN=${GIT_TOKEN} serverless:latest deploy
```

## Docker Compose Usage for Serverless-compatible Project

Add the following service to  docker-compose.yml:
```
remote:
image: serverless:latest
volumes:
  - ./:/opt/workspace
environment:
  AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
  AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
  GIT_TOKEN: ${GIT_TOKEN}
```

All commands are run from the project folder

when deploying:
```
docker-compose run remote deploy
```

when accessing logs:
```
docker-compose run remote logs --function myFunction --tail
```

