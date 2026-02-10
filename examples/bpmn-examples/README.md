
# BPMN examples

This folder contains small, focused BPMN 2.0 diagrams (Operaton BPM / Camunda 7 flavor) used as reference cases.
Each diagram tries to demonstrate one modeling concept without extra engine-specific configuration.

## Quick index

- [sequence-flow.bpmn](sequence-flow.bpmn): straight-line process (start → tasks → end)
- [xor-gateway-example.bpmn](xor-gateway-example.bpmn): exclusive gateway (XOR) split + merge
- [parallel-gateway-example.bpmn](parallel-gateway-example.bpmn): parallel gateway fork + join
- [multiple-end-events.bpmn](multiple-end-events.bpmn): parallel work ending in different end events
- [concurrent-paths.bpmn](concurrent-paths.bpmn): fan-out concurrency with staged joins
- [conditional-paths.bpmn](conditional-paths.bpmn): optional paths modeled via XOR gateways
- [embedded-sub-process.bpmn](embedded-sub-process.bpmn): expanded embedded subprocess inside parallel flow
- [start-events.bpmn](start-events.bpmn): multiple start events (including message starts)
- [boundary-events.bpmn](boundary-events.bpmn): boundary timer events (interrupting + non-interrupting)
- [events-all-kind.bpmn](events-all-kind.bpmn): a grab-bag of event types (event subprocess, boundary error/timer, etc.)
- [compensation.bpmn](compensation.bpmn): compensation throw + compensation handler

## Notes on interpretation

- **Exclusive gateway (XOR)**: exactly one outgoing flow is taken. In practice, you’ll typically add a
	`conditionExpression` on each outgoing flow and set a **default** flow.
- **Parallel gateway (AND)**: forks into multiple tokens and later **waits for all tokens** at the join.
- **Boundary events**:
	- interrupting (default): cancels the attached activity
	- non-interrupting (`cancelActivity="false"`): leaves the activity running and emits an extra token

## Diagrams

### [sequence-flow.bpmn](sequence-flow.bpmn)

Baseline “hello BPMN” with a single path:

- Start event → “First task” → “Second task” → “Third task” → End event.
- Useful as a control example for diagram layout and basic sequence flow behavior.

### [xor-gateway-example.bpmn](xor-gateway-example.bpmn)

Shows how XOR gateways are used to model mutually-exclusive decisions.

- XOR #1 splits into two alternative tasks.
- One branch contains another XOR split.
- All branches merge into a final XOR gateway and end.

Tip: This diagram is structurally correct as BPMN, but it does **not** include any conditions.
In real processes you generally want `conditionExpression`s (JUEL) on outgoing flows and a default flow.

### [parallel-gateway-example.bpmn](parallel-gateway-example.bpmn)

Demonstrates true concurrency (fan-out) and synchronization (join):

- Start → AND-fork into three tasks.
- Two tasks synchronize first (AND-join).
- Their result synchronizes again with the remaining path at the final AND-join.

What to look for: the join gateways only pass when they have received **all required tokens**.

### [multiple-end-events.bpmn](multiple-end-events.bpmn)

Shows that a process can legitimately have multiple end events when different branches represent
different completion outcomes.

- AND-fork into three branches.
- Two branches synchronize and end in “Part A completed”.
- Third branch ends independently in “Part B completed”.

Important semantic: reaching an end event ends **that token**; with parallelism you can end different
paths in different ends (depending on engine behavior and modeling intent).

### [concurrent-paths.bpmn](concurrent-paths.bpmn)

A slightly more realistic concurrency example with staged joins:

- AND-fork into three branches: a 2-step branch (`Task 1.1` → `Task 1.2`), plus `Task 2` and `Task 3`.
- `Task 2` and `Task 3` synchronize first (AND-join).
- That joined token then synchronizes with `Task 1.2` at a final AND-join and ends.

This is a good diagram to explain “join placement matters”: joining early vs. late changes how long
the process waits.

### [conditional-paths.bpmn](conditional-paths.bpmn)

Models “optional” work using XOR gateways:

- Start → “Common task” → XOR split into optional tasks A/B/C.
- Tasks A and B reconverge via an XOR gateway, run an unnamed task (a placeholder), and then merge
	with the C path at another XOR gateway.
- Ends with another “Common task”.

What to look for:

- Without `conditionExpression`s on the split, this is not a *real* condition-based model yet.
- The unnamed task is a useful reminder: always name tasks that should show up in history/UI.

### [embedded-sub-process.bpmn](embedded-sub-process.bpmn)

Demonstrates an **embedded subprocess** (expanded) as one branch of a parallel split.

- AND-fork into two standalone tasks plus an embedded subprocess.
- The embedded subprocess has its own internal Start → Task → Task → End.
- The outer process synchronizes after all branches complete.

Use this to explain: an embedded subprocess is still part of the same process instance, but provides
structure, scoping, and clearer diagrams.

### [start-events.bpmn](start-events.bpmn)

Shows multiple start events and how you can converge them into a shared path.

- One plain start event and **two message start events** (root-level `bpmn:message` definitions).
- Each start path writes a `startType` variable using `camunda:inputOutput` on an intermediate throw.
- All paths merge at an XOR gateway and finish on a single end event.

If you run this in an engine, the message starts are triggered by correlating the given message name.

### [boundary-events.bpmn](boundary-events.bpmn)

Boundary timer patterns (interrupting + non-interrupting) attached to activities.

Highlights:

- A parallel split includes a normal task, another task, and an embedded subprocess.
- **Interrupting boundary timer** on the task and on the subprocess: diverts control to a gateway.
- **Non-interrupting boundary timers** on the task (`cancelActivity="false"`): create extra tokens.
- A small XOR “collector” gateway merges the non-interrupting boundary paths to an end event.

This diagram is ideal for explaining the difference between “timeout cancels work” vs.
“timeout triggers additional actions while work continues”.

### [events-all-kind.bpmn](events-all-kind.bpmn)

An “event zoo” to showcase multiple event types in one place:

- Main flow forks into a normal task branch and an embedded subprocess branch.
- The embedded subprocess includes:
	- an internal boundary **error** event
	- an external boundary **timer** event attached to the subprocess
	- an external boundary **error** event attached to the subprocess
- Demonstrates **event subprocesses**:
	- timer-start event subprocess (interrupting)
	- timer-start event subprocess marked `isInterrupting="false"` (non-interrupting)
	- error-start event subprocess

This is useful for workshops, but not a recommended “production pattern” to copy verbatim.

### [compensation.bpmn](compensation.bpmn)

Compensation basics:

- Main task has an attached **compensation boundary event**.
- A throw compensation event exists (modeled as an intermediate throw event) that would trigger
	compensation.
- A compensation handler is modeled as a `sendTask` with `isForCompensation="true"`, linked via
	an association.

Tip: Compensation is one of the more subtle parts of BPMN; use this diagram to explain intent and mechanics before applying it in real processes.

