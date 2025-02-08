# BPMN with Robot Framework

After learning the [basics of BPMN modeling](../bpmn/index.md) and how to [model for execution with Operaton](../operaton/index.md), it should be clear that external {BPMN}`../bpmn/service-task` **Service Task** is the most flexible way to orchestrate [Robot Framework](https://robotframework.org/) test or task suites with BPMN, using the [Operaton](https://operaton.org/) BPM engine.

```{tip}
The playground ships with a [dedicated plugin](https://github.com/datakurre/camunda-modeler-robot-plugin) for rendering external {BPMN}`../bpmn/service-task` **Service Task** elements with a word *robot* in their *ID* with {BPMN}`../bpmn/robot-task` **robot icon**.
```

## Introducing `pur`(jo)

[`pur`(jo)](https://pypi.org/project/purjo/) is an experimental command line tool for orchestrating [Robot Framework](https://robotframework.org/) test or task suites with the [Operaton](https://operaton.org/) BPM engine. It consumes external service tasks from the Operaton engine by executing Robot Framework test and task suites with the [uv](https://docs.astral.sh/uv/) Python environment manager and reporting the results back to the engine.

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

## Hello `pur`(jo)

To get started, create a new directory for your bot:

```console
$ mkdir hello-world
$ cd hello-world
```

Then initialize the directory with `pur`(jo):

```console
$ pur init
```

This will create a new `hello-world` directory with the following files:

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

Finally, you should be able to see `pur`(jo) executing the Robot Framework test suite from the current directory and reporting the results back to Operaton with:

```console
$ pur serve .
```

## BPMN topics to Robot Framework

`pyproject.toml` is a Python project configuration file, which also contains a mapping from BPMN topics to Robot Framework tests or tasks:

```toml
[tool.purjo.topics]
"My Topic" = { name = "My Task" }
```

In the mapping, `name` is passed as the argument `-t` to `robot` when executing the Robot Framework. For example, `{ name = "*" }` would run all tests or tasks in the package.

## Dependencies and packaging

Test and task package dependencies are managed with the `uv` Python environment manager. For example:

```console
$ uv add request
```

would add the `request` Python package to the `pyproject.toml` and update the `uv.lock` files.

To package the current directory into a deployable `robot.zip` file, use:

```console
$ pur wrap
```

To package an offline-capable `robot.zip`, wrap the package with:

```console
$ pur wrap --offline
```

This will include `uv`'s project-specific `.cache` directory in the package. Packages with `.cache` can be executed with `uv`'s `--offline` flag, utilizing the packaged cache.

## Developing with `pur`(jo)

`pur`(jo) is designed to support fast iterations while developing Robot Framework test and task packages to be orchestrated with BPM. The following commands should be helpful:

* `pur init` initializes a new project in the current directory.
* `pur bpm deploy <RESOURCES...>` deploys given resources as a single multi-file deployment to the Operaton BPM engine.
* `pur bpm start <KEY>` starts a new process instance from the deployed process definition with the given key (*ID* in the modeler, but *Key* in the engine).
* `pur run <RESOURCES...>` is a shortcut for both deploying resources to the BPM engine and starting a new process instance defined in them.
* `pur serve .` serves the project from the current directory as an external BPMN service task worker, following the topic mapping defined in its `pyproject.toml`.

```{note}
Both `pur bpm deploy` and `pur run` try to migrate previous process versions to the latest version deployed with the command, unless called with the `--no-migrate` flag.
```

## Serving with `pur`(jo)

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

## BPMN Variables in Robot Framework

`pur(jo)` passes BPMN variables defined in external {BPMN}`../bpmn/service-task` **Service Task** inputs to Robot Framework execution as global variables using `--variablefile` command line arguments.
