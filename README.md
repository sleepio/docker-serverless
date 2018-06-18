# ipanousis/serverless

Docker image with [Serverless Framework](https://serverless.com/) + [AWS CLI](https://aws.amazon.com/cli/)

##### Github [https://github.com/ipanousis/docker-serverless](https://github.com/ipanousis/docker-serverless)
 
### Packages
    - ca-certificates 
    - update-ca-certificates
    - curl
    - unzip 
    - bash 
    - python 
    - py-pip 
    - openssh 
    - git 
    - make 
    - tzdata
    - awscli (via PIP)  
    - jq
 
## INFO

- You can use it to deploy a serverless.yml without installing Serverless or Node or NPM
- Workdir is set to /opt/workspace

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
