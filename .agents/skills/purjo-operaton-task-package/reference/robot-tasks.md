# Robot task suites

One suite per topic, at the repository root, named after the topic. The task
name equals the topic's `name` in `pyproject.toml`.

## Settings and variables

```robotframework
*** Settings ***
Library     OperatonContracts    OperatonTasks
Library     {{Package}}Client.py

*** Variables ***
${BPMN:TASK}    local                 # purjo overrides; local for dry runs
${studentId}    ${EMPTY}              # every contract input has a default
@{excludedStates}    @{EMPTY}         # list inputs may use @{…}
${dryRun}    ${False}
${api_endpoint}    %{PACKAGE_API_ENDPOINT=}
${api_secret}    Secret:              # Vault value, typed as Secret
```

With `process-variables = false` only template-mapped inputs reach the task;
a missing default makes the task fail on an unset variable. `check` enforces a
declaration for every contract input alias.

Defaults must have the contract's type, because contracts are strict: a plain
`${count}    0` or `${dryRun}    false` is a string and fails validation.
Use `${0}`, `${False}`, `@{EMPTY}`, `&{EMPTY}`, or a typed name
(`${count: int}    0`); `check` rejects untyped defaults for non-string
inputs. Keep each suite default equal to the contract default: the suite
default is what the task sees when the engine omits a variable, the contract
default only pre-fills the template. For manual runs pass typed variables:
`robot -v "dryRun: bool:true" …`.

### What purjo passes from Operaton

- Strings, booleans, and JSON values arrive as Python `str`, `bool`, `list`,
  and `dict`; numbers as `int` or `float` depending on the variable type.
- Operaton `Date` variables arrive as local-time strings like
  `"2024-05-01 00:00:00.000"`. A `date` field with `strict=False` accepts
  midnight values only; an exact `YYYY-MM-DD` validator rejects them. Prefer
  string form fields (`type="string"`) for dates in start forms.
- A `null` process variable arrives as `None`, which overrides the suite
  default and fails strict non-optional fields.

## Inputs

After pre-setting the outputs (see [Outputs](#outputs)), the first step of
every task validates and normalizes its inputs:

```robotframework
${input}=    Validate Task Input    RescindStudyRightsInput
```

Invalid input fails with a message whose first line is `InvalidTaskInput`,
then one `alias: problem (got value)` line per variable. purjo uses the first
line as the BPMN `errorCode`, so with `on-fail = "ERROR"` an error boundary
event with code `InvalidTaskInput` catches it.

Afterwards use `${input}[alias]`, never the raw `${alias}`. Type checks, ID
trimming and deduplication, and non-empty checks belong in the contract, not
in `Should Be True isinstance(...)` steps. `check` enforces the call with the
topic's input contract.

## Outputs

```robotframework
Get Current Study Rights
    VAR    ${studyRights}=    ${None}    scope=${BPMN:TASK}
    ${input}=    Validate Task Input    GetCurrentStudyRightsInput
    …
    VAR    ${studyRights}=    ${rows}    scope=${BPMN:TASK}
```

purjo returns variables set with `scope=${BPMN:TASK}`. By convention set them
in the task body, where `check` enforces a `VAR` with a real value per
contract output alias; the `${None}` placeholder does not count.

Set every output to `${None}` as the task's first step. Operaton evaluates
the template's output mappings (`${alias}`) before a BPMN error reaches its
boundary event; an output the failed task never set makes propagation fail
with `ENGINE-13033` and an incident. purjo 1.0rc2+ stores the task-scope
variables of a failed task as local variables, so the pre-set outputs map
to `null` (or to the value set before a later step failed) and the
boundary event is reached.

## Read tasks

Validate inputs, call one library keyword that runs a static query, validates
rows, and returns JSON-ready dicts; set the output.

## Write tasks

```robotframework
Rescind Study Rights
    VAR    ${result}=    ${None}    scope=${BPMN:TASK}
    ${input}=    Validate Task Input    RescindStudyRightsInput   # bool dryRun, clean non-empty IDs
    ${rows}=    Fetch Study Rights By IDs    ${endpoint}    ${secret}    ${input}[studyRightIds]
    @{returnedIds}=    Create List
    FOR    ${row}    IN    @{rows}
        Append To List    ${returnedIds}    ${row}[studyRightId]
        Should Be Equal    ${row}[termRegistrationState]    ACTIVE
    END
    Lists Should Be Equal    ${returnedIds}    ${input}[studyRightIds]    ignore_order=True
    ${apiResult}=    Rescind Study Rights    …    ${rows}    …    ${input}[dryRun]
    VAR    ${result}=    ${apiResult}    scope=${BPMN:TASK}
```

- Pass validated **rows**, not raw IDs, to the write keyword.
- `${result}` = `{<requestKey>: payload, statusCode, statusBody}`; with
  `dryRun` the request is not sent, `statusCode` is `-1`, and
  `statusBody` is `None`.
- Use BuiltIn/Collections (`Create List`, `Append To List`,
  `Should Be Equal`) before writing keywords.

## Libraries

`@library(auto_keywords=False)` with explicit `@keyword("Title Case Name")`.
Credential parameters are typed `Secret` and rejected when plain strings.
HTTP clients build their own opener (no environment proxies unless intended),
allow `http://` only for loopback, and raise on non-2xx, API errors, and
malformed payloads.
