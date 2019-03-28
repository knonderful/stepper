# Stepper

## The problem

Consider a build script that does the following:

* Check out a Git repository that contains the source code for the target application.
* Initialize CMake.
* Compile the code.
* Build the documentation.
* Execute unit tests.
* Build a software package.
* Install the software package on a staging environment.
* Execute integration tests.
* Publish the software package on a public server.

If all the output of each individual step would just be written to the terminal the user (even an expert) will quickly get swamped with output, since each individual step will normally be rather verbose.
It will be hard for the user to tell, when looking at a running execution of such a script, what the progress is.
Additionally, if something goes wrong it will be hard to tell in which context this happened.
It can even happen that the terminal history is too short to contain all the valid information and that important information can not be retrieved.

Another common problem with such scripts is that the user will have to re-run the entire script again from the start in case of a failure, as there is usually no functionality embedded to allow for the user to resume from some point.
Even if the indivdual steps theoretically support it and the user knows from where to continue, it is unlikely that he will want to execute the remaining commands "by hand" in order to avoid having to wait for the passed steps.

## The solution

Stepper is a small Bash library for executing commands in separated steps.
Its goal is to make it easier for the author of a (potentially) multi-step script to divide the execution into separated steps.

Each step is specifically added before any of the steps get executed.
A step is consists of:

* A name.
  * This is used in case the execution fails and the user wants to resume from the last step.
* A message.
  * This is a small text that is displayed to the user when the step is started.
* A standard-output redirect.
  * This is the file to which the standard output will be written.
* An error-output redirect.
  * This is the file to which the error output will be written.
* A command.
  * This is the command that will be executed for the step.

Once the steps have been defined, they can be executed.
Stepper will execute them in sequence and will present the user with only the relevant information.
If a step produces an error, Stepper will abort the execution and present the user with suggestions to follow-up actions, such as inspecting log files and a command for resuming the execution at a later point.

Additionally, Stepper supports resuming the execution from the last failed step.
Of course, this requires that each step can be executed as long as all preceeding steps have been successfully executed.

Refer to the example in `examples/example.sh` and the in-line method documentation in `lib/stepper.sh` for usage instructions.
