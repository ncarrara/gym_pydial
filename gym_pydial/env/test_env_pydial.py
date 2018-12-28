from gym_pydial.env.env_pydial import EnvPydial

from policy.HDCPolicy import HDCPolicy

config_file = "env1-hdc-CR.cfg"

e = EnvPydial(config_file=config_file, error_rate=0.3)
print("Running pydial on benchmark {} with Handcrafted Policy".format(config_file))
N = 5
hangup_frequency = 0.
rrr = 0.
ccc = 0.
for i in range(N):
    rr = 0.
    cc = 0.
    end = False
    s = e.reset()
    pi = HDCPolicy("CamRestaurants")
    pi.restart()
    a = 'hello()'
    s, r, end, info = e.step(a)
    while not end:
        a = pi.nextAction(e.current_pydial_state.getDomainState(e.domainString))
        s, r, end, info = e.step(a, True)
        c = 1. if info["patience_gone"] else 0.
        rr += r
        cc += c
    if info["patience_gone"]:
        hangup_frequency += 1.
    rrr += rr
    ccc += cc
print("rewards : {} constraint: {}".format(rrr / N, ccc / N))
print("hangup frequency : {}".format(hangup_frequency / N))