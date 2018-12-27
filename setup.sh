git clone --depth=1 git@bitbucket.org:dialoguesystems/pydial.git
2to3 --output-dir=. --write-unchanged-files -n pydial
sed -i 's/import dact, copy/from \. import dact\nimport copy/' utils/DiaAct.py




