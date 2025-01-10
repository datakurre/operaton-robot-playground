from docutils import nodes
from docutils.parsers.rst.directives.misc import Raw
from pathlib import Path
import subprocess


class DmnToHtml(Raw):
    def run(self):
        parent = Path(self.state.document.current_source).parent
        if (parent / self.arguments[0]).with_suffix(".dmn").exists():
            dmn = (parent / self.arguments[0]).with_suffix(".dmn")
        else:
            dmn = parent / self.arguments[0]
        if dmn.exists():
            html = dmn.with_suffix(".html")
            if not html.exists() or html.stat().st_mtime < dmn.stat().st_mtime:
                subprocess.call(
                    [
                        "dmn-to-html",
                        f"{dmn}:{html}",
                        "--no-title",
                        "--no-footer",
                    ]
                )
            self.state.document.settings.record_dependencies.add(self.arguments[0])
            self.arguments[0] = "html"
            self.options["file"] = str(html.relative_to(parent))
        return super().run()


def setup(app):

    app.add_directive("dmn-html", DmnToHtml)

    return {
        "version": "0.1",
        "parallel_read_safe": True,
        "parallel_write_safe": True,
    }
