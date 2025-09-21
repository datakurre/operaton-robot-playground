<!-- Syntax: https://myst-parser.readthedocs.io/ -->

# Operaton Robot Playground

Welcome to this opinionated documentation for orchestrating [Robot Framework](https://robotframework.org/) test or task suites with [Operaton](https://operaton.org/) BPM engine. The documentation was introduced for a workshop at [RoboCon.io](https://robocon.io/) Helsinki 2025.

This documentation accompanies a playground, which you can open in [GitHub Codespaces](https://codespaces.new/datakurre/operaton-robot-playground).

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/datakurre/operaton-robot-playground)

![Screenshot of GitHub Codespaces](./README.png)


## RoboCon.io 2025

The workshop aims to provide a basic understanding of BPMN and its capabilities in orchestrating Robot Framework test or task suites using the Operaton BPM engine. Participants will gain the knowledge needed for further self-study, experimentation, and informed decision-making on integrating these tools into their own projects.

| Time          | Activity                              |
|---------------|---------------------------------------|
| 9.00          | Welcome                               |
|               | **[Introduction to BPMN](bpmn/index.md)**      |
| Break         |                                       |
|               | **[Operaton Robot Playground](playground/index.md)**      |
|               | **[Basic modeling exercises](modeling/index.md)** |
| Break         |                                       |
|               | **[Advanced BPMN concepts](bpmn/advanced.md)** |
|               | **[Modeling for execution](operaton/index.md)** |
|               | **[BPMN with Robot Framework](purjo/index.md)** |
| 12.45--13.30  | Lunch                                 |
|               | **[BPMN with Robot Framework](purjo/index.md)** |
|               | **[Using BPMN and robot for system tests](tests/index.md)** |
|               | Executing and adapting examples       |
| Break         |                                       |
|               | Hands-on exercises                    |
| Break         |                                       |
|               | Discussion and future plans           |
| 17.00         | Workshop ends                         |


## Preparations

The workshop playground has been tested with GitHub Codespaces, but with some effort, you can also run it locally. Check [Getting Started](https://github.com/datakurre/operaton-robot-playground#getting-started) at [the playground repository](https://github.com/datakurre/operaton-robot-playground) for instructions on how to get the playground environment up and running.


## Index

```{toctree}
:maxdepth: 1

bpmn/index.md
playground/index.md
modeling/index.md
bpmn/advanced.md
operaton/index.md
purjo/index.md
tests/index.md
bpmn/juel.md
```
