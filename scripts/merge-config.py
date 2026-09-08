#!/usr/bin/env python3
"""Replace owned top-level TOML assignments without rewriting tables/comments."""
import pathlib
import sys
import tomllib

source = pathlib.Path(sys.argv[1])
destination = pathlib.Path(sys.argv[2])
owned = sys.argv[3:]
with source.open("rb") as handle:
    tomllib.load(handle)
for key in owned:
    if "." in key:
        raise SystemExit(f"owned key must be top-level: {key}")

assignments = {}
in_table = False
for number, line in enumerate(source.read_text().splitlines(), start=1):
    stripped = line.strip()
    if stripped.startswith("["):
        in_table = True
    if "=" in stripped and not stripped.startswith("#"):
        key = stripped.split("=", 1)[0].strip()
        if not in_table and key not in owned:
            raise SystemExit(f"{source}:{number}: unowned top-level key {key}")
        if not in_table and key in owned:
            assignments[key] = line

lines = destination.read_text().splitlines() if destination.exists() else []
result = []
seen = set()
inserted = False
for line in lines:
    stripped = line.strip()
    if not inserted and stripped.startswith("["):
        for key in owned:
            if key not in seen and key in assignments:
                result.append(assignments[key])
        inserted = True
    if not inserted and "=" in stripped and not stripped.startswith("#"):
        key = stripped.split("=", 1)[0].strip()
        if key in owned:
            seen.add(key)
            if key in assignments:
                result.append(assignments[key])
            continue
    result.append(line)
if not inserted:
    for key in owned:
        if key not in seen and key in assignments:
            result.append(assignments[key])

destination.write_text("\n".join(result) + ("\n" if result else ""))
