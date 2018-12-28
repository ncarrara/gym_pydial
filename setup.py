from setuptools import setup, find_packages

# cp this file to pydial git folder, then use the command "python setup.py install" in the shell.

setup(name='gympydial',
      version='0.0.0',
      description='gym wrapper for single domain pydial',
      url='https://github.com/ncarrara/gym_pydial',
      author='Nicolas Carrara',
      author_email='nicolas.carrara1u@gmail.com',
      license='MIT',
      packages=['gym_pydial'],
      zip_safe=False)