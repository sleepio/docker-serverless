# Serverless as a Docker container

Docker image with [Serverless Framework](https://serverless.com/) + [AWS CLI](https://aws.amazon.com/cli/)

Use this image to deploy a `serverless.yml` without installing Serverless or Node or NPM.

## Languages available

- Python 3.6

In future we anticipate needing multiple tags for our Serverless deploy images, each tag for a particular language. For now the `latest` Docker tag (which is the default one) has the Python 3.6 image.

## Local Setup

You will need to checkout this repository and build the Docker image on your local.

1. `git checkout git@github.com:sleepio/docker-serverless.git`
2. `cd docker-serverless`
3. `./build`
4. `cd /your/serverless/compatible/project/dir`
5. Proceed to either the Docker Usage section or the Docker Compose Usage section below, depending on whether you are using Docker Compose or not

## Docker Usage

```bash
docker run --rm -v $(pwd):/opt/workspace -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} -e GIT_TOKEN=${GIT_TOKEN} serverless:latest deploy
```

## Docker Compose Usage for Serverless-compatible Project

Add the following service to `docker-compose.yml`:
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

Add the following in your bashrc:
```sh
srv() {
  docker-compose run \
    -e deploy__remote_url="$(git config --get remote.origin.url)" \
    -e deploy__branch="$(git rev-parse --abbrev-ref HEAD)" \
    -e deploy__HEAD="$(git rev-parse HEAD)" \
    -e deploy__timestamp="$(date +%s)" \
    -e deploy__whoami="$(whoami)" \
    remote $@;
}
```

All commands are run from the project folder

when deploying:
```sh
$ srv deploy
```

when accessing logs:
```sh
$ srv logs --function myFunction --tail
```

## Troubleshooting

### Deploying as an AWS User with MFA

If deploying as an AWS user with 2FA, you will need to generate a session token to go along with temporary credentials with an expiration time. After configuring the AWS CLI on your local machine, run the following commands (after filling in the ``aws-account-id``, ``aws-username`` and ``token-from-MFA-device`` fields) to get temporary credentials and set them as environment variables:
```
$ aws sts get-session-token --serial-number arn:aws:iam::<aws-account-id>:mfa/<aws-username> --token-code <token-from-MFA-device> --duration-seconds 129600

{
"Credentials": {
    "SecretAccessKey": "secret-access-key",
    "SessionToken": "temporary-session-token",
    "Expiration": "expiration-date-time",
    "AccessKeyId": "access-key-id"
  }
}

$ export AWS_ACCESS_KEY_ID=<access-key-id>
$ export AWS_SECRET_ACCESS_KEY=<secret-access-key>
$ export AWS_SESSION_TOKEN=<temporary-session-token>

```
In addition, you will need to add the session token to the remote service `docker-compose.yml`:

```
remote:
  image: serverless:latest
  volumes:
    - ./:/opt/workspace
  environment:
    AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
    AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
    AWS_SESSION_TOKEN: ${AWS_SESSION_TOKEN} <-------------------------
    GIT_TOKEN: ${GIT_TOKEN}
```

### Unable to find image 'remote:latest' locally

If you get the following error:
```
Unable to find image 'remote:latest' locally
docker: Error response from daemon: pull access denied for remote, repository does not exist or may require 'docker login'.
See 'docker run --help'.
```
make sure you're running ``docker-compose run remote deploy`` and not ``docker run remote deploy``.

### Module initialization error

If you get the following error when deploying:
```
{
    "errorMessage": "module initialization error"
}

  Error --------------------------------------------------

  Invoked function failed
```
make sure the role created by CloudFormation (of format ``<ServiceName>-<stage>-us-west-2-lambdaRole``) has the ``SSMDynamicSettings`` permission attached to it. Attach, wait for ~10 min, and re-deploy.
