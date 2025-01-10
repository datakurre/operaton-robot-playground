# BPMN basics by examples

Business Process Model and Notation (BPMN) is a graphical representation for specifying business processes in a business process model [{sup}`Wikipedia`](https://en.wikipedia.org/wiki/Business_Process_Model_and_Notation).

This is an opinionated introduction to some of the most common BPMN 2.0 symbols and their use.

## Sequence flow

```{bpmn-figure} sequence-flow
BPMN sequence flow is made of at least one {bpmn}`start-event` **start event**, {bpmn}`end-event` **end event** and any amount of {bpmn}`task` **tasks** (BPMN activities) in connection between them. {download}`sequence-flow.bpmn`
```

```{attention} ADD MORE EXAMPLES
```


## Naming of elements

```{bpmn-figure} sequence-flow-annotated
BPMN flow elements are named by using their process' business domain terms. Events are named to describe business state of the process. Tasks (BPMN activities) are named using verbs to describe what to do in the process. {download}`sequence-flow-annotated.bpmn`
```

## Gateways and paths

```{bpmn-figure} gateways-and-paths
BPMN gateways control which one of the available paths is taken at the time of execution. {bpmn}`exclusive-gateway` **exclusive gateway** in the example allows only one path at time to be followed at time (either to split or join the flow). {download}`gateways-and-paths.bpmn`
```

## Concurrent tokens

```{bpmn-figure} concurrent-tokens
BPMN token is a theoretical concept that is used as an aid to define the behavior of a process that is being performed. There can be any amount of concurrent tokens in a single running process. For example, {bpmn}`parallel-gateway` **parallel gateway** creates a new token for each outgoing path. Only when all tokens have been consumed, process is really completed. {download}`concurrent-tokens.bpmn`
```

## Multiple end events

```{bpmn-figure} multiple-end-events
Not all BPMN tokens need to reach the same {bpmn}`end-event` **end event** for the process to complete. BPMN process may have as many end events as it makes sense for the business processs it describes. Not all end events need to be reached for the process to complete, but process completes when there are no more tokens alive. {download}`multiple-end-events.bpmn`
```

## Events at boundary

```{bpmn-figure} boundary-events
Attaching events to task boundaries is where BPMN super powers really begin. In this example, a {bpmn}`non-interrupting-timer-boundary-event` **non-interrupting timer boundary event** is used to send reminders about incomplete tasks. Non-interrupting events, by their name, don't interrupt the task, which they are connected to. Instead, they create a new token for the path they start (in the example, regularly as long as the task has not been completed). {download}`boundary-events.bpmn`
```

## Errors at boundary

There are two kind of errors in process automation:

* **Application errors**, which are caused by technical issues like network outages or programming errors, and are fixed by retrying the failing part of the process once the technical issue has been solved.

* **Business errors**, which are known exceptions in the process itself, and cannot be fixed by simply retrying, but must be expected and handled on the BPMN diagram level instead.

```{bpmn-figure} boundary-bpmn-error
In this example, a business error is being expected with {bpmn}`bpmn-error-boundary-event` **error boundary event** (which is always interrupting), and it is used to route the process to alternative end event. {download}`boundary-bpmn-error.bpmn`
```

## Embedded sub-process

```{bpmn-figure} embedded-subprocess
**Embedded sub-process** looks like a process with its own {bpmn}`start-event` **start event** and {bpmn}`end-event` **end event**(s) within its host process. It is a powerful pattern to use  for wrapping tasks, which should share some boundary events. In this example, an {bpmn}`interrupting-timer-boundary-event` **interrupting boundary timer event** is used to cancel the whole sub-process. {download}`embedded-subprocess.bpmn`
```
```{note}
The  example above could also be implemented with use of multiple boundary events task. But how would this change the behavior?
```{bpmn-image} multiple-boundary-events
```

## Event sub-process

```{bpmn-figure} event-subprocess
**Event sub-process** can either interrupt the execution of the main process (with interrupting start event) or run sub-processes in parallel to the main process (with non-interrupting start event). The example does latter with a {bpmn}`non-interrupting-timer-subprocess-start-event` **non-interrupting start timer event**.
{download}`event-subprocess.bpmn`
```

## Basic task types

The examples above, use only so called {bpmn}`task` **undefined task**. It is useful in drafting and documenting processes, but not really in actually implementing and automating the processes. Obviously, there are many more concrete task types.


### Service task

```{bpmn-figure} service-task
**Service task** {bpmn}`service-task` represents automated task. All {bpmn}`robot-task` **Robot Framework** automation tasks are service tasks.
```

### Service task (custom)

```{bpmn-figure} robot-task
Now that {bpmn}`service-task` **service task** has become the core component in process automation, it has also become a thing to customize its symbol to make it easier to reconize service tasks by some categorization. So, when you see a task element with weird symbol, like {bpmn}`robot-task` **Robot Framework** logo, it is safe to assume that it is a service task with just a custom symbol.
```

### Call activity

```{bpmn-figure} call-activity-task
**Call activity** {bpmn}`call-activity-task` calls a such configured sub-process, which is defined separately from the main process (unlike embedded sub-process). It allows to abstract recurring parts of process into re-usable sub-processes (while cleaning up clutter.
```

```{attention} MAKE THIS A STANDALONE EXAMPLE:
```

```{bpmn-figure} call-activity-process
In this example, {bpmn}`call-activity-task` **Call activity** is used to hide the embedded sub-process details, which have been shown in the earlier examples.
{download}`call-activity-process.bpmn`
```


### User task

```{bpmn-figure} user-task
**User task** {bpmn}`user-task` is a task, which is meant to be completed by a human through a connected user interface. Most common way to implement a user task is to show the user a form.
```
