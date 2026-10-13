---
name: purjo-operaton-task-package
description: Build and maintain a Robot Framework robot package that purjo serves as Operaton (Camunda 7) external tasks — topics in pyproject.toml, Robot task suites, Pydantic input/output validation, element templates generated from Pydantic task contracts with the operaton-contracts package, example BPMN, optional devenv, Makefile, and ignore files. Trigger when a repository has [tool.purjo.topics] in pyproject.toml, .operaton/element-templates/, or uses pur serve / pur wrap; when asked to add or change a purjo topic, external task, robot package, or element template; or when element templates must be regenerated, checked, or validated.
metadata:
  workflow: purjo-robot-package
  audience: developers-and-agents
---

# purjo Operaton task package

Say **Operaton**, **robot package**, and **external task**. `pur serve .` polls
Operaton for each topic in `[tool.purjo.topics]`, runs the mapped Robot task,
and returns the task-scope variables it sets. `pur wrap` builds `robot.zip`
from everything `.wrapignore` does not exclude.

## Development environment

Packages use one of two environments; `<run>` below stands for its command
prefix.

- **devenv** — the repository has `devenv.nix`: development tools are Nix
  packages, and `<run>` is `devenv shell --` (see the `devenv` skill). Keep
  `robotframework-robotlibrary` in uv's `dev` group; put pytest, pytest-cov,
  mypy, Black, and jsonschema in `devenv.nix`. Set `UV_PYTHON` to the devenv
  interpreter and `PYTHONPATH` to include the project root, the uv `.venv`
  site-packages, then devenv's site-packages. Run pytest and mypy directly
  from devenv; pass `.venv/bin/python` to mypy so it resolves project deps.
  devenv scripts wrap the project tools: `operaton-contracts` runs
  `uv run --group dev python -m OperatonContracts`, and `robotcode` runs
  `uv run --group dev --with 'robotcode==2.7.0' robotcode` so RobotCode sees
  the project's libraries. Add `shell` and `nix-%` Makefile targets
  (`devenv shell`, `devenv shell -- $(MAKE) $*`).
- **uv** — otherwise: development tools are in uv's `dev` dependency group,
  and `<run>` is `uv run --group dev`.

Use the mode a repository already has. When bootstrapping, use uv unless
`command -v devenv` succeeds; then propose devenv to the user and use it only
if they accept. Run project commands as `<run> make <target>`.

## One topic, end to end

Every topic is the same chain. Each link is checked by
`<run> operaton-contracts check` (`make test` runs it):

```
<Package>Models.py   domain types, keyword input models, API row models
        ▲ imports
OperatonTasks.py    task contracts: one Input/Output model per topic   ← source of truth
        │ generates (with a TaskTemplate spec)   │ validates at runtime
element template (modeler)        Robot task: outputs = ${None} → Validate Task Input → keywords → API
```

The pyproject topic `name` selects the Robot task; the task declares a default
for every contract input, sets every contract output to `${None}`, calls
`Validate Task Input    <Contract>`, and sets every contract output's value
with `VAR … scope=${BPMN:TASK}`.

## Workflow: add a topic

1. **Name it.** Dotted, `<domain>.<scope>.<object>.<verb>`. Check the
   reserved/legacy topics in `[tool.operaton-contracts] reserved-topics`
   (mirrored in AGENTS.md); `check` rejects them.
2. **pyproject.toml.** Add
   `[tool.purjo.topics."<topic>"]` with `name = "<Robot Task Name>"`,
   `on-fail = "ERROR"`, `process-variables = false`.
3. **Task contract** in `OperatonTasks.py`: one `TaskContract` input and one
   output model; aliases are process-variable names, titles are labels,
   validators normalize what the engine may send. See
   [reference/pydantic-models.md](reference/pydantic-models.md).
4. **Robot suite** `<package>_<topic words>.robot`: import
   `OperatonContracts    OperatonTasks`, declare a default for every
   contract input, set every contract output to `${None}` with
   `VAR ${x}=  ${None}  scope=${BPMN:TASK}`, then call
   `${input}=    Validate Task Input    <Contract>`, use `${input}[alias]`
   afterwards, and set the outputs' values with task scope. See
   [reference/robot-tasks.md](reference/robot-tasks.md).
