# gym_pydial

Warning : this is higly experimental.

A gym wrapper for pydial (http://www.camdial.org/pydial/). Only single domain dialogue is supported. Works with python 3.

Clone pydial repository, switch it to python 3, remove useless files for gym environment:

```
sh import_pydial.sh
```


Download dependencies

```
pip install -r requirements.txt
```

Install package localy:

```
pip install .
```

Test :

```
python -c "import gym_pydial.env.test_env_pydial"
```
