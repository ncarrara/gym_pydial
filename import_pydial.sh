#!/usr/bin/sh

git clone https://bitbucket.org/dialoguesystems/pydial.git
cp -r ../pydial .
rm pydial/*
rm -rf pydial/Tutorials
rm -rf pydial/Docs
rm -f pydial/.gitignore
rm -rf pydial/.git

2to3  -w -n pydial

mv pydial/* .
rm -rf pydial
### some changes have to be manual
sed -i 's/import dact, copy/import utils\.dact as dact\nimport copy/' utils/DiaAct.py

## no need to run those for gym_pydial
#find ./ -type f -exec sed -i -e 's/from pydial.\. import. PER\.sum_tree/import policy\.DRL\.PER/g' {} \;
#find ./ -type f -exec sed -i -e 's/from pydial.\. import. DRL/import policy\.DRL/g' {} \;
#sed -i 's/from pydial.\. import. trpo_utils\.distribution\.utils as utils/import policy\.DRL\.trpo_utils\.distribution\.utils as utils/' policy/DRL/na2c.py
#sed -i 's/fin = file/fin = open/' semo/RNNLG/utils/nlp.py

