#!/bin/bash

################################################################################
# This is an example script will install Asciidoc using Stepper.
################################################################################

SCRIPT_DIR=$(dirname $(readlink -e ${0}))
. ${SCRIPT_DIR}/../lib/stepper.sh

# Fail on all errors.
set -e

# Establish a work directory.
WORKDIR=$(mktemp -d /tmp/stepper-example_XXXXXX)

# Define the steps
stepper_add_step "update"  "Updating Apt."        "sudo apt-get update" ${WORKDIR}/update.log ${WORKDIR}/update.err
stepper_add_step "install" "Installing Asciidoc." "sudo apt-get -y install asciidoc" ${WORKDIR}/install.log ${WORKDIR}/install.err
stepper_add_step "clean"   "Cleaning Apt cache."  "sudo apt-get clean" ${WORKDIR}/clean.log ${WORKDIR}/clean.err

# Execute the steps
stepper_execute
