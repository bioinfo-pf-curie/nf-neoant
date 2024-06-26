#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""options.py: Geniac CMake option class"""

import logging
import re
import shutil
import os
from pathlib import Path

from geniac.cli.commands.init import GeniacInit

__author__ = "Fabrice Allain"
__copyright__ = "Institut Curie 2020"

_logger = logging.getLogger(__name__)


class GeniacRecipes(GeniacInit):
    """Geniac CMake Recipes class"""

    def __init__(
        self,
        *args,
        src_path: str = None,
        **kwargs,
    ):
        """Init flags specific to GRecipes command"""
        super().__init__(
            *args, src_path=src_path, post_clean=True, init_build=True, **kwargs
        )

    def cmake_recipes(self):
        """Generate container recipes"""

        cmake_run = (
            self._subprocess_run(
                ["cmake", "-DCMAKE_INSTALL_PREFIX=" + (self.working_dirs["src"]).as_posix() + "/../.install", (self.working_dirs["src"] / "geniac").as_posix()],
                check=True,
                capture_output=True,
                cwd=self.working_dirs["build"],
                cmd_name="CMake run",
            )
            if self.working_dirs.get("src")
            else None
        )

        make_docker = (
            self._subprocess_run(
                ["make", "build_docker_recipes"],
                capture_output=True,
                check=True,
                cwd=self.working_dirs["build"],
                cmd_name="Make docker recipes",
            )
            if self.working_dirs.get("src")
            else None
        )

        make_singularity = (
            self._subprocess_run(
                ["make", "build_singularity_recipes"],
                capture_output=True,
                check=True,
                cwd=self.working_dirs["build"],
                cmd_name="Make singularity recipes",
            )
            if self.working_dirs.get("src")
            else None
        )
        output_dir = Path(self.working_dirs["build"].as_posix() + "/../recipes").as_posix()
        output_dir = os.path.realpath(output_dir)
        if os.path.isdir(output_dir):
            shutil.rmtree(output_dir)
            self.info("The folder '%s' has been deleted and will be reinitialized.", output_dir)

        shutil.copytree((self.working_dirs["build"]).as_posix() + "/workDir/results/docker/Dockerfiles/", output_dir + "/docker/")
        shutil.copytree((self.working_dirs["build"]).as_posix() + "/workDir/results/singularity/deffiles/", output_dir + "/singularity/")
        self.info("The '%s' folder has been created with container recipes generated by geniac.", output_dir)


    def run(self):
        """

        Returns:

        """
        self.cmake_recipes()
