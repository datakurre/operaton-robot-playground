from robot.api.deco import keyword
from robot.api.deco import library


@library()
class Hello:
    @keyword()
    def hello(self, name: str) -> str:
        return f"Hello {name}!"
