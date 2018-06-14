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

## Usage
```bash
$> docker run --rm -v $(pwd):/opt/workspace ipanousis/serverless deploy
    
```

## Example
```bash
$> docker run --rm -v $(pwd):/opt/workspace -e aws_access_key=${AWS_ACCESS_KEY_ID} -e aws_secret_key=${AWS_SECRET_ACCESS_KEY} ipanousis/serverless deploy
```
