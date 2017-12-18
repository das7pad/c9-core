#!/usr/bin/env bash
# Helper script to launch jedi/pylint in a python2/3 virtualenv
set -e

PYTHON=$1
COMMAND=$2

SHAREDENV="/mnt/shared/lib/$PYTHON"
FALLBACKENV="$HOME/.c9/$PYTHON"

if [[ -d $SHAREDENV ]]; then
    ENV=$SHAREDENV
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

    PYTHON="$ENV/bin/$PYTHON"
    if ! $PYTHON -c 'import jedi' &>/dev/null; then
        PIP="$ENV/bin/pip"
        echo "Installing python support dependencies" >&2
        $PIP install --upgrade \
            jedi \
            'pylint>=1.7,<1.8' \
            pylint-flask \
            pylint-django \
            >&2
    fi
fi

COMMAND=${COMMAND/\$PYTHON/$PYTHON}
COMMAND=${COMMAND/\$ENV/$ENV}
eval "$COMMAND"
