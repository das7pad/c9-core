#!/usr/bin/env bash
# Helper script to launch jedi/pylint in a python2/3 virtualenv
set -e

PYTHON=$1
COMMAND=$2

SHAREDENV="/mnt/shared/lib/$PYTHON"
FALLBACKENV="$HOME/.c9/$PYTHON"

if [[ -d $SHAREDENV ]]; then
    ENV=$SHAREDENV
    source $ENV/bin/activate
    PYTHON="$ENV/bin/$PYTHON"
else
    ENV=$FALLBACKENV

    if ! [[ -d $ENV ]]; then
        if [ "$PYTHON" = "python3" ]; then
            python3 -m venv $ENV
        else
            if ! which virtualenv &>/dev/null; then
                pip install -U virtualenv
            fi
            virtualenv --python=python2 $ENV
        fi
    fi

    source $ENV/bin/activate

    if ! python -c 'import jedi' &>/dev/null; then
        echo "Installing python support dependencies" >&2
        pip install --upgrade jedi pylint pylint-flask pylint-django >&2
    fi

    PYTHON=$ENV/bin/$PYTHON
fi

COMMAND=${COMMAND/\$PYTHON/$PYTHON}
COMMAND=${COMMAND/\$ENV/$ENV}
eval "$COMMAND"
