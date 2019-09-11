
import argparse
import json
import os
import pathlib
import sys


PREFIX = 'post_deploy_'

parser = argparse.ArgumentParser()
parser.add_argument('path', help='Provide the path for the output JSON file.')
args = parser.parse_args()

post_deploy_kwargs = {}
for key in os.environ:
    if key.startswith(PREFIX):
        post_deploy_kwargs[key[len(PREFIX):]] = os.environ[key]

dump = json.dumps(post_deploy_kwargs)
pathlib.Path(args.path).write_text(dump)
print(dump)
