#!/bin/bash

STEPPER_SHOW_COMMANDS="false"
STEPPER_STEP_NAMES=()
STEPPER_STEP_MESSAGE=()
STEPPER_STEP_COMMANDS=()
STEPPER_RESUME_COMMAND=""

################################################################################
# Prints a message.
#
# Parameter 1: The message.
################################################################################
function stepper_print() {
  echo "${1}"
}

################################################################################
# Prints an error message.
#
# Parameter 1: The message.
################################################################################
function stepper_print_error() {
  echo "${1}"
}

################################################################################
# Enables the output of the commands that are executed for a step.
################################################################################
function stepper_show_commands() {
  STEPPER_SHOW_COMMANDS="true"
}

################################################################################
# Disables the output of the commands that are executed for a step.
################################################################################
function stepper_hide_commands() {
  STEPPER_SHOW_COMMANDS="false"
}

################################################################################
# Sets the command that can be used to resume in case of an error.
#
# If this command is not set, resuming will not be supported.
#
# Parameter 1: The prefix of the command for resuming. The name of the step that
#              failed will be appended to the prefix when an error occurs.
################################################################################
function stepper_set_resume_command() {
  STEPPER_RESUME_COMMAND="${1}"
}

################################################################################
# Outputs a command, if the output of commands is enabled.
#
# Parameter 1: The complete command to execute.
################################################################################
function stepper_print_command() {
  if [[ "true" == "${STEPPER_SHOW_COMMANDS}" ]]; then
    stepper_print "> ${1}"
  fi
}

################################################################################
# Adds a step.
#
# Parameter 1: The name of the step (used for resuming, if enabled).
# Parameter 2: The message that will be displayed to the user for this step.
# Parameter 3: The complete command to execute.
# Parameter 4: The path for stdout redirection (default: /dev/nul).
#              If parameter 3 is not defined, this path will also be used for
#              redirecting stderr.
# Parameter 5: The path for stderr redirection.
################################################################################
function stepper_add_step() {
  # Add the step to the steps arrays
  local index=${#STEPPER_STEP_NAMES[@]}
  STEPPER_STEP_NAMES[${index}]="${1}"
  STEPPER_STEP_MESSAGE[${index}]="${2}"
  STEPPER_STEP_COMMANDS[${index}]="${3}"
  STEPPER_STEP_STDOUTS[${index}]="${4}"
  STEPPER_STEP_STDERRS[${index}]="${5}"
}

################################################################################
# Executes the steps.
#
# Parameter 1: Name of the step to resume from.
################################################################################
function stepper_execute() {
  local resume_from="${1}"

  local message
  local full_command
  local result
  local stdout_file
  local stderr_file
  local total_steps=${#STEPPER_STEP_NAMES[@]}

  local start_index=0
  # In case of resume, find the appropriate step
  if [[ "" != "${resume_from}" ]]; then
    start_index=-1
    for ((i = 0; i < ${total_steps}; ++i)); do
      if [[ "${resume_from}" == "${STEPPER_STEP_NAMES[${i}]}" ]]; then
        start_index=${i}
        stepper_print "Resuming from step $((${i}+1))/${total_steps}."
        break
      fi
    done
    if [[ -1 -eq ${start_index} ]]; then
      stepper_print_error "Could not find step '${resume_from}'."
      return -1
    fi
  fi

  for ((i = ${start_index}; i < ${total_steps}; ++i)); do
    message="${STEPPER_STEP_MESSAGE[${i}]}"
    command="${STEPPER_STEP_COMMANDS[${i}]}"
    stdout_file="${STEPPER_STEP_STDOUTS[${i}]}"
    stderr_file="${STEPPER_STEP_STDERRS[${i}]}"

    if [[ "" == "${stdout_file}" ]]; then
      stdout_file="/dev/null"
    fi

    local full_command
    if [[ "" == "${stderr_file}" ]]; then
      full_command="( ${command} ) > ${stdout_file} 2>&1"
    else
      full_command="( ${command} ) > ${stdout_file} 2> ${stderr_file}"
    fi

    stepper_print "Step $((${i}+1))/${total_steps} - ${message}"

    if [[ "true" == "${STEPPER_SHOW_COMMANDS}" ]]; then
      stepper_print "  Command: ${command}"
    fi
    if [[ "/dev/null" != "${stdout_file}" ]]; then
      stepper_print "  Stdout: ${stdout_file}"
    fi
    if [[ "" == "${stderr_file}" ]]; then
      if [[ "/dev/null" != "${stdout_file}" ]]; then
        stepper_print "  Stderr: ${stdout_file}"
      fi
    else
      stepper_print "  Stderr  : ${stderr_file}"
    fi

    result=0
    eval ${full_command} || result=${?}
    if [[ ! ${result} -eq 0 ]]; then
      stepper_print_error "An error occurred (code ${result}). Please refer to the log file(s) for more information"

      if [[ "" != "${STEPPER_RESUME_COMMAND}" ]]; then
        stepper_print ""
        stepper_print "The execution can be resumed from the failed step with"
        stepper_print "  ${STEPPER_RESUME_COMMAND}${STEPPER_STEP_NAMES[${i}]}"
      fi

      return ${result}
    fi

    stepper_print ""
  done

  return 0
}
