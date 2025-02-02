# Operaton Robot Playground

This repository hosts a playground and documentation for orchestrating [Robot Framework](https://robotframework.org/) test or task suites with [Operaton](https://operaton.org/) BPM engine. The playground was introduced for a workshop at [RoboCon.io](https://robocon.io/) Helsinki 2025.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/datakurre/operaton-robot-playground)

![Screenshot of GitHub Codespaces](./docs/README.png)


## Getting started

To get started, pick any of the following options:

* Open this repository in [GitHub Codespaces](https://codespaces.new/datakurre/operaton-robot-playground).

* Or clone this repository and open it using [VSCode](https://code.visualstudio.com/) [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) [extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).

* Or clone this repository, and install [GNU Make](https://www.gnu.org/software/make/) and [devenv.sh](https://devenv.sh/).

* Or choose your own adventure by manually installing [uv](https://docs.astral.sh/uv/), [purjo](https://pypi.org/project/purjo/) and [Operaton](https://operaton) or other compatible BPM engine.


## Down the rabbit hole

Activate the playground by starting its built-in Operaton build with

```bash
$ make start
✔ Building shell in 6.2s.
• PID is 56105
• See logs:  $ tail -f /workspaces/operaton-robot-playground/.devenv/processes.log
• Stop:      $ devenv processes stop
✔ Starting processes in 6.2s.
```

Next, check if `pur`(jo) is already available

```sh
$ pur --help
```

If not, run `make shell` to manually activate the playground `devenv`shell with `uv` and `pur`(jo) pre-installed, and defauld Python virtualenv activated.


## Hello World

Once you have entered the shell with either `make start shell` or separately `make start` and `make shell`, you should be able to try out the following example:

1. Create directory for your bot

   ```sh
   $ mkdir hello-world
   $ cd hello-world
   $ pur init
   Adding pyproject.toml
   Adding uv.lock
   Adding Hello.py
   Adding .python-version
   Adding README.md
   Adding hello.robot
   ```

2. Deploy and start the example process

   ```sh
   $ pur run hello.bpmn
   Started: http://localhost:8080/operaton/app/cockpit/default/#/process-instance
   ```

3. Serve the example bot

   ```sh
   $ pur serve .
   02-02-2025 14:39:49 | INFO | purjo.runner:267 | purjo | Subscription | My Task
   02-02-2025 14:39:49 | INFO | operaton.tasks.worker:263 | External task worker started.
   ```

![Screenshot of GitHub Codespaces](./docs/operaton.png)
