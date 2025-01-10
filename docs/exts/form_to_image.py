from docutils import nodes
from docutils.parsers.rst.directives.images import Figure
from docutils.parsers.rst.directives.images import Image
from docutils.parsers.rst.directives.misc import Raw
from pathlib import Path
import subprocess


class FormToHtml(Raw):
    def run(self):
        parent = Path(self.state.document.current_source).parent
        if (parent / self.arguments[0]).with_suffix(".form").exists():
            form = (parent / self.arguments[0]).with_suffix(".form")
        else:
            form = parent / self.arguments[0]
        if form.exists():
            html = form.with_suffix(".html")
            if not html.exists() or html.stat().st_mtime < form.stat().st_mtime:
                subprocess.call(
                    [
                        "form-to-image",
                        f"{form}:{html}",
                        "--no-title",
                        "--no-footer",
                    ]
                )
            self.state.document.settings.record_dependencies.add(self.arguments[0])
            self.arguments[0] = "html"
            self.options["file"] = str(html.relative_to(parent))
        return super().run()


class formToImage(Image):
    def run(self):
        parent = Path(self.state.document.current_source).parent
        if (parent / self.arguments[0]).with_suffix(".form").exists():
            form = (parent / self.arguments[0]).with_suffix(".form")
        else:
            form = parent / self.arguments[0]
        if form.exists():
            image = form.with_suffix(".png")
            if not image.exists() or image.stat().st_mtime < form.stat().st_mtime:
                subprocess.call(
                    [
                        "form-to-image",
                        f"{form}:{image}",
                        "--no-title",
                        "--no-footer",
                    ]
                )
                subprocess.call(
                    [
                        "convert",
                        f"{image}",
                        "-transparent",
                        "white",
                        f"{image}",
                    ]
                )

            self.state.document.settings.record_dependencies.add(self.arguments[0])
            if (parent / self.arguments[0]).with_suffix(".json").exists():
                self.state.document.settings.record_dependencies.add(
                    str((parent / self.arguments[0]).with_suffix(".json"))
                )
            self.arguments[0] = str(image.relative_to(parent))
        return super().run()


class formToFigure(Figure):
    def run(self):
        parent = Path(self.state.document.current_source).parent
        if (parent / self.arguments[0]).with_suffix(".form").exists():
            form = (parent / self.arguments[0]).with_suffix(".form")
        else:
            form = parent / self.arguments[0]
        if form.exists():
            image = form.with_suffix(".png")
            if not image.exists() or image.stat().st_mtime < form.stat().st_mtime:
                subprocess.call(
                    [
                        "form-to-image",
                        f"{form}:{image}",
                        "--no-title",
                        "--no-footer",
                    ]
                )
                subprocess.call(
                    [
                        "convert",
                        f"{image}",
                        "-transparent",
                        "white",
                        f"{image}",
                    ]
                )
            self.state.document.settings.record_dependencies.add(self.arguments[0])
            if (parent / self.arguments[0]).with_suffix(".json").exists():
                self.state.document.settings.record_dependencies.add(
                    str((parent / self.arguments[0]).with_suffix(".json"))
                )
            self.arguments[0] = str(image.relative_to(parent))
        return super().run()


def setup(app):

    app.add_directive("form-image", formToImage)
    app.add_directive("form-html", FormToHtml)
    app.add_directive("form-figure", formToFigure)

    return {
        "version": "0.1",
        "parallel_read_safe": True,
        "parallel_write_safe": True,
    }
