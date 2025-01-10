# Advanced BPMN concepts

## Alternative start events

```{bpmn-figure} more-start-events
While the plain {bpmn}`../bpmn/start-event` **start event** could be triggered through APIs to start processes in custom ways, also BPMN itself supports multiple ways to start processes. For example, {bpmn}`../bpmn/timer-start-event` **timer start event** can start a new process instance periodically, or {bpmn}`../bpmn/message-start-event` **message start event** from a BPMN message (even from an another process instance). {download}`more-start-events.bpmn`
```

## Intermediate events

```{bpmn-figure} intermediate-events
In addition to start and end events, BPMN has {bpmn}`../bpmn/intermediate-throw-event` intermediate (throw) events too. The most simply use case for them, is to use empty intermediate throw events to mark relevant business states in the process (as metrics like KPIs in later data analysis). {download}`intermediate-events.bpmn`
```

## Multi-instance

```{bpmn-figure} multi-instance-subprocess
**Tasks** and **embedded sub-processes** can be configured to be **multi-instance** -- the BPMN way to loop over a collection. The configuration can be either {bpmn}`../bpmn/parallel-multi-instance` **parallel** or {bpmn}`../bpmn/sequential-multi-instance` **sequential**. Multi-instance requires an input collection to be configured for it, but then it executes task or sub-process separately for every input item in the collection with one BPMN symbol. {download}`multi-instance-subprocess.bpmn`
```

## Business rule task

```{bpmn-figure} business-rule-task
**Business rule task** {bpmn}`../bpmn/business-rule-task` is a special task type reserved for automated rule-based decision making in a process. It's typically configured to use DMN (Decision Model and Notation) decision tables, designed to describe business rules. In addition, DMN tables can be maintained separately from the process models, for example, to allow faster iterations.
```

This imaginary bus ticket pricing is an example, in which decision table should be superior to possible alternatives, like "just coding it":

```{dmn-html} bus-ticket-price
```
{download}`bus-ticket-price.dmn`