5. **Library keyword + keyword models** in `<Package>*.py` / `<Package>Models.py`:
   validate inputs with strict Pydantic models, validate API rows with output
   models, fail on HTTP/API/shape errors.
6. **Template spec.** Append a `TaskTemplate` to `TEMPLATES` in
   `OperatonTasks.py`, then run `make element-templates`. Never hand-edit the
   JSON. Configure `specs = "OperatonTasks:TEMPLATES"` in
   `[tool.operaton-contracts]`. To keep build-time metadata out of the runtime
   module, put it in a root-level `OperatonTemplates.py` and point `specs`
   there instead; list that module in `.wrapignore`. See
   [reference/element-templates.md](reference/element-templates.md).
7. **Example BPMN** `examples/example_<package>_<name>.bpmn` with a start form
   and one templated service task, plus a `deploy-example-*` Makefile target.
8. **Tests**: pytest at 100% branch coverage, a stub-backed RobotLibrary suite
   under `tests/`. See [reference/testing.md](reference/testing.md).
9. **Verify**: `<run> make format check test check-element-templates`.
10. **Docs**: update the AGENTS.md topic table and repository map.

## Workflow: change a published topic

A change that keeps deployed diagrams working (a new input with a default,
labels, constraints) needs only a `version` bump. A breaking change (a new
required input, a removed or renamed input or output, a changed type) gets a
new topic `<topic>.v<N>`, while the old contract, Robot task, and topic stay
served for diagrams on the kept version. See "Versioning a published task"
in [reference/element-templates.md](reference/element-templates.md).

## Workflow: bootstrap a package

1. Choose the environment (see above). With devenv, copy `devenv.nix.tmpl` to
   `devenv.nix` first. Then run, prefixing each command with `devenv shell --`
   in devenv mode:

   ```sh
   uv init --bare --python 3.12
   uv add pydantic robotframework "operaton-contracts[robot]"
   uv add --group dev robotframework-robotlibrary
   # UV mode only; devenv provides these tools when that environment is used.
   uv add --group dev "operaton-contracts[templates]" black mypy pytest \
     pytest-cov types-jsonschema
   ```

   `--bare` avoids a `src/` package or `main.py` that would ship in
   `robot.zip`. Never edit `uv.lock`.
2. Copy [assets/](assets/) into the new repository:

   | Asset | Destination |
   |---|---|
   | `Makefile.tmpl`, `robot.toml.tmpl`, `AGENTS.md.tmpl` | same name without `.tmpl` |
   | `devenv.nix.tmpl` | `devenv.nix`, devenv mode only (step 1) |
   | `wrapignore.tmpl`, `gitignore.tmpl` | `.wrapignore`, `.gitignore` |
   | `pyproject.purjo.toml.tmpl` | append to `pyproject.toml` |
   | `Models.py.tmpl`, `Client.py.tmpl` | `<Package>Models.py`, `<Package>Client.py` |
   | `OperatonTasks.py.tmpl` | `OperatonTasks.py` (contracts and template specs) |
   | `OperatonTemplates.py.tmpl` | `OperatonTemplates.py` (optional separate specs) |
   | `task.robot.tmpl` | `<package>_<topic_words>.robot` |
   | `robot_manual_variables.py.tmpl` | `tests/robot_manual_variables.py` |
   | `example.bpmn.tmpl` | `examples/example_<package>_<topic_words>.bpmn` |
   | `Stub.py.tmpl` | `tests/<Package>Stub.py` |
   | `test_task.robot.tmpl` | `tests/test_<package>_<topic_words>.robot` |
   | `test_element_templates.py.tmpl`, `test_client.py.tmpl`, `test_examples.py.tmpl` | `tests/` (same names, `.py`) |

   Replace only these placeholders:

   | Placeholder | Example |
   |---|---|
   | `{{package}}` / `{{Package}}` / `{{PACKAGE}}` | `sisu` / `Sisu` / `SISU` |
   | `{{topic}}` / `{{topic_words}}` | `sisu.generic.study_rights.get_current` / `generic_study_rights` |
   | `{{Task Name}}` / `{{TaskName}}` | `Get Current Study Rights` / `GetCurrentStudyRights` |
   | `{{Thing}}` / `{{thing_field}}` / `{{thingAlias}}` | `StudyRight` / `study_right` / `studyRight` |
   | `{{inputAlias}}` / `{{input_field}}` / `{{Input label}}` | `studentId` / `student_id` / `Student ID` |
   | `{{outputAlias}}` / `{{output_field}}` | `studyRights` / `study_rights` |
   | `{{reverse.domain}}` / `{{template-id}}` | `fi.example` / `generic-study-rights-get-current` |
   | `{{One sentence.}}` / `{{Fetch Keyword}}` | template description / `Fetch Study Rights` |
   | `{{vault/path}}` / `{{https://demo.example/api}}` | Vault path prefix / demo API endpoint |
   | `{{run}}` | `devenv shell --` or `uv run --group dev` |

   Any other `{{`/`}}` text is Python f-string or Robot syntax; leave it.
