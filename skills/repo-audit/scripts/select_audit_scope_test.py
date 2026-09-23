#!/usr/bin/env python3

import unittest

from select_audit_scope import select_scope


PRS = [
    {"number": 10, "mergedAt": "2026-08-20T10:00:00Z", "labels": []},
    {"number": 11, "mergedAt": "2026-08-21T10:00:00Z", "labels": [{"name": "audit:daily"}]},
    {"number": 12, "mergedAt": "2026-08-22T10:00:00Z", "labels": []},
    {"number": 13, "mergedAt": "2026-08-23T10:00:00Z", "labels": [{"name": "audit:weekly"}]},
]


class ScopeTest(unittest.TestCase):
    def test_daily_resumes_after_latest_marker(self):
        scope = select_scope(PRS, "daily")
        self.assertEqual(scope["checkpointPr"], 11)
        self.assertEqual(scope["selectedPrs"], [12, 13])
        self.assertEqual(scope["markerTargets"], [12, 13])
        self.assertFalse(scope["fullRepository"])

    def test_first_daily_run_baselines_and_marks_latest_pr(self):
        scope = select_scope([dict(item, labels=[]) for item in PRS], "daily")
        self.assertTrue(scope["baseline"])
        self.assertTrue(scope["fullRepository"])
        self.assertEqual(scope["selectedPrs"], [])
        self.assertEqual(scope["markerTargets"], [13])

    def test_weekly_scope_is_full_even_with_a_marker(self):
        scope = select_scope(PRS, "weekly")
        self.assertTrue(scope["fullRepository"])
        self.assertEqual(scope["checkpointPr"], 13)
        self.assertEqual(scope["selectedPrs"], [])

    def test_failed_runs_cannot_advance_markers(self):
        scope = select_scope(PRS, "daily")
        self.assertNotIn("applyMarkers", scope)


if __name__ == "__main__":
    unittest.main()
