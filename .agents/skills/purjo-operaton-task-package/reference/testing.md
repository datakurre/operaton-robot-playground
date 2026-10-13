# Testing

`make test` must pass offline, without Vault or the live API.

## pytest (unit, schema, consistency)

- Run `python -m pytest --cov=<each maintained module> --cov=OperatonTasks
  --cov-branch --cov-fail-under=100 tests` from devenv; in uv mode run
  `uv run --group dev make test`. Use `python -m pytest`, not bare `pytest`:
  it puts the project root on `sys.path`, so tests import `OperatonTasks`,
  `<Package>Models`, and `tests.robot_manual_variables` without a devenv
  `PYTHONPATH`.
- Contract tests call `validate_input(Contract, {...})` from
  `OperatonContracts` directly (no Robot needed) and exercise each task
  model's normalization, defaults, and rejection cases (non-bool `dryRun`,
  blank IDs, wrong date format, unknown choices); Robot tests verify the
  installed library integration.
- `unittest.TestCase` style; patch `urlopen`/openers, never hit the network.
- Cover: query documents use variables only; models reject blank IDs and
  malformed rows; HTTP, API-error, and shape failures raise; secrets must be
  `Secret`; `http://` only for loopback; manual-variable loader.
- `tests/test_client.py` (asset): client request shape, HTTPS/loopback and
  `Secret` checks, malformed responses, and the manual-variable loader.
- `tests/test_examples.py` (asset): every example BPMN uses a template, has a
  start form, and maps exactly the contract's inputs and outputs; every
  template has an example.
- `tests/test_element_templates.py` (from the asset): committed templates
  equal the `operaton-contracts` render and package consistency checks pass.
- Independent assertions on the generated JSON (topic, inputs, outputs, list
  types, icon) and on example BPMN files catch generator regressions.

## Robot

- Dry-run every task suite: `robot --dryrun --output NONE --log NONE --report
  NONE <suites>`.
- Integration suites in `tests/test_<suite>.robot` import the real libraries
  plus `${CURDIR}/<Api>Stub.py`, a `@library(scope="SUITE")` that runs a
  `ThreadingHTTPServer` on `127.0.0.1:0` (`Start … Stub` / `Stop … Stub`,
  `Get … Stub URL`) and validates request bodies, headers, and auth.
- Run the real task with `Run Robot Task    <suite>    <Task>    name=value…`.
  RobotLibrary first injects the target suite's variable defaults, so a
  caller variable with the same name as a task input is overwritten: name
  caller variables differently (`@{requestedIds}`, not `@{studyRightIds}`).
- `Secret` arguments fail inside `TRY` around `Run Robot Task`; negative
  cases that fail input validation need no credentials, so omit them.
- Run them with `uv run --group dev python -m robot` (RobotLibrary is a dev
  dependency).

## Example BPMN

`examples/example_<package>_<name>.bpmn`:

- process `id` equals the file stem; `name` starts with `Example:`;
- one start event with `camunda:formData`, one form field per process input
  (strings with a required validation constraint, booleans with
  `defaultValue="false"`);
- one service task with `camunda:modelerTemplate` = template id,
  `camunda:type="external"`, the topic, and input/output mappings equal to the
  template's;
- `isExecutable="true"`, `camunda:historyTimeToLive` set;
- a pytest test asserts all of the above, and `make deploy-example-<name>`
  deploys it with `pur operaton deploy`.
