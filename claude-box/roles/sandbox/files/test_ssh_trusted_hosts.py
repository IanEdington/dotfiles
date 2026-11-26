import json
import subprocess
import sys
import unittest
from pathlib import Path

from ssh_trusted_hosts import decide

HOOK = Path(__file__).with_name("ssh_trusted_hosts.py")
TRUSTED = {"staging"}


class Decide(unittest.TestCase):
    def assert_decisions(self, expected, commands):
        for command in commands:
            with self.subTest(command=command):
                self.assertEqual(decide(command, TRUSTED), expected)

    def test_allows_one_remote_argument_to_a_trusted_alias(self):
        self.assert_decisions(
            "allow",
            [
                "ssh staging 'uptime'",
                "ssh staging uptime",
                "ssh staging 'a; b'",
                "ssh staging 'cd /srv && wp cache flush | tee /tmp/x'",
                "ssh staging 'echo $(hostname) `date`'",
                'ssh staging "systemctl status nginx"',
                "ssh staging 'line one\nline two'",
                "  ssh\tstaging   'uptime'  \n",
                "ssh staging ' -o is fine after a space'",
            ],
        )

    def test_asks_for_anything_beyond_the_remote_argument(self):
        self.assert_decisions(
            "ask",
            [
                "ssh staging 'x' && rm -rf ~",
                "ssh staging 'x'; ssh prod 'y'",
                "ssh staging 'x' | sh",
                "ssh staging 'x' > ~/.bashrc",
                "ssh staging 'bash -s' <<'SH'\nuptime\nSH",
                "ssh staging 'x' &",
                "ssh staging 'x' 'y'",
                "ssh staging 'x'\nrm -rf ~",
                "ssh staging 'it'\\''s'",
                "ssh staging $(whoami)",
                "ssh staging `whoami`",
                'ssh staging "$(whoami)"',
                'ssh staging "`whoami`"',
                'ssh staging "$HOME"',
                "ssh staging ~/x",
                "ssh staging '*'x",
                "ssh staging x*",
                "(ssh staging x)",
                "cd /tmp && ssh staging x",
                "env ssh staging x",
            ],
        )

    def test_asks_for_ssh_options(self):
        self.assert_decisions(
            "ask",
            [
                "ssh -o ProxyCommand=sh staging x",
                "ssh -oLocalCommand=sh -oPermitLocalCommand=yes staging x",
                "ssh -F /tmp/config staging x",
                "ssh staging -oProxyCommand=sh",
                "ssh staging '-oProxyCommand=sh'",
                "ssh staging -- x",
            ],
        )

    def test_asks_for_untrusted_hosts(self):
        self.assert_decisions(
            "ask",
            [
                "ssh staging2 x",
                "ssh prod x",
                "ssh user@staging x",
                "ssh staging.example.com x",
                "ssh 10.0.0.1 x",
            ],
        )

    def test_asks_for_interactive_and_empty_sessions(self):
        self.assert_decisions(
            "ask", ["ssh staging", "ssh staging ''", "ssh staging '   '"]
        )

    def test_asks_for_other_remote_shell_commands(self):
        self.assert_decisions(
            "ask",
            [
                "scp staging:/etc/hosts .",
                "sftp staging",
                "rsync -a staging:/srv/ ./srv/",
                "/usr/bin/ssh staging x",
            ],
        )

    def test_ignores_commands_without_remote_shells(self):
        self.assert_decisions(
            None,
            ["ls ~/.ssh/config.d", "git status", "cat new-staging-key", "sshd -T"],
        )


class Hook(unittest.TestCase):
    def run_hook(self, stdin, *aliases):
        result = subprocess.run(
            [sys.executable, "-I", str(HOOK), *aliases],
            input=stdin,
            capture_output=True,
            text=True,
            check=True,
        )
        if not result.stdout:
            return None
        return json.loads(result.stdout)["hookSpecificOutput"]["permissionDecision"]

    def test_allows_a_trusted_alias(self):
        stdin = json.dumps({"tool_input": {"command": "ssh staging 'uptime'"}})
        self.assertEqual(self.run_hook(stdin, "staging"), "allow")

    def test_trusts_nothing_without_aliases(self):
        stdin = json.dumps({"tool_input": {"command": "ssh staging 'uptime'"}})
        self.assertEqual(self.run_hook(stdin), "ask")

    def test_ignores_malformed_alias_arguments(self):
        stdin = json.dumps({"tool_input": {"command": "ssh -x 'uptime'"}})
        self.assertEqual(self.run_hook(stdin, "-x"), "ask")

    def test_stays_silent_for_unrelated_commands(self):
        stdin = json.dumps({"tool_input": {"command": "git status"}})
        self.assertIsNone(self.run_hook(stdin, "staging"))

    def test_asks_when_input_is_malformed(self):
        for stdin in ["not json", "{}", json.dumps({"tool_input": {"command": 1}})]:
            with self.subTest(stdin=stdin):
                self.assertEqual(self.run_hook(stdin, "staging"), "ask")


if __name__ == "__main__":
    unittest.main()
