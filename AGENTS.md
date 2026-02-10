# AGENTS.md

Project instructions for LLM coding agents creating **Robot Framework bots** orchestrated by **Operaton BPM** using **purjo**. `rf-mcp` is available for keyword discovery and stepwise execution help.


## Non‑Negotiables

1. **MUST scaffold new bots with `pur init` (never hand-create files).**
2. **MUST run `pur init` only inside an empty directory.** If not empty: stop, pick a new dir, or ask.
3. **MUST keep BPMN topic == `pyproject.toml` topic mapping** (exact string match).
4. **Python keyword libraries MUST use both decorators:** `@library()` on the class and `@keyword()` on every exposed method.


## New Bot (Golden Path)

```bash
mkdir my-bot
cd my-bot
ls -la
# MUST be empty (only '.' and '..')
pur init
```

Then modify the generated template (do not add new scaffolding unless asked):
- `pyproject.toml` (topic mapping, deps)
- `hello.robot` / `Hello.py` (implement your task, rename)
- `hello.bpmn` (wire BPMN, often add a User Task + form, rename)


## Topic Mapping (`pyproject.toml`)

```toml
[tool.purjo.topics]
"My Topic in BPMN" = { name = "My Task Name in Robot" }

# Optional per-topic overrides
[tool.purjo.topics."My Topic in BPMN"]
name = "My Task Name in Robot"
on-fail = "FAIL"           # FAIL|COMPLETE|ERROR
process-variables = false
```

## BPMN authoring

When working with .bpmn files, always use the `#bpmn-js-mcp` tools instead of editing BPMN XML directly. The MCP tools ensure valid BPMN 2.0 structure, proper diagram layout coordinates, and semantic correctness that hand-editing XML cannot guarantee.

To modify an existing .bpmn file, use import_bpmn_xml to load it, make changes with the MCP tools, then export_bpmn and write the result back to the file.

To create a new diagram, use create_bpmn_diagram, build it with add_bpmn_element / connect_bpmn_elements, then export_bpmn to get the XML.

## Robot Framework authoring

Use `#robotmcp` for tasks related to **Robot Framework test automation**. Use it when the user wants to create tests from natural language, execute steps interactively, explore or validate application behavior via automation, debug Robot Framework runs, inspect keywords/libraries/variables, or generate a complete `.robot` test suite. Prefer step-by-step execution first, verify results, then produce a clean, reproducible final test:

- `analyze_scenario` – understand intent and testing needs
- `recommend_libraries` – suggest suitable Robot Framework libraries
- `create_session` / `attach_session` – start or connect to a RF execution session
- `import_library` / `import_resource` – load test dependencies
- `run_step` – execute a single keyword/step interactively
- `get_state` / `get_variables` – inspect execution state and variables
- `search_keywords` – discover available keywords
- `generate_test` – produce a final `.robot` test from successful steps
- `run_suite` – execute and validate a generated test suite
- `debug_session` – troubleshoot failures in a live session

## Robot Conventions

### Inputs

Declare expected inputs with safe defaults:

```robotframework
*** Variables ***
${BPMN:TASK}        local
${BPMN:PROCESS}     local

${message}          ${None}
${count}            ${None}
${enabled}          ${None}
@{items}            ${None}
&{payload}          &{EMPTY}
```

### Outputs

Export outputs back to BPMN:

```robotframework
*** Tasks ***
Do Work
    ${result}=    Set Variable    ok
    VAR    ${result}    ${result}    scope=${BPMN:TASK}
```

Note: if a value was introduced via **BPMN input mapping**, exporting to process scope still typically requires **BPMN output mapping**.


## Python Keyword Libraries (Do Not Get This Wrong)

```python
from robot.api.deco import keyword, library


@library()
class MyLibrary:
    @keyword()
    def my_keyword(self, value: str) -> str:
        return value
```

Rules:
- Every exposed method MUST have `@keyword()`.
- Arguments must have type hints.


## BPMN Modeling

### Robot Task

- Service Task → Implementation: `External`
- Service Task → Topic: exactly the same string as in `pyproject.toml`

### Inputs/Outputs

- Inputs: process variables → task variables (Robot sees these)
- Outputs: task variables → process variables
- File variables: use `${execution.getVariableTyped("name")}`
- Gateways: use JUEL like `${errorCode != null}`


## Add a User Task + Camunda 7 Generated Task Form (Recommended for Demos)

If the bot needs demo inputs (like `${message}`), add a **User Task before the robot task**.

Steps:
1. `Start → User Task → Robot Service Task → End`
2. User Task → Form Type: `Generated Task Form`
3. Add fields. **Field ID MUST equal the process variable name**.

Example fields:

```
id: message   type: string   label: Message
id: count     type: long     label: Count
id: enabled   type: boolean  label: Enabled
```


## Fast Local Testing (No Engine)

```robotframework
*** Settings ***
Library    purjo
Library    Collections

*** Test Cases ***
Task Works
    &{inputs}=    Create Dictionary    message=Hello
    &{outputs}=   Get Output Variables    .    My Topic in BPMN    ${inputs}
    Should Be Equal    ${outputs}[result]    ok
```


## Run with Engine (Playground)

```bash
make start
pur run hello.bpmn
pur serve .
```


## rf-mcp (Available)

Use MCP to:
- discover keywords and args (`find_keywords`, `get_keyword_info`)
- iterate stepwise, then generate final suite once steps succeed


## Agent Checklist

- Start new bots with `pur init` (empty dir).
- Keep BPMN topic and `pyproject.toml` mapping identical.
- Prefer adding a User Task + Generated Form for demo inputs.
- Use `@library()` + `@keyword()` correctly.
- Don’t invent new scaffolding when `pur init` exists.

## Documentation

- https://datakurre.github.io/purjo/
