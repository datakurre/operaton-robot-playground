
# Compensation example (BPMN “teardown”)

This example shows how to model **test setup + optional manual steps + guaranteed teardown** using **BPMN compensation**.

The key trick is: instead of drawing the teardown on the normal sequence flow, you mark dedicated activities as **compensation handlers** (`isForCompensation="true"`) and then **throw compensation** at the end (here: by using end events with a `compensateEventDefinition`).

## What’s in the diagram

The executable pool is **System Test** (process id: `example-test-with-compensation`). There is also a second participant **SUT** used only for documentation; the message flows show where the test interacts with the system under test.

### Main flow (happy-path structure)

1. **Start: “Test triggered”**
2. **Service Task: “Simulate SUT”** (External Task)
	- Topic: `Simulate SUT`
	- Implemented in Robot Framework task `Simulate SUT` (see [hello.robot](hello.robot)).
	- It sets process variable `requireManual` (boolean) to control the next gateway.
3. **Gateway: “Test Case requires manual steps?”**
	- If `${requireManual == true}`: a **User Task** “Execute manual tests” is created.
	- Else: it skips straight to the merge.
4. **Gateway: merge**
5. **Gateway: “Test passed?”**
	- In this example the “Yes” condition is `${false}` (a placeholder), so the default path “No” is taken.
	- Replace this with a real condition (e.g. `${passed == true}`) if you want a real pass/fail split.
6. **End event: “Test passed” / “Test failed”**
	- Both end events contain a **compensation throw** (`compensateEventDefinition`).
	- That means: reaching either end event triggers compensation for all completed activities that have a compensation handler.

### Compensation wiring (the teardown)

This process defines two compensation handlers:

- **Teardown for the automated SUT simulation**
  - Boundary compensation event attached to “Simulate SUT”.
  - Associated handler task: **“Revert simulation”** (External Task, `isForCompensation="true"`).
  - Topic: `Simulate SUT Teardown`.

- **Teardown for the manual test step**
  - Boundary compensation event attached to “Execute manual tests”.
  - Associated handler task: **“Revert manual tests”** (User Task, `isForCompensation="true"`).

When compensation is thrown, handlers run in **reverse completion order** (so if manual tests happened, “Revert manual tests” is triggered before “Revert simulation”).

### Exceptional paths still trigger teardown

There are two interrupting event subprocesses that both end by throwing compensation:

- **Timeout**: “Test timed out” timer start (`P7D`) → “Set Test Failure Reason” → end event “Test failed due to timeout” (throws compensation).
- **Unexpected error**: error start → “Set Test Failure Reason” → end event “Test failed due to error” (throws compensation).

These are here to demonstrate that you can **centralize cleanup** (compensation) even when the process ends via different failure paths.

## Robot / Purjo mapping

Topic-to-task mapping lives in [pyproject.toml](pyproject.toml):

- `Simulate SUT` → Robot task `Simulate SUT`
- `Simulate SUT Teardown` → Robot task `Simulate SUT Teardown`

Those strings must match the BPMN service task topics exactly.

## Variables used

- `requireManual` (process variable): controls whether the manual user task is created.
- `failureReason` (process variable): set by the event subprocesses.
- `errorCode` / `errorMessage` (process variables): populated by the BPMN error start event (engine-specific).

## Run it

From the repo root (starts Operaton + workers, depending on your playground setup):

- `make start`

From this example directory:

- `pur run example-compensation.bpmn`
- `pur serve .`

Then watch the instance in Cockpit/Tasklist:

- If `requireManual` becomes true, you’ll get a task **“Execute manual tests”**.
- When the process ends, compensation triggers the teardown handlers (notably **“Revert simulation”**).

