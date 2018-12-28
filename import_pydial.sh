#!/usr/bin/sh

git clone https://bitbucket.org/dialoguesystems/pydial.git

# removing some useless files for gym wrapper
rm pydial/*
rm -rf pydial/Tutorials
rm -rf pydial/Docs
rm -f pydial/.gitignore
rm -rf pydial/.git

# convertion to python 3
2to3  -w -n pydial

# moving pydial python3 to root of this module (we should move it to gym_pydial folder but all imports will be broken if so)
mv pydial/* .
rm -rf pydial

# Embedding of database files and config files
mv config gym_pydial
mkdir gym_pydial/ontology
mv ontology/ontologies gym_pydial/ontology
touch gym_pydial/config/pydial_benchmarks/__init__.py
touch gym_pydial/config/__init__.py
sed -i "s/ontopath = os\.path\.join('ontology','ontologies')/import pkg_resources;ontopath = pkg_resources\.resource_filename('gym_pydial', '')+'\/'+os\.path\.join('ontology','ontologies')/" ontology/OntologyUtils.py
sed -i "s/config_file_path = self\._check_config_file_path(config_file_path)/import pkg_resources;config_file_path = pkg_resources\.resource_filename('gym_pydial', '')+'\/'+ config_file_path;config_file_path = self\._check_config_file_path(config_file_path)/"  usersimulator/UMHdcSim.py
sed -i "s/def _check_paramset(self, paramset):/def _check_paramset(self, paramset):\n        import pkg_resources;paramset=pkg_resources\.resource_filename('gym_pydial', '')+'\/'+paramset/" usersimulator/ErrorModel.py


### some fixes needed (not handle by 2to3)
sed -i 's/import dact, copy/import utils\.dact as dact\nimport copy/' utils/DiaAct.py
## those fixes are not important for the wrapper :
find policy -type f -exec sed -i -e 's/from \. import DRL\.utils as drlutils/import policy\.DRL\.utils as drlutils/g' {} \;
find policy -type f -exec sed -i -e 's/from \. import DRL/import policy\.DRL/g' {} \;
find policy -type f -exec sed -i -e 's/from \. import PER/import policy\.DRL\.PER/g' {} \;
find policy -type f -exec sed -i -e 's/from \. import trpo_utils\.distribution\.utils as utils/import policy\.trpo_utils\.distribution\.utils as utils/g' {} \;
