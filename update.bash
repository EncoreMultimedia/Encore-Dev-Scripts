#!/usr/bin/env bash

self_dir=$(cd "$(dirname "$BASH_SOURCE")"; pwd -P)

source $self_dir/bash_completion && echo "Bash command completion updated."
