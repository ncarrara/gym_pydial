import os
from gym_pydial.pydial.usersimulator import SimulatedUsersManager
from gym_pydial.pydial.utils import Settings, ContextLogger
from gym_pydial.pydial.utils.DiaAct import DiaAct
from gym_pydial.pydial.ontology import Ontology
from gym_pydial.pydial.policy import SummaryAction
from gym_pydial.pydial.policy.Policy import TerminalState
from gym_pydial.pydial.ontology import FlatOntologyManager
import os.path
import pkg_resources
import random
import numpy
import logging

# xaxa=pkg_resources.resource_filename('gym_pydial','')
# print(xaxa)

# sys.path.append(xaxa)
# sys.path.append(pkg_resources.resource_filename('gym_pydial', 'config'))
# print("env_pydial sees whose things : \n{}".format("".join([ss+"\n" for ss in sys.path])))
TERMINAL_STATE = None

__author__ = "ncarrara"
__version__ = Settings.__version__

ontology_is_loaded = False
logger = logging.getLogger(__name__)

class EnvPydial:
    # resetable variables
    currentTurn = None
    next_pydial_state = None
    next_state = None
    current_state = None
    endingDialogue = None
    user_act = None

    # intialised with constructor
    domainString = None
    domainUtils = None
    summaryaction = None
    simulator = None
    semi_belief_manager = None
    evaluation_manager = None
    sim_level = 'dial_act'
    hub_id = 'simulate'
    forceNullPositive = False

    def size_belief_vector(self, domainString):
        if domainString == 'CamRestaurants':
            return 268
        elif domainString == 'CamHotels':
            return 111
        elif domainString == 'SFRestaurants':
            return 633
        elif domainString == 'SFHotels':
            return 438
        elif domainString == 'Laptops11':
            return 257
        elif domainString == 'TV':
            return 188

    def __init__(self, config_file="env1-hdc-CR.cfg", error_rate=0.3,
                 seed=None, pydial_logging_level="ERROR"):
        """

        :param config_file:
        :param error_rate:
        :param seed: override seed from config file
        :param pydial_logging_level:
        """

        logging.getLogger('pydial').setLevel(pydial_logging_level)

        notfound = []
        originel = config_file
        if not os.path.exists(config_file):
            notfound.append(config_file)
            config_file = pkg_resources.resource_filename('gym_pydial', '') + "/config/pydial_benchmarks/" + originel
            if not os.path.exists(config_file):
                notfound.append(config_file)
                config_file = pkg_resources.resource_filename('gym_pydial', '') + "/" + originel
                if not os.path.exists(config_file):
                    notfound.append(config_file)
                    raise Exception(
                        "config file not found in those folders : \n{}".format("".join([c + "\n" for c in notfound])))

        Settings.load_config(config_file)
        Settings.load_root()
        if seed is not None:
            self.seed(seed)
        if not ontology_is_loaded:
            Ontology.init_global_ontology()
            ontology_is_loaded = True
        else:
            logger.info("Ontology has already been loaded")

        self.maxTurns = Settings.config.getint("agent", "maxturns")
        self.domainString = Settings.config.get('GENERAL', "domains")
        self.domainUtils = FlatOntologyManager.FlatDomainOntology(self.domainString)
        self.size_pydial_state = self.size_belief_vector(self.domainString)
        self.summaryaction = SummaryAction.SummaryAction(self.domainString)
        self.simulator = SimulatedUsersManager.DomainsSimulatedUser(self.domainString, error_rate)
        self.semi_belief_manager = self.load_manager('semanticbelieftrackingmanager',
                                                     'semanticbelieftracking.SemanticBeliefTrackingManager.'
                                                     'SemanticBeliefTrackingManager')
        self.evaluation_manager = self.load_manager('evaluationmanager',
                                                    'evaluation.EvaluationManager.'
                                                    'EvaluationManager')

    def seed(self, seed):
        Settings.set_seed(seed)
        random.seed(seed)
        numpy.random.seed(seed)

    def action_space(self):
        return self.summaryaction.action_names

    def action_space_str(self):
        return self.summaryaction.action_names

    def reset(self):
        self.simulator.restart(otherDomainsConstraints=[])
        self.semi_belief_manager.restart()
        self.evaluation_manager.restart()
        self.user_act = ''
        self.prev_sys_act = None
        self.endingDialogue = False
        self.currentTurn = 0
        self.sys_act = None
        self.next_pydial_state = None
        self.next_state = None
        self.current_state = None
        self.endingDialogue = False
        self.current_pydial_state = self.semi_belief_manager.update_belief_state(ASR_obs=None, sys_act=self.sys_act,
                                                                                 dstring=self.domainString,
                                                                                 turn=self.currentTurn,
                                                                                 hub_id=self.hub_id)
        self.system_summary_acts = []
        self.system_master_acts = []
        self.user_acts = []
        self.current_state = self.flatten_state(self.current_pydial_state) \
                             + self.system_summary_acts \
                             + self.system_master_acts \
                             + self.user_acts + [self.currentTurn]

        self.current_state = {
            "flatten": self.flatten_state(self.current_pydial_state),
            "system_summary_acts": self.system_summary_acts,
            "system_master_acts": self.system_master_acts,
            "user_acts": self.user_acts,
            "pydial_state": self.current_pydial_state.getDomainState(self.domainString),
            "turn": self.currentTurn

        }
        return self.current_state

    def step(self, a, is_master_act=False):
        if not self.endingDialogue:
            if is_master_act:
                masterAct = a
            else:
                beliefstate = self.current_pydial_state.getDomainState(self.domainUtils.domainString)
                masterAct = self._summary_act_to_master_act(beliefstate, a,
                                                            None if self.prev_sys_act is None
                                                            else self.prev_sys_act.to_string())
            self.sys_act = DiaAct(masterAct)
            info = {}

            user_act = self.simulator.act_on(self.sys_act.to_string())
            n_best = self._confuse_user_act_and_enforce_null(user_act)
            self.next_pydial_state = self.semi_belief_manager.update_belief_state(ASR_obs=n_best,
                                                                                  dstring=self.domainString,
                                                                                  sys_act=self.sys_act.to_string(),
                                                                                  turn=self.currentTurn,
                                                                                  hub_id=self.hub_id,
                                                                                  sim_lvl=self.sim_level)
            outofturns = (self.currentTurn + 1) >= self.maxTurns
            self.endingDialogue = 'bye' == self.sys_act.act or outofturns or 'bye' == user_act.act
            if self.endingDialogue:
                reward = self._evaluate_final_reward()
                self.next_state = TERMINAL_STATE
                self.next_pydial_state = TerminalState()
            else:
                reward = self._evaluate_turn_reward(str_sys_act=self.sys_act.to_string(), state=self.next_pydial_state)
                if not is_master_act:
                    self.system_summary_acts.append(a)
                self.system_master_acts.append(self.sys_act.to_string())
                self.user_acts.append(user_act.to_string())
                self.next_state = {
                    "flatten": self.flatten_state(self.next_pydial_state),
                    "system_summary_acts": self.system_summary_acts,
                    "system_master_acts": self.system_master_acts,
                    "user_acts": self.user_acts,
                    "pydial_state": self.next_pydial_state.getDomainState(self.domainString),
                    "turn": self.currentTurn + 1

                }
            self.prev_sys_act = self.sys_act
            self.current_pydial_state = self.next_pydial_state
            self.current_state = self.next_state

            info["state_is_absorbing"] = self.endingDialogue
            info["patience_gone"] = self.simulator.um.goal.patience < 1.
            info["patience"] = self.simulator.um.goal.patience
            info["c_"] = 1. if info["patience_gone"] else 0.

            self._increment_turn()
            return self.next_state, reward, self.endingDialogue, info
        else:
            raise Exception("dialogue ended, please reset the environment")

    def _confuse_user_act_and_enforce_null(self, user_act):
        hyps = self.simulator.error_simulator.confuse_act(user_act)
        null_prob = 0.0
        for h in hyps:
            act = h.to_string()
            prob = h.P_Au_O
            if act == 'null()':
                null_prob += prob
        if self.forceNullPositive and null_prob < 0.001:
            nullAct = DiaAct.DiaActWithProb('null()')
            nullAct.P_Au_O = 0.001
            hyps.append(nullAct)
        return hyps

    def _evaluate_final_reward(self):
        finalInfo = {}
        finalInfo['usermodel'] = {self.domainString: self.simulator.um}
        finalInfo['task'] = None  # self.task
        finalInfo['subjectiveSuccess'] = None
        final_rewards = self.evaluation_manager.finalRewards(finalInfo)
        # print final_rewards
        return final_rewards[self.domainString]

    def _evaluate_turn_reward(self, str_sys_act, state):
        turnInfo = {}
        turnInfo['sys_act'] = str_sys_act
        turnInfo['state'] = state
        turnInfo['prev_sys_act'] = self.prev_sys_act
        turnInfo['usermodel'] = self.simulator.um
        reward = self.evaluation_manager.turnReward(turnInfo=turnInfo, domainString=self.domainString)
        # if reward == -1.:
        #     reward = 0
        #     print "to remove, changing reward"
        return reward

    def _increment_turn(self):
        self.currentTurn += 1
        Settings.global_currentturn = self.currentTurn

    def load_manager(self, config, defaultManager):
        manager = defaultManager
        if Settings.config.has_section('agent') and Settings.config.has_option('agent', config):
            manager = Settings.config.get('agent', config)
        try:
            components = manager.split('.')
            packageString = 'gym_pydial.pydial.' + '.'.join(components[:-1])
            classString = components[-1]
            # print(packageString)
            mod = __import__(packageString, fromlist=[classString])
            klass = getattr(mod, classString)
            return klass()
        except ImportError as e:
            raise Exception('Manager "{}" could not be loaded: {}'.format(manager, e))

    def action_space_executable(self):
        beliefstate = self.current_pydial_state
        lastSystemAction = self.prev_sys_act
        beliefstate = beliefstate.getDomainState(self.domainUtils.domainString)
        nonExec = self.summaryaction.getNonExecutable(beliefstate, lastSystemAction)
        return list(set(self.action_space()) - set(nonExec))

    def _summary_act_to_master_act(self, beliefstate, summaryAct, str_lastSystemAction):
        if summaryAct == "hello()":
            masterAct = summaryAct
        else:
            masterAct = self.summaryaction.Convert(beliefstate, summaryAct, str_lastSystemAction)
        return masterAct

    def flatten_state(self, state):
        domainUtil = self.domainUtils

        if isinstance(state, TerminalState):
            return [0] * self.size_pydial_state

        state = state.getDomainState(domainUtil.domainString)

        policyfeatures = ['full', 'method', 'discourseAct', 'requested', \
                          'lastActionInformNone', 'offerHappened', 'inform_info']

        flat_belief = []
        for feat in policyfeatures:
            add_feature = []
            if feat == 'full':
                # for slot in self.sorted_slots:
                for slot in domainUtil.ontology['informable']:
                    for value in domainUtil.ontology['informable'][slot]:  # + ['**NONE**']:
                        add_feature.append(state['beliefs'][slot][value])

                    # pfb30 11.03.2017
                    try:
                        add_feature.append(state['beliefs'][slot]['**NONE**'])
                    except:
                        add_feature.append(0.)  # for NONE
                    try:
                        add_feature.append(state['beliefs'][slot]['dontcare'])
                    except:
                        add_feature.append(0.)  # for dontcare

            elif feat == 'method':
                add_feature = [state['beliefs']['method'][method] for method in domainUtil.ontology['method']]
            elif feat == 'discourseAct':
                add_feature = [state['beliefs']['discourseAct'][discourseAct]
                               for discourseAct in domainUtil.ontology['discourseAct']]
            elif feat == 'requested':
                add_feature = [state['beliefs']['requested'][slot] \
                               for slot in domainUtil.ontology['requestable']]
            elif feat == 'lastActionInformNone':
                add_feature.append(float(state['features']['lastActionInformNone']))
            elif feat == 'offerHappened':
                add_feature.append(float(state['features']['offerHappened']))
            elif feat == 'inform_info':
                add_feature += state['features']['inform_info']
            else:
                raise Exception('Invalid feature name in config: ' + feat)

            flat_belief += add_feature

        return flat_belief
