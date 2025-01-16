# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = "Operaton Robot Playground"
author = "Asko Soukka"

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

import os
import sys


sys.path.append(os.path.abspath("exts"))
extensions = [
    "sphinxcontrib.jquery",
    "myst_parser",
    "sphinx_copybutton",
    "bpmn_to_image",
    "dmn_to_html",
    "form_to_image",
]

templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]
myst_heading_anchors = 3

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = "sphinx_book_theme"
html_show_copyright = False
html_show_sourcelink = False
html_show_sphinx = False
html_theme_options = dict(
    logo=dict(text=project),
    use_download_button=False,
    use_fullscreen_button=True,
)
html_static_path = ["_static"]
html_css_files = [
    "diagram-js.css",
    "bpmn-js.css",
    "bpmn-embedded.css",
    "bpmn-js-token-simulation.css",
    "custom.css",
    "dmn-js-shared.css",
    "dmn-js-decision-table.css",
    "dmn-js-literal-expression.css",
    "dmn.css",
    "form-js.css",
]
html_js_files = [
    "minipres.js",
    "bpmn-js-token-simulation.js",
    "form-viewer.umd.js",
    "custom.js",
]
html_favicon = "favicon.ico"

# FEEL lexer

from feel import FeelLexer
from pygments.lexers import get_lexer_by_name


def setup(app):
    app.add_lexer("feel", FeelLexer())
