#!/usr/bin/env python

import argparse
import em
import subprocess
import time

DEFAULT_IMAGES = ['master', 'repo', 'slave']

parser = argparse.ArgumentParser(description='Build docker images')
parser.add_argument('targets', metavar='N', type=str, nargs='+',
                    help='whcih images to build',
                    default=DEFAULT_IMAGES)
args = parser.parse_args()

invalid_targets = [t for t in args.targets if t not in DEFAULT_IMAGES]
if invalid_targets:
    parser.error("invalid timages %s" % invalid_targets)

elapsed_times = {}

for target in args.targets:
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
