from env_pydial import EnvPydial
from policy.HDCPolicy import HDCPolicy

e = EnvPydial(config_file="config/pydial_benchmarks/env1-hdc-CR.cfg", error_rate=0.3)
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
print(rrr / N, ccc / N)
print(hangup_frequency / N)
