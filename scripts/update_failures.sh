#!/usr/bin/env bash
tail -n 10 /config/logs/automation_failures.log | tac > /config/.automation_failures_recent.txt
