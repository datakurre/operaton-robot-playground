# BPMN with Robot Framework

After learning the [basics of BPMN modeling](../bpmn/index.md) and how to [model for execution with Operaton](../operaton/index.md), it should be clear that external {BPMN}`../bpmn/service-task` **Service Task** is the most flexible way to orchestrate [Robot Framework](https://robotframework.org/) test or task suites with BPMN, using [Operaton](https://operaton.org/) BPM engine.

```{tip}
The playground ships with a [dedicated plugin](https://github.com/datakurre/camunda-modeler-robot-plugin) for rendering external {BPMN}`../bpmn/service-task` **Service Task** elements with a word *robot* in their *ID* with {BPMN}`../bpmn/robot-task` **robot icon**.
```

## Introducing `pur`(jo)

[`pur`(jo)](https://pypi.org/project/purjo/) is an experimental command line tool for orchestrating [Robot Framework](https://robotframework.org/) test or task suites with [Operaton](https://operaton.org/) BPM engine. It consumes external service tasks from Operaton engine by executing Robot Framework test and task suites with [uv](https://docs.astral.sh/uv/) Python environment manager and reports the results back to the engine.

```console
$ pur
                                                                                                                           
Usage: pur [OPTIONS] COMMAND [ARGS]...                                                                                     
                                                                                                                           
pur(jo) is a tool for managing and serving robot packages.                                                                 
                                                                                                                            
╭─ Commands ───────────────────────────────────────────────────────────────╮
│ serve   Serve robot.zip packages (or directories) as BPMN service tasks. │
│ init    Initialize a new robot package into the current directory.       │
│ wrap    Wrap the current directory into a robot.zip package.             │
│ run     Deploy and start resources to the BPMN engine.                   │
│ bpm     BPM engine operations as distinct sub commands.                  │
╰──────────────────────────────────────────────────────────────────────────╯
```

```{tip}
Before trying out `pur`(jo) in the playground, first start its Operaton engine with the `make start` command in the terminal.
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
* `README.md` - Empty README for your use

Next, start a new process instance the example BPMN model:

```console
$ pur run hello.bpmn
```

Finally, you should be able to see `pur`(jo) executing the Robot Framework test suite from the current directory and reporting the results back to the Operaton with:

```console
$ pur serve .
```

## BPMN topics to Robot Framework

`pyproject.toml` is a Python project configuration file, which also contains a mapping from BPMN topics to Robot Framework test or task:

```toml
[tool.purjo.topics]
"My Topic" = { name = "My Task" }
```

Mapped `name` is passed as `robot -t` argument, when executing the Robot Framework. For exampe `name = "*"` would run all tests or tasks in the package.


## Dependencies and packaging

Test and task package dependencies are managed with `uv` Python environment manager. For example:

```console
$ uv add request
```

will add `request` Python package to the `pyproject.toml` and update `uv.lock` files.

To package the current directory into a `robot.zip` file, use:

```console
$ pur wrap
```

For offline use, wrap the package with:

```console
$ pur wrap --offline
```