# Serverless as a Docker container

Docker image with [Serverless Framework](https://serverless.com/) + [AWS CLI](https://aws.amazon.com/cli/)

Use this image to deploy a serverless.yml without installing Serverless or Node or NPM.

## Languages available

- Python 3.6

## Docker Usage

```bash
docker run --rm -v $(pwd):/opt/workspace -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} -e GIT_TOKEN=${GIT_TOKEN} bighealth/serverless deploy
```

## Docker Compose Usage

docker-compose.yml:
```
services:
  deploy:
    image: ipanousis/serverless
    volumes:
      - ./:/opt/workspace
    environment:
      AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
      AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
```

in Shell / script:
```
docker-compose run deploy
```
