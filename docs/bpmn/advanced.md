# BPMN advanced

This section continues from the [BPMN basics](./index.md) and introduces more advanced BPMN concepts.


## Alternative start events

```{bpmn-figure} more-start-events
While the plain {bpmn}`start-event` **start event** could be triggered through APIs to start processes in custom ways, also BPMN itself supports multiple ways to start processes. For example, {bpmn}`timer-start-event` **timer start event** can start a new process instance periodically, or {bpmn}`message-start-event` **message start event** from a BPMN message (even from an another process instance). {download}`more-start-events.bpmn`
```

The above example introduced the following new event type:

* {bpmn}`message-start-event` **message events**, for sending and receiving targeted messages, e.g. for inter-process communication


## Intermediate events

```{bpmn-figure} intermediate-events
In addition to {bpmn}`start-event` **start event**, {bpmn}`end-event` **end event**, and {bpmn}`boundary-event` **boundary event**, BPMN has {bpmn}`intermediate-throw-event` **intermediate event** too. The simplest use case for them is to use empty intermediate events for marking relevant business states in the process (as metrics like KPIs in later data analysis). {download}`intermediate-events.bpmn`
```


## Even more events

```{bpmn-figure} more-events
Events in BPMN 2.0: start events, interrupting and non-interrupting start events, intermediate throw events, intermediate catch events, interrupting and non-interrupting boundary events, and end events. All in many different types. 
{download}`more-events.bpmn`
```

The above example introduced the following new event types:

* {bpmn}`signal-start-event` **signal event**, for sending and receiving broadcasted signals, e.g. for mass-cancellation of processes
* {bpmn}`conditional-start-event` **conditional event**, for being triggered on a condition, e.g. a process variable value change
* {bpmn}`compensation-event` **compensation event**, for triggering compensation tasks for already completed, but now compensated tasks.


## Multi-instance

```{bpmn-figure} multi-instance-subprocess
**Tasks** and **embedded sub-processes** can be configured to be **multi-instance** -- the BPMN way to loop over a collection. The configuration can be either {bpmn}`parallel-multi-instance` **parallel** or {bpmn}`sequential-multi-instance` **sequential**. Multi-instance requires an input collection to be configured for it, but then it executes task or sub-process separately for every input item in the collection with one BPMN symbol. {download}`multi-instance-subprocess.bpmn`
```

## Script task


```{bpmn-figure} script-task
```

**Script task** {bpmn}`script-task` is a task that allows executing custom scripts directly in the process engine being used. The supported scripting languages depend on the engine but typically include JavaScript, Groovy, or Python (Jython or GraalPy, which has not been implemented yet).

In Operaton BPMN engine, a script task can manipulate multiple process variables using its `execution.setVariable` API, or assign its return value to a single result variable.


## Business rule task

```{bpmn-figure} ./business-rule-task
**Business rule task** {bpmn}`business-rule-task` is a special task type reserved for automated rule-based decision making in a process. It's typically configured to use DMN (Decision Model and Notation) decision tables, designed to describe business rules. Additionally, DMN tables can be maintained separately from the process models, allowing for faster iterations.
```

This test case selection example demonstrates how a business rule task with DMN decision table can be used to select test cases based on the test case selection criteria. Even in this simple example, the DMN table should be compact and easier to maintain than the equivalent conditional logic in classic programming languages.

```{dmn-html} test-case-selection
```
{download}`test-case-selection.dmn`