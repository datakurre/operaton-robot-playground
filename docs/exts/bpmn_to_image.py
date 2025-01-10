from docutils import nodes
from docutils.parsers.rst.directives.images import Figure
from docutils.parsers.rst.directives.images import Image
from pathlib import Path
import subprocess


class BpmnToImage(Image):
    def run(self):
        parent = Path(self.state.document.current_source).parent
        if (parent / self.arguments[0]).with_suffix(".bpmn").exists():
            bpmn = (parent / self.arguments[0]).with_suffix(".bpmn")
        else:
            bpmn = parent / self.arguments[0]
        if bpmn.exists():
            image = bpmn.with_suffix(".svg")
            if not image.exists() or image.stat().st_mtime < bpmn.stat().st_mtime:
                subprocess.call(
                    [
                        "bpmn-to-image",
                        f"{bpmn}:{image}",
                        "--no-title",
                        "--no-footer",
                    ]
                )
            self.state.document.settings.record_dependencies.add(self.arguments[0])
            self.arguments[0] = str(image.relative_to(parent))
            self.options["width"] = ""
        return super().run()


def bpmn_to_image(name, rawtext, text, lineno, inliner, options=None, content=None):
    parent = Path(inliner.document.current_source).parent
    if (parent / text).with_suffix(".bpmn").exists():
        bpmn = (parent / text).with_suffix(".bpmn")
    else:
        bpmn = parent / text
    if bpmn.exists():
        image = bpmn.with_suffix(".svg")
        if not image.exists() or image.stat().st_mtime < bpmn.stat().st_mtime:
            subprocess.call(
                [
                    "bpmn-to-image",
                    f"{bpmn}:{image}",
                    "--no-title",
                    "--no-footer",
                ]
            )
        inliner.document.settings.record_dependencies.add(text)
        image_node = nodes.image(
            uri=str(image.relative_to(parent)), alt="", classes=["role-bpmn"]
        )

        return [image_node], []
    return [], []


class BpmnToFigure(Figure):
    def run(self):
        parent = Path(self.state.document.current_source).parent
        if (parent / self.arguments[0]).with_suffix(".bpmn").exists():
            bpmn = (parent / self.arguments[0]).with_suffix(".bpmn")
        else:
            bpmn = parent / self.arguments[0]
        if bpmn.exists():
            image = bpmn.with_suffix(".svg")
            if not image.exists() or image.stat().st_mtime < bpmn.stat().st_mtime:
                subprocess.call(
                    [
                        "bpmn-to-image",
                        f"{bpmn}:{image}",
                        "--no-title",
                        "--no-footer",
                    ]
                )
            self.state.document.settings.record_dependencies.add(self.arguments[0])
            self.arguments[0] = str(image.relative_to(parent))
            self.options["width"] = ""
        return super().run()


def setup(app):

    app.add_directive("bpmn-image", BpmnToImage)
    app.add_directive("bpmn-figure", BpmnToFigure)
    app.add_role("bpmn", bpmn_to_image)

    return {
        "version": "0.1",
        "parallel_read_safe": True,
        "parallel_write_safe": True,
    }