3. Add an SVG icon at the repository root as `<package>-logo.svg`; install
   `operaton-contracts` from PyPI as a project dependency rather than vendoring
   its runtime library or template tooling.
4. `<run> make element-templates format check test`. The client asset is a generic
   JSON POST client; adapt it and its stub and tests to the real API, keeping
   the HTTPS, proxy, `Secret`, and response-shape checks.
5. Follow "add a topic" for further topics. Layout details:
   [reference/package-layout.md](reference/package-layout.md).

## Workflow: update Operaton Contracts and this skill

The `operaton-contracts` PyPI package supplies `TaskContract`, the
`Validate Task Input` Robot library, and element-template generation,
consistency checks, and schema validation. Upgrade its dependency with
`uv add`; do not copy its implementation into the robot package.

This skill ships inside the package. After upgrading, refresh the installed
copy with `<run> operaton-contracts install-skill --force`; it lives in
`.agents/skills/purjo-operaton-task-package/` and, when the project has
`.claude/` (or with `--claude`), is linked into `.claude/skills/`. The
installed copy and that link are generated: ignore them in `.gitignore` and
`.wrapignore` (the assets do), and reinstall after cloning. Do not edit the installed copy;
change the skill in the `operaton-contracts` repository.

## Hard rules

- Generated element templates and `uv.lock` are never hand-edited.
- One template per topic, one topic per template, all with the same embedded
  icon and the pinned `$schema` URL. Do not commit a copy of the schema.
- Task contracts and, by default, `TaskTemplate` specs live in deployed
  `OperatonTasks.py`; every task first sets each output to `${None}` with
  task scope (output mappings run before a BPMN error reaches its boundary
  event, so they must resolve), then validates its inputs with
  `Validate Task Input` before doing anything else. Deployed code imports the
  `OperatonContracts` dependency, not build-time tooling.
- Every engine input has a typed default in its suite (`${EMPTY}`, `${False}`,
  `${0}`, `@{EMPTY}`) matching the contract; every output uses
  `scope=${BPMN:TASK}`; `process-variables = false`.
- One suite defines each task name; purjo runs every suite task whose name
  matches, ignoring case, spaces, and underscores.
- Credentials are `robot.api.types.Secret` values; keywords reject plain
  strings; secrets are never logged or returned.
- Query/operation text is static and lives in files; values go through
  variables. Fail explicitly on HTTP errors, API errors, and malformed data.
- Write tasks take a boolean `dryRun` (default false), fetch and validate the
  target rows (exact ID match, expected state) before writing, and return
  `${result}` with the request payload, `statusCode`, and `statusBody`.
- Prefer BuiltIn and Collections keywords; add custom keywords only for domain
  operations.
- Test helpers, tests, generated templates, examples, the root template icon,
  an optional `OperatonTemplates.py`, and `.agents/` stay out of `robot.zip`
  via `.wrapignore`.
