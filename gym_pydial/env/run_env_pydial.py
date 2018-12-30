from gym_pydial.env.env_pydial import EnvPydial
from gym_pydial.pydial.policy.HDCPolicy import HDCPolicy
import numpy as np

import logging

logging.basicConfig(level=logging.INFO)

logger = logging.getLogger("run_env_pydial")

config_file = "config/pydial_benchmarks/env1-hdc-CR.cfg"
#
e = EnvPydial(config_file=config_file,
              error_rate=0.3,
              seed=1,
              pydial_logging_level="ERROR")
rr = 0.
end = False
s = e.reset()
a = 'hello()'
s, r, end, info = e.step(a)
while not end:
    a = np.random.choice(e.action_space())
    s, r, end, info = e.step(a)
    rr += r

logger.info("Random policy reward : {} ".format(rr))

pi = HDCPolicy("CamRestaurants")
rr = 0.
end = False
s = e.reset()
pi.restart()
a = 'hello()'
s, r, end, info = e.step(a)
while not end:
    a = pi.nextAction(e.current_pydial_state.getDomainState(e.domainString))
    s, r, end, info = e.step(a, is_master_act=True)
    rr += r

logger.info("HDC policy reward : {} ".format(rr))
