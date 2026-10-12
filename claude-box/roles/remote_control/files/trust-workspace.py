"""Mark a directory as trusted in ~/.claude.json, as the trust dialog would.

Claude Code documents this key as the way to trust a folder by hand. Only the
one key is touched, and the file is replaced atomically because Claude Code
rewrites it while running. Prints "changed" when it wrote.
"""
import json
import os
import sys
import tempfile

config_path, workspace = sys.argv[1], sys.argv[2]

with open(config_path) as f:
    config = json.load(f)

project = config.setdefault("projects", {}).setdefault(workspace, {})
if project.get("hasTrustDialogAccepted") is True:
    sys.exit(0)
project["hasTrustDialogAccepted"] = True

fd, tmp = tempfile.mkstemp(dir=os.path.dirname(config_path), prefix=".claude.json.")
with os.fdopen(fd, "w") as f:
    json.dump(config, f, indent=2)
os.chmod(tmp, os.stat(config_path).st_mode & 0o777)
os.replace(tmp, config_path)
print("changed")
