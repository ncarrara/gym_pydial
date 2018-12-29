#!/usr/bin/sh

git clone https://bitbucket.org/dialoguesystems/pydial.git
mv pydial gym_pydial/
#cp -r pydial pydial.back
#rm -rf gym_pydial/pydial
#cp -r pydial.back gym_pydial/pydial

# fix some imports (this is ugly and uncomplete but I dont think refractoring tools can handle the way pydial plays with imports)
find gym_pydial/pydial -type f -exec sed -i -E "s/^import trpo_utils\./import gym_pydial\.pydial\.policy\.DRL\.trpo_utils\./g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/^import replay_abc *$/import gym_pydial\.pydial\.policy\.DRL\.replay_abc as replay_abc/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/^import binary_heap$/import gym_pydial\.pydial\.policy\.DRL\.PER\.binary_heap as binary_heap/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/^import rank_based/import gym_pydial\.pydial\.policy\.DRL\.PER\.rank_based as rank_based/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/^from SemanticBeliefTrackingManager import/from gym_pydial\.pydial\.semanticbelieftracking\.SemanticBeliefTrackingManager import/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/^import RegexSemI *$/import gym_pydial\.pydial\.semi\.RegexSemI as RegexSemI/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/^import BeliefTrackingUtils$/import gym_pydial\.pydial\.belieftracking\.BeliefTrackingUtils as BeliefTrackingUtils/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/^from ontology import Ontology$/import gym_pydial\.pydial\.ontology\.Ontology as Ontology/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/^from ontology import OntologyUtils/import gym_pydial\.pydial\.ontology\.OntologyUtils as OntologyUtils/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/^import FlatOntologyManager$/import gym_pydial\.pydial\.ontology\.FlatOntologyManager as FlatOntologyManager/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/^import OntologyUtils/import gym_pydial\.pydial\.ontology\.OntologyUtils as OntologyUtils/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/from GPLib import/from gym_pydial\.pydial\.policy\.GPLib import/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/^from EvaluationManager import/from gym_pydial\.pydial\.evaluation\.EvaluationManager import/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/^from SuccessEvaluator import/from gym_pydial\.pydial\.evaluation\.SuccessEvaluator import/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/^from DataBase import/from gym_pydial\.pydial\.ontology\.DataBase import/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/^import DataBaseSQLite *$/import gym_pydial\.pydial\.ontology\.DataBaseSQLite as DataBaseSQLite/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/from BeliefTracker import/from gym_pydial\.pydial\.belieftracking\.BeliefTracker import/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/^from utils/from gym_pydial\.pydial\.utils/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/^from DRL/from gym_pydial\.pydial\.policy\.DRL/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/^from policy/from gym_pydial\.pydial\.policy/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/^from Policy/from gym_pydial\.pydial\.policy\.Policy/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E 's/^import DRL/import gym_pydial\.pydial\.policy\.DRL/g' {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/^import Policy *$/import gym_pydial\.pydial\.policy\.Policy as Policy/g" {} \;
find gym_pydial/pydial -type f -exec sed -i -E "s/^import SummaryAction$/import gym_pydial\.pydial\.policy\.SummaryAction as SummaryAction/g" {} \;
sed -i 's/import dact, copy/import gym_pydial\.pydial\.utils\.dact as dact\nimport copy/' gym_pydial/pydial/utils/DiaAct.py
find gym_pydial/pydial -type f -exec sed -i 's/from ontology import Ontology, OntologyUtils/import gym_pydial\.pydial\.ontology\.Ontology as Ontology\nimport gym_pydial\.pydial\.ontology\.OntologyUtils as OntologyUtils/' {} \;
sed -i -E "s/^import utils\.Settings$/import gym_pydial\.pydial\.utils as utils/g" gym_pydial/pydial/ontology/OntologyUtils.py
find gym_pydial/pydial -type f -exec sed -i -E "s/^from ontology import Ontology *$/import gym_pydial\.pydial\.ontology\.Ontology as Ontology/g" {} \;
#find gym_pydial/pydial -type f -exec sed -i -E "s//gym_pydial\.pydial\./g" {} \;


## convertion to python 3
2to3  -w -n gym_pydial/pydial

## Embedding of database files and config files
mv gym_pydial/pydial/config gym_pydial
mkdir gym_pydial/ontology
mv gym_pydial/pydial/ontology/ontologies gym_pydial/ontology
touch gym_pydial/config/pydial_benchmarks/__init__.py
touch gym_pydial/config/__init__.py
sed -i "s/ontopath = os\.path\.join('ontology','ontologies')/import pkg_resources;ontopath = pkg_resources\.resource_filename('gym_pydial', '')+'\/'+os\.path\.join('ontology','ontologies')/" gym_pydial/pydial/ontology/OntologyUtils.py
sed -i "s/config_file_path = self\._check_config_file_path(config_file_path)/import pkg_resources;config_file_path = pkg_resources\.resource_filename('gym_pydial', '')+'\/'+ config_file_path;config_file_path = self\._check_config_file_path(config_file_path)/"  gym_pydial/pydial/usersimulator/UMHdcSim.py
sed -i "s/def _check_paramset(self, paramset):/def _check_paramset(self, paramset):\n        import pkg_resources;paramset=pkg_resources\.resource_filename('gym_pydial', '')+'\/'+paramset/" gym_pydial/pydial/usersimulator/ErrorModel.py


# some last minute fixies
sed -i "s/from semi import SemI/import gym_pydial\.pydial\.semi\.SemI as SemI/" gym_pydial/pydial/semanticbelieftracking/ModularSemanticBeliefTracker.py
sed -i "s/from belieftracking import BeliefTrackingManager/import gym_pydial\.pydial\.belieftracking\.BeliefTrackingManager as BeliefTrackingManager/" gym_pydial/pydial/semanticbelieftracking/ModularSemanticBeliefTracker.py
sed -i "s/as OntologyUtils, Ontology/as OntologyUtils\nimport gym_pydial\.pydial\.ontology\.Ontology as Ontology/" gym_pydial/pydial/semi/SemIContextUtils.py

