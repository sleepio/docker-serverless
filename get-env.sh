#!/bin/bash

exec 2> /dev/null

if [ -z "$1" ]
  then
    echo "Please provide a CONTEXT argument"
    exit 1
fi

CONTEXT=$1
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENV_FILE="$SCRIPT_DIR/$CONTEXT.env"
CLEAN_TREE="unknown"

main()
{
    [ -e $ENV_FILE ] && rm $ENV_FILE
    is_tree_clean $SCRIPT_DIR

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
        VALUE=$(eval $COMMAND) && VALID_OUTPUT=1

        if [ "$VALID_OUTPUT" -eq "1" ]; then
            KEY_VALUE="$CONTEXT$KEY=$VALUE"
        else
            KEY_VALUE="$CONTEXT$KEY=unkown"
        fi
        echo $KEY_VALUE >> $ENV_FILE
    done
}

is_tree_clean()
{
    git_status=`git -C $1 status 2> /dev/null`
    clean_pattern="working tree clean|working directory clean"
    if [ ! -z "$git_status" ] && [[ ! $git_status =~ $clean_pattern ]]; then
        CLEAN_TREE="false"
    else
        CLEAN_TREE="true"
    fi
}


main;
