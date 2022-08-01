"""Configuration file for the Sphinx documentation builder."""

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
import os
import subprocess
import sys
from typing import Tuple

import matplotlib
import packaging.version

sys.path.insert(0, os.path.abspath(".."))
matplotlib.use("agg")

# -- Utility functions -------------------------------------------------------


def get_version_and_release() -> Tuple[str, str]:
    """Get the version automatically from Poetry, if possible."""
    try:
        # We need to run the subprocess in a shell because the `poetry`
        # executable on Windows is actually a batch file.
        proc = subprocess.run(
            "poetry version --short",
            shell=True,
            text=True,
            capture_output=True,
        )
    except subprocess.CalledProcessError:
        _release = "0.1.0"
    else:
        _release = proc.stdout

    _version_info = packaging.version.Version(_release)
    _version = f"v{_version_info.major}.{_version_info.minor}"

    return _version, _release


# -- Project information -----------------------------------------------------

project = "Predictions & Describers"
copyright = "2019-2021, El"
author = "El"
version, release = get_version_and_release()

# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    "sphinx.ext.autodoc",
    "sphinx.ext.intersphinx",
    "sphinx.ext.napoleon",
    "sphinx.ext.viewcode",
    "sphinx.ext.doctest",
    "sphinx.ext.autosummary",
    "m2r2",
    "sphinx_tabs.tabs",
    "sphinx_copybutton",
]

# autosummary_generate = True

# Add any paths that contain templates here, relative to this directory.
templates_path = ["_templates"]

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]

# Role applied to anything surrounded in single backticks
default_role = "any"

# -- Options for PDF output --------------------------------------------------
latex_documents = [
    (
        "index",  # Root document
        "ell.predictions",  # Name of LaTeX file
        "Predictions & Describers",  # Document title
        "El",  # Author
        "manual",  # Document class (manual or howto)
    )
]
latex_logo = "_static/el-logo.png"

rinoh_template = "article"
rinoh_stylesheet = "sphinx_article"


# -- Options for HTML output -------------------------------------------------
html_experimental_html5_writer = True

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = "sphinx_book_theme"
html_theme_options = {
    "show_navbar_depth": 2,
}
# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ["_static"]

html_logo = "_static/el-logo.png"
html_favicon = "_static/el-favicon.ico"

pygments_style = "friendly"

# -- Options for autodoc extension -------------------------------------------
# autodoc_default_options = {}
autodoc_member_order = "bysource"

# -- Options for napoleon extension ------------------------------------------
napoleon_google_docstring = True
# napoleon_use_param = True

# -- Options for intersphinx extension ---------------------------------------
intersphinx_mapping = {
    "python": ("https://docs.python.org/3.7", None),
    "pandas": ("https://pandas.pydata.org/pandas-docs/stable/", None),
    "ray": ("https://docs.ray.io/en/latest/", None),
}

# -- Options for doctest extension -------------------------------------------
doctest_global_setup = """
import os
"""
