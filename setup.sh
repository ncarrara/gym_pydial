#!/usr/bin/sh
sh clean.sh
git clone --depth=1 git@bitbucket.org:dialoguesystems/pydial.git
sudo easy_install pip
pip install --user -r requirements.txt
2to3 --output-dir=. --write-unchanged-files -n pydial
sed -i 's/import dact, copy/from \. import dact\nimport copy/' utils/DiaAct.py
cp -r pydial/config/ config
cp -r pydial/ontology/ontologies ontology/ontologies
cp -r pydial/Docs Docs


# useless files for pydial gym
rm -rf pydial
rm -rf cedm
rm -rf scripts
rm -rf tests
rm Agent.py
rm conf.py
rm DialogueServer.py
rm Simulate.py
rm Texthub.py
rm run.log
rm pydial.py


#python setup.py install

