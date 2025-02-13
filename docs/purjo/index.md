# BPMN with Robot Framework

After learning the [basics of BPMN modeling](../bpmn/index.md) and how to [model for execution with Operaton](../operaton/index.md), it should be clear that external {BPMN}`../bpmn/service-task` **Service Task** is the most flexible way to orchestrate [Robot Framework](https://robotframework.org/) test or task suites with BPMN, using the [Operaton](https://operaton.org/) BPM engine.

```{tip}
The playground ships with a [dedicated plugin](https://github.com/datakurre/camunda-modeler-robot-plugin) for rendering external {BPMN}`../bpmn/service-task` **Service Task** elements with a word *robot* in their *ID* with {BPMN}`../bpmn/robot-task` **robot icon**.
```


## Introducing `pur`(jo)

[`pur`(jo)](https://pypi.org/project/purjo/) is an experimental command line tool for orchestrating [Robot Framework](https://robotframework.org/) test or task suites with the [Operaton](https://operaton.org/) BPM engine. It long-polls external service tasks from the Operaton engine, executes mapped Robot Framework test and task suites with the [uv](https://docs.astral.sh/uv/) Python environment manager, and finally reports the results or errors back to the engine.

```console
$ pur
Usage: pur [OPTIONS] COMMAND [ARGS]...

pur(jo) is a tool for managing and serving robot packages.

╭─ Commands ───────────────────────────────────────────────────────────────╮
│ serve   Serve robot.zip packages (or directories) as BPMN service tasks. │
│ init    Initialize a new robot package into the current directory.       │
│ wrap    Wrap the current directory into a robot.zip package.             │
│ run     Deploy process resources to BPM engine and start a new instance. │
│ bpm     BPM engine operations as distinct sub commands.                  │
╰──────────────────────────────────────────────────────────────────────────╯
```

```{tip}
Before trying out `pur`(jo) in the playground, first start the Operaton BPM engine with the `make start` command in the terminal.
```


## "Hello World" for `pur`(jo)

To get started, create a new directory for your bot:

```console
$ mkdir hello-world
$ cd hello-world
```

Then initialize the directory with `pur`(jo):

```console
$ pur init
```

This would create a new `hello-world` directory with the following files:

* `.python-version` - Python version
* `pyproject.toml` - Python dependencies and topic mapping
* `uv.lock` - `uv` dependency lock file
* `hello.bpmn` - example BPMN model for trying out the package
* `Hello.py` - example Robot Framework keyword library
* `hello.robot` - example Robot Framework test suite
* `README.md` - Empty README for your use.

Next, start a new process instance with the example BPMN model:

```console
$ pur run hello.bpmn
```

Then, start the `pur`(jo) worker to execute the Robot Framework test suite:

```console
$ pur serve .
```

Now you should be able to see `pur`(jo) executing the Robot Framework test suite from the current project directory and reporting the results back to Operaton.


## Mapping test and tasks

Every `pur`(jo) project includes `pyproject.toml`, which is a Python project configuration file. For `pur`(jo) projects, it also contains a mapping from BPMN topics to Robot Framework tests or tasks:

```toml
[tool.purjo.topics."My Topic in BPMN"]
name = "My Test in Robot"
on-fail = "ERROR"
process-variables = true
```

In the mapped value, `name` is passed as the argument `-t` to `robot` when executing the Robot Framework. For example, `name = "*"` would run all tests or tasks in the package.

The other two options, `on-fail` and `process-variables` are optional. Option `on-fail` controls the behavior of purjo when the executed robot test or task fails:

* `on-fail = "FAIL"` is the default, which raises on incident at the Operaton engine.

* `on-fail = "COMPLETE"` completes the task at Operatin with success, but sets local task variables `errorCode` and `errorMessage` from the last Robot Framework test or task failure.

* `on-fail = "ERROR"` completes the task at Operatin with a BPMN error, which allows catching the error in BPMN with a {BPMN}`../bpmn/bpmn-error-boundary-event` **BPMN error boundary event**.

Finally, option `process-variables = true` makes purjo to pass all process variables to the Robot Framework test or task as global variables using `--variablefile` command line argument. The default behavior is `false`, which passes only the variables defined in the BPMN task inputs.


## Dependency management

Test and task package dependencies are managed with the `uv` Python environment manager. For example:

```console
$ uv add request
```

would add the `request` Python package to the `pyproject.toml` and update the `uv.lock` files.


## Project packaging

To package the current directory into a deployable `robot.zip` file, use:

```console
$ pur wrap
```

To package an offline-capable `robot.zip`, wrap the package with:

```console
$ pur wrap --offline
```

This will include `uv`'s project-specific `.cache` directory in the package. Packages with `.cache` can be executed with `uv`'s `--offline` flag, utilizing the packaged cache.


## Development helpers

`pur`(jo) is designed to support fast iterations while developing Robot Framework test and task packages to be orchestrated with BPM. The following commands should be helpful:

* `pur init` initializes a new project in the current directory.
* `pur bpm deploy <RESOURCES...>` deploys given resources as a single multi-file deployment to the Operaton BPM engine.
* `pur bpm start <KEY>` starts a new process instance from the deployed process definition with the given key (*ID* in the modeler, but *Key* in the engine).
* `pur run <RESOURCES...>` is a shortcut for both deploying resources to the BPM engine and starting a new process instance defined in them.
* `pur serve .` serves the project from the current directory as an external BPMN service task worker, following the topic mapping defined in its `pyproject.toml`.

```{tip}
Both `pur bpm start` and `pur run` accept option `--variables`, which accepts a JSON string, a JSON filename or `-` to read JSON from *stdin*. JSON object would then be parse as key-value-pairs into initial process variables for the started process.
```

```{note}
Both `pur bpm deploy` and `pur run` try to migrate previous process versions to the latest version deployed with the command, unless called with the `--no-migrate` flag.
```


## Executing test and task packages

`pur serve <PACKAGES...>` serves the given `robot.zip` packages or directories with developed packages as external BPMN service task workers by following their topic mapping in `pyproject.toml`:

```console
$ pur serve --help

 Usage: pur serve [OPTIONS] ROBOTS...

 Serve robot.zip packages (or directories) as BPMN service tasks.

╭─ Arguments ─────────────────────────────────────────────────────────────────────────────────╮
│ *    robots      ROBOTS...  [default: None] [required]                                      │
╰─────────────────────────────────────────────────────────────────────────────────────────────╯
╭─ Options ───────────────────────────────────────────────────────────────────────────────────╮
│ --base-url             TEXT                   [default: http://localhost:8080/engine-rest]  │
│ --authorization        TEXT                   [default: None]                               │
│ --timeout              INTEGER                [default: 20]                                 │
│ --poll-ttl             INTEGER                [default: 10]                                 │
│ --lock-ttl             INTEGER                [default: 30]                                 │
│ --max-jobs             INTEGER                [default: 1]                                  │
│ --worker-id            TEXT                   [default: operaton-robot-runner]              │
│ --log-level            TEXT                   [default: DEBUG]                              │
│ --on-fail              [FAIL|COMPLETE|ERROR]  [default: FAIL]                               │
│ --help                                        Show this message and exit.                   │
╰─────────────────────────────────────────────────────────────────────────────────────────────╯
```

```{tip}
`pur serve --on-fail=ERROR` would report failed robot executions as BPMN errors, which allows easy routing of execution in BPMN using {BPMN}`../bpmn/bpmn-error-boundary-event` **Error Boundary Events**.
```


## BPMN variables in robot

`pur`(jo) passes BPMN variables defined in external {BPMN}`../bpmn/service-task` **Service Task** inputs to Robot Framework execution as global variables using `--variablefile` command line argument.

Therefore, robot variable `${message}` in the following robot suite

```robotframework
*** Variables ***

${message}    Hello World

*** Test Cases ***

Log message
    Log    ${message}
```

would be replaced with the value of local variable `message` defined in the {bpmn}`../bpmn/service-task` **Service Task** inputs.


## Robot variables to BPMN

Robot Framework as such does not have a concept of output or result variables. In other words, there is no single right way of defining, what should e returned back to BPM engine.

At first, `pur`(jo) always returns `log.html` and `output.xml` files are local task variables into engine. On error, `pur`(jo) returns also the last Robot Framework test or task failure as local `errorCode` and `errorMessage` variables or Operaton incident or BPMN error arguments.

For custom variables, `pur`(jo) extends Robot Framework variable scope with two new scopes: `BPMN:TASK` and `BPMN:PROCESS`. These scopes are used in robot test or task suites to define variables, which should be returned back to BPMN engine. For example:

```robotframework
*** Test Cases ***

Set BPMN variable
    VAR    ${message}    Hello World!    scope=BPMN:TASK
```

would set a BPMN variable `message` with value `Hello World!` for the current task scope in Operaton. This variable could then be exported from task to process scope with [task outputs](../operaton/index.md#inputs-and-outputs).

Unfortunately, `scope=BPMN:TASK` is not valid robot syntax, because of undefined scope. Therefore, `pur`(jo) supports the following pattern, where `${BPMN:TASK}` variable with valid default value is used instead. `pur`(jo) would then replace the default value with its custom scope when executing robot.

This would be valid robot syntax, that would also return a BPMN variable when executed with `pur`(jo):

```robotframework
*** Variables ***

${BPMN:TASK}    local

*** Test Cases ***

Set BPMN variable
    VAR    ${message}    Hello World!    scope=${BPMN:TASK}
```

Simlarly, the following example would set the variables direcly onto process scope, not requiring definition of task outputs in the BPMN task:

```robotframework
*** Variables ***

${BPMN:PROCESS}    local

*** Test Cases ***

Set BPMN variable
    VAR    ${message}    Hello World!    scope=${BPMN:PROCESS}
```

```{warning}
If a variable is defined in input mapping, `scope=${BPMN:PROCESS}` cannot pass the variable back to the process scope, but only updates the variable in the task scope instead. Therefore output mapping is still required for passing variables back to the process scope.
```


## Handling failures

Handling orchestrated Robot Framework test or task failures in BPMN may have different requirements in different processes. In task automation, for example, unexpected failure should usually halt the process for manual investigation (by rising a new incident at Operaton engine). In test automation, such failures are usually expected and it is enough to tear down the test environment and report the failure.

In Operaton engine an external {BPMN}`../bpmn/service-task` **Service Task** can fail in three main ways:

* Task worker reports the task as **failed without retry instructions**, which creates manually managed incident at the engine.

* Task worker reports the task as **completed with BPMN error**, which allows catching the error redirecting the process automatically in the process flow with {BPMN}`../bpmn/bpmn-error-boundary-event` **BPMN error boundary event**.

* Task worker reports the task as **successfully completed, but with BPMN error throw expression**, which could then be caught and redirected in the process flow using {BPMN}`../bpmn/bpmn-error-boundary-event` **BPMN error boundary event**.

  ![Conditional BPMN error definition](./conditional-error.png)

For handling these different failure types, `pur serve` has option `--on-fail=FAIL|COMPLETE|ERROR` to configure how failed robot executions are reported back to the engine, unless task have topic specific configuration in `pyproject.toml`.

By the default value, `FAIL`, `pur serve` reports failed robot executions as failed tasks without automated instructions, creating incidents to be manually hangled at the engine. (Note: `pur`(jo) should eventually support configuration settings allowed per listened topic.)

With `COMPLETE`, failed robot executions are reported as successfully completed tasks, but two local task variables `errorCode` and `errorMessage`. These variables are `null` on Robot Framework PASS. On Robot Framework FAIL, `errorCode` contains the first line of the last Robot Framework test or task failure, and `errorMessage` contains the rest. This allows configuring an throw expression BPMN when `errorCode` has a value.

With `ERROR`, failed robot executions are reported as completed tasks with a BPMN error, which allows redirecting the process with a {BPMN}`../bpmn/bpmn-error-boundary-event` **BPMN error boundary event** or capturing all errors with an event-based subprocess with an error start event.

![BPMN error on Robot Framework failure](./complete-error.png)

```{note}
To be more complete, external {BPMN}`../bpmn/service-task` **Service Task** can also fail in two other ways:

* Task worker reports the task as failed, but with retry timeout as automated retry instrutions, and the task will be automatically and silently retried by the engine later.

* Task worker disappears after locking the task and before completing it, and the task will be automatically released for a retry by another worker later.
```
