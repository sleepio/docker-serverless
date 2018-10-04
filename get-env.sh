#!/bin/bash

# Build a config/env file with informative key-values about the environment
# Replaces/Creates a .env.<context>.<extension> in the $PWD or provided dir path
#
# Usage: ./get-env.sh [context] [optional: file extension | default: yml] [optional: env file dir | default: $PWD]
#
# TODO if optionality and no order of args starts to matter, introduce flags and case .. esac

if [ -z "$1" ]
  then
    echo "Please provide a CONTEXT argument"
    exit 1
fi

CONTEXT=$1
EXTENSION=${2:-yml} # default to YAML if no arg
[ ${EXTENSION} = "env" ] && SEPARATOR="=" || SEPARATOR=": "
ENV_PREFIX="${CONTEXT}__"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENV_FILE_DIR=${3:-$SCRIPT_DIR}
ENV_FILE="${ENV_FILE_DIR}/.env.${CONTEXT}.${EXTENSION}"
CLEAN_TREE="unknown"

main()
{
    [ -e ${ENV_FILE} ] && rm ${ENV_FILE}

    is_tree_clean ${SCRIPT_DIR}

    # Old versions of bash (below 4) do not support associative arrays, here's a
    # workaround using chars as array index for compatability across work stations
    array=(
        'timestamp::date +%s'     # unix timestamp in seconds
        'hostname::hostname'
        'whoami::whoami'
        'OS::uname -s'
        'arch::uname -p'
        'shell::echo $SHELL'
        'docker_version::docker version --format "{{.Client.Version}}"'
        'git_version::git --version | cut -d " " -f 3'
        'git_user_name::git config user.name'
        'git_user_email::git config user.email'
        'git_repo::basename `git rev-parse --show-toplevel`'
        'git_tag::git describe --tag'
        'git_branch::git rev-parse --abbrev-ref HEAD'
        'git_HEAD::git rev-parse HEAD'
        'git_clean_tree::echo "$CLEAN_TREE"'
    )

    for index in "${array[@]}" ; do
        VALID_OUTPUT=0
        KEY="${index%%::*}"
        COMMAND="${index##*::}"
        VALUE=$(eval ${COMMAND}) && VALID_OUTPUT=1

        if [ "${VALID_OUTPUT}" -eq "1" ]; then
            ENV_KEY_VALUE="${ENV_PREFIX}${KEY}${SEPARATOR}${VALUE}"
        else
            ENV_KEY_VALUE="${ENV_PREFIX}${KEY}${SEPARATOR}unkown"
        fi
        echo ${ENV_KEY_VALUE} >> ${ENV_FILE}
    done
}

is_tree_clean()
{
    git_status=`git -C $1 status 2> /dev/null`
    clean_pattern="working tree clean|working directory clean"
    if [ ! -z "${git_status}" ] && [[ ! ${git_status} =~ ${clean_pattern} ]]; then
        CLEAN_TREE="false"
    else
        CLEAN_TREE="true"
    fi
}


main;
