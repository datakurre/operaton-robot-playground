# Introduction to BPMN

Business Process Model and Notation (BPMN) is a graphical representation for specifying business processes in a business process model [{sup}`Wikipedia`](https://en.wikipedia.org/wiki/Business_Process_Model_and_Notation).

This is an opinionated introduction to some of the most common BPMN 2.0 symbols and their uses.


## Sequence flow

```{bpmn-figure} sequence-flow
BPMN sequence flow is made up of at least one {bpmn}`start-event` **start event**, one {bpmn}`end-event` **end event**, and any number of {bpmn}`task` **tasks** (BPMN activities) in connection between them. {download}`sequence-flow.bpmn`
```


## Naming of elements

```{bpmn-figure} sequence-flow-annotated
BPMN flow elements should be named using terms from the business domain of the process. Events are named to describe the business state of the process. Tasks (BPMN activities) are named using verbs to describe what actions to take in the process. {download}`sequence-flow-annotated.bpmn`
```


## Gateways and paths

```{bpmn-figure} gateways-and-paths
BPMN gateways control which one of the available paths is taken at the time of execution. The {bpmn}`exclusive-gateway` **exclusive gateway** in the example allows only one path to be followed at a time (either to split or join the flow). {download}`gateways-and-paths.bpmn`
```


## Conditional flows

```{bpmn-figure} sequence-flow-redux
With {bpmn}`exclusive-gateway` **exclusive gateways**, you can direct the flow of the process based on the results from the completed tasks. This already allows you to implement complex workflows beyond the plain `robot`. {download}`sequence-flow-redux.bpmn`
```


## Concurrent tokens

```{bpmn-figure} concurrent-tokens
BPMN token is a theoretical concept used to define the behavior of a process being performed. There can be any number of concurrent tokens in a single running process. For example, a {bpmn}`parallel-gateway` **parallel gateway** creates a new token for each outgoing path. The process is only completed when all tokens have been consumed. {download}`concurrent-tokens.bpmn`
```


## Inclusive gateway

```{bpmn-figure} gateways-inclusive-paths
The {bpmn}`inclusive-gateway` **inclusive gateway** in the example allows multiple paths to be followed simultaneously, depending on the conditions defined. This means that one or more paths can be taken based on the evaluation of the conditions. {download}`gateways-inclusive-paths.bpmn`
```


## Multiple end events

```{bpmn-figure} multiple-end-events
Not all BPMN tokens need to reach the same {bpmn}`end-event` **end event** for the process to complete. A BPMN process may have as many end events as it makes sense for the business process it describes. Not all end events need to be reached for the process to complete; the process completes when there are no more tokens alive. {download}`multiple-end-events.bpmn`
```


## Events at boundary

```{bpmn-figure} boundary-events
Attaching events to task boundaries is where BPMN superpowers really begin. In this example, a {bpmn}`non-interrupting-timer-boundary-event` **non-interrupting timer boundary event** is used to send notification about test execution taking too much time. Non-interrupting events, as their name suggests, don't interrupt the task they are connected to. Instead, they create a new token for the path they start (in the example, once or regularly as long as the task has not been completed). {download}`boundary-events.bpmn`
```

## Errors at boundary

There are two kind of errors in process automation:

* **Application errors**, which are caused by technical issues like network outages or programming errors, and can be fixed by retrying the failing part of the process once the technical issue has been resolved.

* **Business errors**, which are known exceptions in the process itself, and cannot be fixed by simply retrying, but must be expected and handled on the BPMN diagram level instead.

```{bpmn-figure} boundary-bpmn-error
In this example, a business error is expected with a {bpmn}`bpmn-error-boundary-event` **error boundary event** (which is always interrupting), and it is used to route the process to an alternative end event. {download}`boundary-bpmn-error.bpmn`
```


## Embedded sub-process

```{bpmn-figure} embedded-subprocess
**Embedded sub-process** looks like a process with its own {bpmn}`start-event` **start event** and {bpmn}`end-event` **end event**(s) within its host process. It is a powerful pattern to use for wrapping tasks that should share some boundary events. In this example, an {bpmn}`interrupting-timer-boundary-event` **interrupting boundary timer event** is used to cancel the whole sub-process. {download}`embedded-subprocess.bpmn`
```

```{note}
The example above could also be implemented using multiple boundary events on a task. However, this would change the behavior by allowing the task to handle multiple events simultaneously. Each boundary event could trigger different actions or paths, providing more flexibility and complexity in the process flow. 

This approach is useful, however, when a task needs to respond to various conditions or events without interrupting the main process flow.
```{bpmn-image} multiple-boundary-events
```


## Event sub-process

```{bpmn-figure} event-subprocess
**Event sub-process** can either interrupt the execution of the main process (with an interrupting start event) or run sub-processes in parallel to the main process (with a non-interrupting start event). The example does the latter with a {bpmn}`non-interrupting-timer-subprocess-start-event` **non-interrupting start timer event**.
{download}`event-subprocess.bpmn`
```

## Externalized sub-process

```{bpmn-figure} call-activity-process
{bpmn}`call-activity-task` **Call activity** is used to encapsulate and reference a reusable sub-process or another process, allowing for modular and maintainable process designs. In this example, it is used to hide the embedded sub-process details from the earlier examples.
{download}`call-activity-process.bpmn`
```


## Basic task types

The examples above use only the so-called {bpmn}`task` **undefined task**. This is useful for drafting and documenting processes, but not for actually implementing and automating them. There are many more concrete task types available.


### Service task

```{bpmn-figure} service-task
**Service task** {bpmn}`service-task` represents an automated task. All {bpmn}`robot-task` **Robot Framework** tests and tasks are modeled as service tasks.
```


### Service task (custom)

```{bpmn-figure} robot-task
Now that {bpmn}`service-task` **service task** has become the core component in process automation, it has also become usual to customize its symbol to make it easier to recognize service tasks by some categorization. So, when you see a task element with a unique symbol, like the {bpmn}`robot-task` **Robot Framework** logo, it is safe to assume that it is a service task with just a custom symbol.
```


### Call activity

```{bpmn-figure} call-activity-task
**Call activity** {bpmn}`call-activity-task` calls a separately configured sub-process, which is defined outside of the main process (unlike an embedded sub-process). It allows abstraction of recurring parts of a process into reusable sub-processes, thereby reducing clutter.
```


### User task

```{bpmn-figure} user-task
**User task** {bpmn}`user-task` is a task meant to be completed by a human through a connected user interface. The most common way to implement a user task is to show the user a form.
```
