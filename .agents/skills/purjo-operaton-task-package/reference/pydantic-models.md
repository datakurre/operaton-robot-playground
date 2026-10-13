# Pydantic models

Three roles, all deployed. Task contracts are the source of truth for what a
topic accepts and returns; keyword and row models describe the API calls
below them. Do not derive one role from another by inheritance: share field
types (`Literal` choices, `Annotated` ID types) through `<Package>Models.py`
and build keyword inputs from validated contract values.

## 1. Keyword input models (`<Package>Models.py`, deployed)

Validate library keyword arguments before any request.

```python
class StudyRightsByIdsInput(BaseModel):
    model_config = ConfigDict(
        extra="forbid", populate_by_name=True, strict=True, str_strip_whitespace=True
    )
    study_right_ids: list[Annotated[str, Field(min_length=1)]] = Field(
        alias="studyRightIds", min_length=1
    )
```

- camelCase aliases equal the API's variable names; dump with
  `model_dump(by_alias=True)` as query variables.
- `min_length=1` on identifiers and lists.
- `date` fields with `strict=False`; when the exact `YYYY-MM-DD` text matters,
  add a `field_validator(..., mode="before")` that round-trips
  `date.fromisoformat(value).isoformat() == value`.
- Shared normalizers (e.g. ID lists from JSON array or CSV, dropping
  `None`/blank/`"none"`, deduplicating) are plain functions next to the models.

## 2. Row / output models (deployed)

Validate every API row before returning it to Robot.

```python
class StudyRight(BaseModel):
    model_config = ConfigDict(extra="forbid", populate_by_name=True)
    study_right_id: str = Field(alias="studyRightId")
    study_right_start_date: date | None = Field(alias="studyRightStartDate")
```

- Select only the columns the model declares; `extra="forbid"` catches drift.
- Match the source's nullability and `date` types exactly.
- Return `Model.model_validate(row).model_dump(mode="json", by_alias=True)`.

## 3. Task contracts (`OperatonTasks.py`, deployed)

Describe the **engine-facing** variables of one topic. The element template is
generated from them, `check` matches them against the Robot suite, and the
task validates its inputs against them at runtime.

```python
from OperatonContracts import TaskContract, template_hints
from SisuModels import parse_study_right_ids

Id = Annotated[str, Field(min_length=1)]

class RescindStudyRightsInput(TaskContract):
    study_right_ids: list[Id] = Field(
        alias="studyRightIds", title="Sisu studyRightIds", min_length=1,
        json_schema_extra=template_hints(value=["${studyRightId}"]),
    )
    cancellation_date: date = Field(
        alias="cancellationDate", title="Cancellation date", strict=False
    )
    dry_run: bool = Field(alias="dryRun", title="Dry run",
                          description="Return the payload without sending it.",
                          default=False)

    @field_validator("study_right_ids", mode="before")
    @classmethod
    def sanitize_study_right_ids(cls, value: object) -> list[str]:
        return parse_study_right_ids(value)   # trim, drop None/""/"none", dedupe

class WriteResultOutput(TaskContract):
    result: dict[str, Any] = Field(alias="result", title="Result variable")
```

```robotframework
*** Settings ***
Library     OperatonContracts    OperatonTasks

*** Tasks ***
Rescind Study Rights
    VAR    ${result}=    ${None}    scope=${BPMN:TASK}
    ${input}=    Validate Task Input    RescindStudyRightsInput
    ...    ${input}[studyRightIds]
```

`Validate Task Input` reads `${alias}` for every field (unset variables are
left out so defaults apply), validates, and returns the values normalized and
JSON-compatible (dates as `YYYY-MM-DD` strings), keyed by alias.

Rules:

- `TaskContract` is strict, forbids extras, and strips strings. Use
  `Field(strict=False)` for values the engine sends as text (dates).
- Every field needs `alias` (process variable) and `title` (label);
  `description` becomes the template description. Field order is UI order.
- Model what the **engine** may send, which may differ from keyword models
  (e.g. `excludedStates` vs. `excludedTermRegistrationStates`, `dryRun`).
  Accept alternative encodings with `field_validator(mode="before")` and keep
  the declared type the canonical one, so the template stays e.g. a `List`.
- Choices come from `Literal[...]`; put the domain `Literal` in
  `<Package>Models.py` so keyword code and stubs can reuse it. `Enum`,
  `Optional`, and nested models produce `$ref`/`anyOf` schemas the generator
  does not support.
- Robot's default and the template's pre-filled value can differ: use
  `default_factory=list` for the Robot-side empty default and
  `template_hints(value=[...])` for the modeler default. Without a hint a
  `List` property gets `[]`; other properties get `"${alias}"`.
- Aliases are plain identifiers (`[A-Za-z_][A-Za-z0-9_]*`), so `${alias}`
  is a simple Robot variable, not extended variable syntax.
- Contracts import only Pydantic, `OperatonContracts`, and
  `<Package>Models`; never test helpers or other build-time-only modules.
