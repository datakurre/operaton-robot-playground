## Managing secrets example (Purjo)

This example mirrors Purjo’s secrets docs:
https://raw.githubusercontent.com/datakurre/purjo/refs/heads/main/docs/managing_secrets.md

Secrets are configured in [pyproject.toml](pyproject.toml) under `[tool.purjo.secrets]` and injected into Robot/Python tasks as variables.

The runnable process model is [secrets.bpmn](secrets.bpmn).

### 1) Create a secrets file locally

Copy the template and fill it with real values:

```bash
cp secrets.json.example secrets.json
```

Do not commit `secrets.json`.

### 2) Run with secrets

Purjo uses the `default` profile automatically (if present):

```bash
pur serve .
```

Or select a different profile / direct secrets file path:

```bash
pur serve --secrets prod .
pur serve --secrets ./secrets.json .
```

### Accessing secrets in tasks

- Robot Framework: `${api_key}` is available as a normal variable. With Robot Framework >= 7.4, secrets may be masked in logs.
- Python: tasks can read variables via `BuiltIn().get_variable_value("${api_key}")`.

This example **requires** `${api_key}` to be a Robot Framework `Secret` object (see `robot.utils.secret.Secret`) and will fail if it is a plain string. It prints only the masked representation:

- `api_key (masked) = <secret>`

This example’s task computes and exports only derived values:

- `api_key_fingerprint` (sha256 digest)
- `api_key_bytes` (byte count)

The secret value itself is never logged or returned.
