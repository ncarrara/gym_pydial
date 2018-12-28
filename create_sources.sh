#!/usr/bin/sh

git clone --depth=1 git@bitbucket.org:dialoguesystems/pydial.git

rm pydial/*
rm -rf pydial/Tutorials
rm -rf pydial/Tutorials
rm -rf pydial/Docs
rm -f pydial/.gitignore
rm -rf pydial/.git

2to3 -w -n pydial

mv pydial/* .

### some changes have to be manual
sed -i 's/import dact, copy/from \. import dact\nimport copy/' utils/DiaAct.py
find ./ -type f -exec sed -i -e 's/from \. import PER\.sum_tree/import policy\.DRL\.PER/g' {} \;
find ./ -type f -exec sed -i -e 's/from \. import DRL/import policy\.DRL/g' {} \;
sed -i 's/from \. import trpo_utils\.distribution\.utils as utils/import policy\.DRL\.trpo_utils\.distribution\.utils as utils/' policy/DRL/na2c.py
sed -i 's/fin = file/fin = open/' semo/RNNLG/utils/nlp/nlp.py

#sed -i 's/from \. import utils\.ContextLogger as clog/import utils\.ContextLogger as clog/' pydial.py
#sed -i 's/from \. import usersimulator\.textgenerator\.textgen_toolkit\.SCTranslate as SCT/import usersimulator\.textgenerator\.textgen_toolkit\.SCTranslate as SCT/' Simulate.py



