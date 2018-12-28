#!/usr/bin/sh
## clean this folder
#sh clean.sh
#
# pydial instruction for installing
#git clone --depth=1 git@bitbucket.org:dialoguesystems/pydial.git
cp -r ../pydial .

rm pydial/*
rm -rf pydial/Tutorials
rm -rf pydial/Tutorials
rm -rf pydial/Docs
rm -f pydial/.gitignore
rm -rf pydial/.git

2to3 -w -n pydial

mv pydial/* .
#rmdir pydial
### some changes have to be manual
sed -i 's/import dact, copy/from \. import dact\nimport copy/' utils/DiaAct.py
find ./ -type f -exec sed -i -e 's/from \. import PER\.sum_tree/import policy\.DRL\.PER/g' {} \;
find ./ -type f -exec sed -i -e 's/from \. import DRL/import policy\.DRL/g' {} \;
sed -i 's/from \. import trpo_utils\.distribution\.utils as utils/import policy\.DRL\.trpo_utils\.distribution\.utils as utils/' policy/DRL/na2c.py


#sed -i 's/from \. import utils\.ContextLogger as clog/import utils\.ContextLogger as clog/' pydial.py
#sed -i 's/from \. import usersimulator\.textgenerator\.textgen_toolkit\.SCTranslate as SCT/import usersimulator\.textgenerator\.textgen_toolkit\.SCTranslate as SCT/' Simulate.py

# rm useless pydial files for gym




#cd pydial
#sudo easy_install pip
#pip install --user -r requirements.txt
#cd ..
#

#
## adding missing files
#cp -r pydial/config/ config
#cp -r pydial/ontology/ontologies ontology/ontologies
#cp -r pydial/Docs Docs
#cp

## removing sources
#rm -rf pydial





#
##!/usr/bin/sh
## clean this folder
#sh clean.sh
#
## pydial instruction for installing
##git clone --depth=1 git@bitbucket.org:dialoguesystems/pydial.git
#cp -r ../pydial .
#rm -rf pydial/.git
##cd pydial
##sudo easy_install pip
##pip install --user -r requirements.txt
##cd ..
#
## pydial python2 to python3
##2to3 --output-dir=. --write-unchanged-files -n pydial
#
#
#
##
#2to3 -w -n pydial
#mv pydial/* .
### some changes have to be manual
##sed -i 's/import dact, copy/from \. import dact\nimport copy/' utils/DiaAct.py
##find ./ -type f -exec sed -i -e 's/from \. import PER\.sum_tree/import policy\.DRL\.PER/g' {} \;
##find ./ -type f -exec sed -i -e 's/from \. import DRL/import policy\.DRL/g' {} \;
##sed -i 's/from \. import trpo_utils\.distribution\.utils as utils/import policy\.DRL\.trpo_utils\.distribution\.utils as utils/' policy/DRL/na2c.py
##sed -i 's/from \. import utils\.ContextLogger as clog/import utils\.ContextLogger as clog/' pydial.py
##sed -i 's/from \. import usersimulator\.textgenerator\.textgen_toolkit\.SCTranslate as SCT/import usersimulator\.textgenerator\.textgen_toolkit\.SCTranslate as SCT/' Simulate.py
#
#
#
#
##
### adding missing files
##cp -r pydial/config/ config
##cp -r pydial/ontology/ontologies ontology/ontologies
##cp -r pydial/Docs Docs
##cp
#
### removing sources
##rm -rf pydial




