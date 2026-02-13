# AGENTS.md

Project instructions for LLM coding agents creating **Robot Framework bots** orchestrated by **Operaton BPM** using **purjo**.

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

Rule of thumb for dependencies:
- **Single source of truth:** for bot deps, always edit the bot’s `pyproject.toml` and run via `uv`.
- Don’t `pip install` (or `install_python_packages`) into the workspace root expecting `uv run` to see it.
- If you add Python deps: update `pyproject.toml` in the bot dir and validate with `uv run …`.

Then modify the generated template (do not add new scaffolding unless asked):
- `pyproject.toml` (topic mapping, deps)
- `hello.robot` / `Hello.py` (implement your task, rename)
- `hello.bpmn` (wire BPMN, often add a User Task + form, rename)


## Topic Mapping (`pyproject.toml`)

```toml
[tool.purjo.topics."My Topic in BPMN"]
name = "My Task Name in Robot"
on-fail = "FAIL"           # FAIL|COMPLETE|ERROR
process-variables = true   # false for Input/Output in BPMN
```

## BPMN authoring

When working with .bpmn files, always use the `#bpmn-js-mcp` tools instead of editing BPMN XML directly. The MCP tools ensure valid BPMN 2.0 structure, proper diagram layout coordinates, and semantic correctness that hand-editing XML cannot guarantee.

Identify ids first (guardrail):
- Import existing BPMN with `import_bpmn_xml`.
- Inspect using `summarize_bpmn_diagram` and/or `list_bpmn_elements`.
- Then set properties / mappings using the ids you just inspected.
- Don’t assume element ids (especially for processes/participants).

To modify an existing .bpmn file, use import_bpmn_xml to load it, make changes with the MCP tools, then export_bpmn with file path to write the result back to the file.

To create a new diagram, use create_bpmn_diagram, build it with batch_bpmn_operations, then export_bpmn with file path to serialize back to XML.

## Robot Framework authoring

Use `#robotmcp` for tasks related to **Robot Framework test automation**. Use it when the user wants to create tests from natural language (`mcp_robotmcp_analyze_scenario`), execute steps interactively, explore or validate application behavior via automation, debug Robot Framework runs, inspect keywords/libraries/variables, or generate a complete `.robot` test suite. Prefer step-by-step execution first, verify results, then produce a clean, reproducible final test.

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
    VAR    ${result}    ${result}    scope=${BPMN:PROCESS}
```

Note: if a value was introduced via **BPMN input mapping**, exporting to process scope still typically requires **BPMN output mapping** (`process-variables = false`).


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

Guardrail (name collisions):
- Never give a Python `@keyword()` the same name as a Task/Test Case in the `.robot` suite.
- If you want a human-readable task name, keep the Robot task named for the BPMN topic, and name the Python keyword something else (e.g. “Build …” vs “Generate …”).


## BPMN Modeling

### Robot Task

- Service Task → Implementation: `External`
- Service Task → Topic: exactly the same string as in `pyproject.toml`

### Inputs/Outputs

- Inputs: process variables → task variables (Robot sees these)
- Outputs: task variables → process variables
- File variables: use `${execution.getVariableTyped("name")}`
- Gateways: use JUEL like `${errorCode != null}`

Decision table: BPMN I/O mapping vs `process-variables`
- If BPMN uses **camunda:inputOutput mappings**, set `process-variables = false` in `pyproject.toml`.
- If you want Purjo to push/pull variables automatically (no BPMN I/O mapping), set `process-variables = true`.
- For **file variables** with mappings: use `${execution.getVariableTyped("<taskVar>")}` in BPMN outputs.


## Add a User Task + Camunda 7 Generated Task Form (Recommended for Demos)

If the bot needs demo inputs (like `${message}`), add a **User Task before the robot task**.

Steps:
1. `Start → User Task → Robot Service Task → End`
2. User Task → Form Type: `Generated Task Form`
3. Add fields. **Field ID MUST equal the process variable name**.

Example fields:

```text
id: message   type: string   label: Message
id: count     type: long     label: Count
id: enabled   type: boolean  label: Enabled
```


## Integration tests (RobotLibrary)

Prefer exercising your bot through a Robot Framework integration test suite (usually generated by `pur init` as `test_*.robot`). These tests run the task suite the same way Purjo would, but without starting the BPM engine.

Pattern:

- Put `test_*.robot` next to your task file (e.g. `hello.robot`).
- Use `RobotLibrary` and `Run Robot Test` to execute a single Robot task from that file.
- Pass `BPMN:PROCESS=global` so variables exported with `scope=${BPMN:PROCESS}` are visible to the test for assertions.
- Assert success, and for negative cases use `Run Keyword And Expect Error`.


Example:

```robotframework
*** Settings ***
Library             RobotLibrary
Test Template       Test Hello


*** Variables ***
${message}      ${None}


*** Test Cases ***    NAME
Hello John          John Doe
Hello Jane          Jane Doe


*** Keywords ***
Test Hello
    [Arguments]    ${name}
    ${suite}=    Join Path    ${EXECDIR}    hello.robot
    Run Robot Test    ${suite}
    ...    My Test in Robot
    ...    BPMN:PROCESS=global
    ...    name=${name}
    Should Be Equal    ${message}    Hello ${name}!

Guardrail: `Run Robot Test` pathing
- Avoid `${CURDIR}` when locating the target suite from within an integration test.
- Prefer `${EXECDIR}` + `Join Path` so the suite path follows where you launched `robot` from.
```

Run locally:

- `uv run --group dev robot test_hello.robot` (or `make test` inside the bot dir if it has a `Makefile`)

Preferred validation command:
- Default: `uv run --group dev robot test_*.robot` (inside the bot directory).
- Why: ensures the same environment as `pur serve`.


## Run with Engine (Playground)

```bash
make start
pur run hello.bpmn
pur serve .
```

## Agent Checklist

- Start new bots with `pur init` (empty dir).
- Keep BPMN topic and `pyproject.toml` mapping identical.
- Keep bot dependencies in the bot’s `pyproject.toml` and validate with `uv run …`.
- Prefer adding a User Task + Generated Form for demo inputs.
- Use `@library()` + `@keyword()` correctly.
- Confirm Python keyword names do not collide with Robot task names.
- Confirm tests run with `uv run --group dev robot test_*.robot` in the bot dir.
- After BPMN edits: run `validate_bpmn_diagram`, then `layout_bpmn_diagram`, then export.
- Don’t invent new scaffolding when `pur init` exists.

Fallback when VS Code terminal execution fails:
- If terminal tool execution fails, prefer running commands via `#robotmcp` (e.g. execute `Run Process`) to validate `pur init` / `uv run` / `robot` steps.

## Documentation

- <https://datakurre.github.io/purjo/>
