#!/usr/bin/env python

import em
import subprocess
import time

targets = ['master', 'repo', 'slave']

elapsed_times = {}

for target in targets:
    start_time = time.time()
    with open('Dockerfile.em', 'r') as fh:
        template_contents = fh.read()

    start_time = time.time()
    output = em.expand(template_contents, folder=target)

    # print(output)
    with open('Dockerfile', 'w') as of:
        of.write(output)

    print("wrote Dockerfile templated on %s" % target)
    cmd = 'docker build -t %s .' % target
    print("Running [%s]" % cmd)
    subprocess.check_call(cmd.split())
    elapsed_times[target] = time.time() - start_time

print("ran targets:")
for k, v in elapsed_times.items():
    print("%s: %s" % (k, v))
