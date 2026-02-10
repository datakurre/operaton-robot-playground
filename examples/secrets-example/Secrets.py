from robot.api.deco import keyword
from robot.api.deco import library
from robot.libraries.BuiltIn import BuiltIn
from robot.utils.secret import Secret

import hashlib


@library()
class Secrets:
    @keyword()
    def api_key_fingerprint(self) -> tuple[str, int]:
        """Compute a stable fingerprint for the injected `${api_key}` secret.

        Purjo injects secrets as Robot Framework variables.
        This keyword reads `${api_key}` via BuiltIn and returns only derived values.
        """

        api_key = BuiltIn().get_variable_value("${api_key}")
        if api_key is None:
            raise ValueError("Missing secret: ${api_key}")

        if not isinstance(api_key, Secret):
            raise TypeError(
                "Expected ${api_key} to be robot.utils.secret.Secret. "
                "Make sure Purjo secrets injection is enabled and Robot Framework >= 7.4 is used."
            )

        # Keep the real secret value out of logs. Only derive stable values.
        secret_value = api_key.value
        data = secret_value if isinstance(secret_value, bytes) else str(secret_value).encode("utf-8")

        digest = hashlib.sha256(data).hexdigest()
        return digest, len(data)
