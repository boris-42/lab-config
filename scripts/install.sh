#!/bin/bash -e

cwd="$(dirname $0)/.."
venv="$cwd/.venv"

# Install docker-compose in virtualenv
virtualenv "$venv"
"$venv/bin/pip" install docker-compose==1.9.0
