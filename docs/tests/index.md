# Towards system testing

Below is a slightly derived version of a real system test orchestrated with BPMN. Next, we look into selected BPMN features used in detail.

```{bpmn-figure} example-full
```

## Pools and lanes

Pools and lanes within pools are purely visual features of BPMN and do not affect execution of the process in the Operaton engine. 

Pools and lanes can be used to separate different roles or organizations in the process, and visualise communication between systems.

```{bpmn-figure} example-pools

In the example, pools are used to separate the process engine driven orchestration from the systems under test, and highlight the possible manual steps required by QA team.
```

## Event sub processes

Event sub processes with interrupting start events could be used to handle process wide events.

```{bpmn-figure} example-events

In the example, event subprocesses are used to

* limit test execution time by cancelling test cases with a timer event.

* handle test case failures by catching any unhandled error event.

```

## User tasks and compensation

In the real world system tests especially when involving 3rd party or legacy systems, not all tests can be automated. BPMN orchestrated test processes may contain manual steps when required. Also manual test setup teardowns can be orchestrated with compensation tasks.

```{bpmn-figure} example-compensation
{download}`example-compensation.bpmn`
```