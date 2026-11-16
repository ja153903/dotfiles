import json
from pathlib import Path
import os
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "jimmy_mode.py"


class JimmyModeTests(unittest.TestCase):
    def setUp(self):
        self.home = tempfile.TemporaryDirectory()
        self.addCleanup(self.home.cleanup)

    def run_hook(self, prompt):
        result = subprocess.run(
            [sys.executable, SCRIPT],
            input=json.dumps({"prompt": prompt}),
            capture_output=True,
            text=True,
            env={**os.environ, "HOME": self.home.name},
            check=True,
        )
        if not result.stdout:
            return None
        return json.loads(result.stdout)["hookSpecificOutput"]["additionalContext"]

    def test_toggle_cycle(self):
        self.assertIsNone(self.run_hook("fix the bug"))
        self.assertIn("ON", self.run_hook("Jimmy on"))
        self.assertIn("JIMMY MODE ON", self.run_hook("fix the bug"))
        self.assertIn("is ON", self.run_hook("jimmy status"))
        self.assertIn("OFF", self.run_hook("jimmy off"))
        self.assertIsNone(self.run_hook("fix the bug"))


if __name__ == "__main__":
    unittest.main()
