#!/bin/bash
# shellcheck disable=SC2001
# The shebang above is only there to enable the right linter

"./enc.$(echo "$0" | sed 's|.*/||')" install
