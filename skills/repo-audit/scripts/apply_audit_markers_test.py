#!/usr/bin/env python3

import subprocess
import unittest

from apply_audit_markers import apply_markers


class MarkerTest(unittest.TestCase):
    def test_success_applies_every_marker(self):
        commands = []
        apply_markers(
            "owner/repo",
            "audit:daily",
            [12, 13],
            run=commands.append,
            has_label=lambda _repo, _pr, _label: False,
        )
        self.assertEqual([command[-2:] for command in commands], [
            ["--add-label", "audit:daily"],
            ["--add-label", "audit:daily"],
        ])

    def test_failure_rolls_back_markers_added_by_this_batch(self):
        commands = []

        def run(command):
            commands.append(command)
            if command[3] == "13" and "--add-label" in command:
                raise subprocess.CalledProcessError(1, command)

        with self.assertRaises(subprocess.CalledProcessError):
            apply_markers(
                "owner/repo",
                "audit:daily",
                [12, 13],
                run=run,
                has_label=lambda _repo, _pr, _label: False,
            )

        self.assertIn(["--remove-label", "audit:daily"], [command[-2:] for command in commands])

    def test_existing_marker_is_not_removed_on_later_failure(self):
        commands = []

        def run(command):
            commands.append(command)
            raise subprocess.CalledProcessError(1, command)

        with self.assertRaises(subprocess.CalledProcessError):
            apply_markers(
                "owner/repo",
                "audit:weekly",
                [12, 13],
                run=run,
                has_label=lambda _repo, pr, _label: pr == 12,
            )

        self.assertFalse(any("--remove-label" in command for command in commands))


if __name__ == "__main__":
    unittest.main()
