import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "theme.py"


class ThemeCommandTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        for directory in ["ghostty", "herdr", "nvim", "bin"]:
            (self.root / directory).mkdir()
        self.ghostty = self.root / "ghostty/config"
        self.herdr = self.root / "herdr/config.toml"
        self.mode = self.root / "nvim/theme-mode"
        self.ghostty.write_text('theme = Atom One Dark\nfont-family = "TX-02"\n#background-opacity = 0.85\n')
        self.herdr.write_text('[theme]\nname = "one-dark"\nauto_switch = true\n[ui]\nname = "preserve"\n')
        self.env = dict(os.environ, XDG_CONFIG_HOME=str(self.root), PATH=str(self.root / 'bin') + os.pathsep + os.environ['PATH'])
        self.env.pop('HERDR_CONFIG_PATH', None)
        self.stub('osascript', 'exit 0')
        self.stub('herdr', '''if [ "$1" = status ]; then
    echo '{"running": true}'
else
    echo "$*" >> "$XDG_CONFIG_HOME/reloads"
fi''')

    def stub(self, name, content):
        path = self.root / 'bin' / name
        path.write_text('#!/bin/sh\n' + content + '\n')
        path.chmod(0o755)

    def run_theme(self, *args):
        return subprocess.run([sys.executable, str(SCRIPT), *args], env=self.env, capture_output=True, text=True)

    def test_light_dark_toggle_and_status(self):
        self.assertEqual(self.run_theme('status').stdout, 'dark\n')
        for command, mode, ghostty, herdr in [
            ('light', 'light', 'Atom One Light', 'one-light'),
            ('dark', 'dark', 'Atom One Dark', 'one-dark'),
            ('toggle', 'light', 'Atom One Light', 'one-light'),
        ]:
            result = self.run_theme(command)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(self.mode.read_text(), mode + '\n')
            self.assertIn('theme = ' + ghostty + '\n', self.ghostty.read_text())
            self.assertIn('name = "' + herdr + '"\n', self.herdr.read_text())
            self.assertIn('auto_switch = false\n', self.herdr.read_text())
            self.assertIn('[ui]\nname = "preserve"\n', self.herdr.read_text())
            self.assertIn('#background-opacity = 0.85\n', self.ghostty.read_text())
        self.assertEqual((self.root / 'reloads').read_text().splitlines(), ['server reload-config'] * 3)
        self.assertEqual(self.run_theme().returncode, 0)
        self.assertEqual(self.mode.read_text(), 'dark\n')

    def test_invalid_argument_writes_nothing(self):
        original = self.ghostty.read_bytes()
        self.assertEqual(self.run_theme('purple').returncode, 2)
        self.assertEqual(self.ghostty.read_bytes(), original)
        self.assertFalse(self.mode.exists())

    def test_invalid_herdr_leaves_all_configs_unchanged(self):
        original = self.ghostty.read_bytes()
        self.herdr.write_text('[ui]\nname = "wrong section"\n')
        self.assertEqual(self.run_theme('light').returncode, 1)
        self.assertEqual(self.ghostty.read_bytes(), original)
        self.assertFalse(self.mode.exists())

    def test_refresh_failure_reports_saved_mode_and_refreshes_other_app(self):
        self.stub('osascript', 'echo "automation denied" >&2\nexit 1')
        result = self.run_theme('light')
        self.assertEqual(result.returncode, 1)
        self.assertIn('automation denied', result.stderr)
        self.assertIn('Configs are saved', result.stderr)
        self.assertEqual(self.mode.read_text(), 'light\n')
        self.assertEqual((self.root / 'reloads').read_text(), 'server reload-config\n')

    def test_stopped_herdr_does_not_reload_or_start(self):
        self.stub('herdr', '''if [ "$1" = status ]; then
    echo '{"running": false}'
else
    exit 99
fi''')
        result = self.run_theme('light')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_custom_herdr_config_and_symlinks_are_preserved(self):
        custom = self.root / 'custom.toml'
        self.herdr.rename(custom)
        self.env['HERDR_CONFIG_PATH'] = str(custom)
        target = self.root / 'ghostty-target'
        self.ghostty.rename(target)
        self.ghostty.symlink_to(target)
        result = self.run_theme('light')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.ghostty.is_symlink())
        self.assertIn('one-light', custom.read_text())
        self.assertIn('Atom One Light', target.read_text())


if __name__ == '__main__':
    unittest.main()
