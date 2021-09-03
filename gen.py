#!/usr/bin/env python

import os
import sys
from pathlib import Path

from jinja2 import Environment, FileSystemLoader

TEMPLATES_DIR = "templates"


def render(path: str) -> str:
    """
    Render a Jinja2 template to actual text, using macros in scope.

    :param path: Path to the file you'd like to render.
    """
    env = Environment(loader=FileSystemLoader("."))
    render = env.from_string(open(path, "r").read()).render()
    return render


def gen(templates_dir: str) -> str:
    """
    Crawl the templates directory and generate files in the correct locations.
    NOTE: This must be run from project root!

    :param templates_dir: The directory of templates, which mirror project root.
    """

    for root, _, files in os.walk(templates_dir, topdown=True):
        for filename in files:
            # TEMPLATES_DIR should act a mirror of the codebase, so the filepaths
            # of each template file should be the same as the filepaths of template targets.
            template_file = Path(root) / filename
            target_file = str(template_file).replace(".jinja", "").replace(templates_dir + "/", "")
            rendered_template = render(template_file)
            with open(target_file, "w") as f:
                f.write(rendered_template)


if __name__ == "__main__":
    gen(TEMPLATES_DIR)
