from setuptools import setup, find_packages

# cp this file to pydial git folder, then use the command "python setup.py install" in the shell.

setup(
    name = "gym-pydial",
    version = "0.0.0",
    description = ("Gym wrapper for pydial"),
    packages=find_packages(),
)