#!/bin/bash

################################################################################
# This is an example script for how to use the Stepper library.
#
# Two parameters can be passed to this script:
# Parameter 1: The work directory for the execution. By default some temporary
#              directory will be created.
# Parameter 2: The step from which to resume. If omitted, all steps will be
#              executed.
################################################################################

SCRIPT_DIR=$(dirname $(readlink -e ${0}))
. ${SCRIPT_DIR}/../lib/stepper.sh

# Fail on all errors.
set -e

# Some example function
function fn_test() {
  echo "This is a hello to the world."
}

# Establish a work directory.
WORKDIR="${1}"
if [[ "" == "${WORKDIR}" ]]; then
  WORKDIR=$(mktemp -d /tmp/stepper-example_XXXXXX)
fi
# Retrieve the resume step (if specified)
RESUME_STEP="${2}"

# Define the steps
#                Name             Message                               Command                                                          Stdout                 Stderr
stepper_add_step "list_stuff"     "Listing stuff."                      "echo 'hello world' && ls -la && touch ${WORKDIR}/touched.file"  ${WORKDIR}/stdout.log  ${WORKDIR}/stderr.log
stepper_add_step "call_internal"  "Calling an internal function."       "fn_test"
stepper_add_step "call_internal2" "Calling an internal function again." "fn_test && doamso"                                              ${WORKDIR}/logfile.txt

# Enable showing of the commands that are executed for each step (this is optional; default is hidden).
#stepper_show_commands

# Set the resume command (this will be shown in case of failure and will be appended with the failing step).
stepper_set_resume_command "${0} ${WORKDIR} "

# Execute the steps
stepper_execute "${RESUME_STEP}"
