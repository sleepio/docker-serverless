# Serverless as a Docker container

Docker image with [Serverless Framework](https://serverless.com/) + [AWS CLI](https://aws.amazon.com/cli/)

Use this image to deploy a serverless.yml without installing Serverless or Node or NPM.

## Languages available

- Python 3.6

In future we anticipate needing multiple tags for our Serverless deploy images, each tag for a particular language. For now the `latest` Docker tag (which is the default one) has the Python 3.6 image.

## BigHealth Repository and Getting Access

We are using the Container Registry that AWS offers.

The domain name for it is a bit long and ugly: 067862724523.dkr.ecr.us-east-1.amazonaws.com

To get access please contact the infrastructure team.

## Docker Usage

```bash
docker run --rm -v $(pwd):/opt/workspace -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} -e GIT_TOKEN=${GIT_TOKEN} 067862724523.dkr.ecr.us-east-1.amazonaws.com/serverless deploy
```

## Docker Compose Usage

docker-compose.yml:
```
services:
  deploy:
    image: 067862724523.dkr.ecr.us-east-1.amazonaws.com/serverless
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
