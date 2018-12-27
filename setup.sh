#!/usr/bin/sh
sh clean.sh
# pydial instruction for installing
git clone --depth=1 git@bitbucket.org:dialoguesystems/pydial.git
#cp -r ~/pydial .
cd pydial
sudo easy_install pip
pip install --user -r requirements.txt
cd ..

# pydial python2 to python3
2to3 --output-dir=. --write-unchanged-files -n pydial
sed -i 's/import dact, copy/from \. import dact\nimport copy/' utils/DiaAct.py
find ./ -type f -exec sed -i -e 's/from \. import PER\.sum_tree/import policy\.DRL\.PER/g' {} \;
find ./ -type f -exec sed -i -e 's/from \. import DRL/import policy\.DRL/g' {} \;
sed -i 's/from \. import trpo_utils\.distribution\.utils as utils/import policy\.DRL\.trpo_utils\.distribution\.utils as utils/' policy/DRL/na2c.py

# adding files (not .py)
cp -r pydial/config/ config
cp -r pydial/ontology/ontologies ontology/ontologies
cp -r pydial/Docs Docs

rm -rf pydial

# setup this module in order to import it in other python projects
python setup.py install


