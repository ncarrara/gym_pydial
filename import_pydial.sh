#!/usr/bin/sh

#git clone --depth=1 git@bitbucket.org:dialoguesystems/pydial.git
#git clone https://bitbucket.org/dialoguesystems/pydial.git
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
#find ./ -type f -exec sed -i -e 's/from pydial.\. import. PER\.sum_tree/import policy\.DRL\.PER/g' {} \;
#find ./ -type f -exec sed -i -e 's/from pydial.\. import. DRL/import policy\.DRL/g' {} \;
#sed -i 's/from pydial.\. import. trpo_utils\.distribution\.utils as utils/import policy\.DRL\.trpo_utils\.distribution\.utils as utils/' policy/DRL/na2c.py
#sed -i 's/fin = file/fin = open/' semo/RNNLG/utils/nlp.py

#find ./ -type f -exec sed -i -e 's/from pydial.\(.*\) import/from pydial\.\1 import/g' {} \;


#sed -i 's/from pydial.\. import. utils\.ContextLogger as clog/import utils\.ContextLogger as clog/' pydial.py
#sed -i 's/from pydial.\. import. usersimulator\.textgenerator\.textgen_toolkit\.SCTranslate as SCT/import usersimulator\.textgenerator\.textgen_toolkit\.SCTranslate as SCT/' Simulate.py



