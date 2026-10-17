#!/usr/bin/env python3
"""Checks every plugins/<id>/plugin.json and writes index.json, which the ConsoleDeck app reads.

    python3 tools/build_index.py          # check and write index.json
    python3 tools/build_index.py --check  # check only; fails if index.json is out of date

Mirrors the app's own checks (app/src-tauri/src/plugins.rs in mike623/consoledeck).
"""
import json, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FIELD_TYPES = {"text", "textarea", "url", "app", "keys", "password", "select"}
WAYS = {"exec", "shell", "url", "app", "keys", "type", "password", "input", "media"}
PLATFORMS = {"mac", "windows"}


def check_run(run, where):
    if not isinstance(run, dict):
        raise ValueError(f"{where}: run must be an object")
    unknown = set(run) - WAYS - PLATFORMS
    if unknown:
        raise ValueError(f"{where}: unknown run keys {sorted(unknown)}")
    ways = [k for k in run if k in WAYS]
    variants = [k for k in run if k in PLATFORMS]
    if not ((len(ways) == 1 and not variants) or (not ways and variants)):
        raise ValueError(f"{where}: run needs exactly one of {sorted(WAYS)} (or mac/windows variants)")
    if "exec" in run and (not isinstance(run["exec"], list) or not run["exec"] or not all(isinstance(a, str) for a in run["exec"])):
        raise ValueError(f"{where}: exec must be a non-empty list of strings")
    for p in variants:
        check_run(run[p], f"{where}.{p}")


def commands(run):
    """Every program a run can start, for reviewers and the app's install prompt."""
    if not run:
        return []
    out = [run["exec"]] if "exec" in run else []
    for p in PLATFORMS & set(run):
        out += commands(run[p])
    return out


def check(folder: Path):
    m = json.loads((folder / "plugin.json").read_text())
    for key in ("id", "name", "version"):
        if not isinstance(m.get(key), str) or not m[key]:
            raise ValueError(f"missing {key}")
    if not re.fullmatch(r"[a-z0-9-]{1,64}", m["id"]):
        raise ValueError(f"bad id {m['id']!r}: use a-z, 0-9 and -")
    if m["id"] != folder.name:
        raise ValueError(f"id {m['id']} doesn't match folder {folder.name}")
    if not re.fullmatch(r"\d+(\.\d+){0,2}", m["version"]):
        raise ValueError(f"version {m['version']!r} should look like 1.2.3")
    if set(m.get("platforms", [])) - PLATFORMS:
        raise ValueError(f"platforms must be from {sorted(PLATFORMS)}")
    option_runs = False
    for f in m.get("fields", []):
        if f.get("type") not in FIELD_TYPES:
            raise ValueError(f"field {f.get('id')}: type must be one of {sorted(FIELD_TYPES)}")
        for o in f.get("options", []):
            if "run" in o:
                check_run(o["run"], f"option {o.get('value')}")
                option_runs = True
    if "live" in m:
        check_run(m["live"], "live")
        if any(k in WAYS - {"exec"} for r in [m["live"], *(m["live"].get(p, {}) for p in PLATFORMS)] for k in r):
            raise ValueError("live only takes exec")
    if "run" in m:
        check_run(m["run"], "run")
    elif not option_runs and "live" not in m:
        raise ValueError("nothing to run: add run")
    files = sorted(str(p.relative_to(folder)).replace("\\", "/") for p in folder.rglob("*") if p.is_file() and p.name != ".DS_Store")
    cmds = commands(m.get("run")) + commands(m.get("live"))
    for f in m.get("fields", []):
        for o in f.get("options", []):
            cmds += commands(o.get("run"))
        if f.get("optionsFrom") and f["optionsFrom"] != ["inputSources"]:
            cmds.append(f["optionsFrom"])
        if f.get("button"):
            cmds.append(f["button"]["exec"])
    return {
        "id": m["id"], "name": m["name"], "version": m["version"], "description": m.get("description", ""),
        "platforms": m.get("platforms", []), "files": files, "commands": cmds,
    }


def main():
    entries, errors = [], []
    for folder in sorted((ROOT / "plugins").iterdir()):
        if folder.is_dir():
            try:
                entries.append(check(folder))
            except Exception as e:  # report every broken plugin, not just the first
                errors.append(f"{folder.name}: {e}")
    if errors:
        sys.exit("\n".join(errors))
    index = json.dumps({"plugins": entries}, indent=2, ensure_ascii=False) + "\n"
    path = ROOT / "index.json"
    if "--check" in sys.argv:
        if not path.exists() or path.read_text() != index:
            sys.exit("index.json is out of date: run python3 tools/build_index.py")
    else:
        path.write_text(index)
    print(f"{len(entries)} plugins OK")


if __name__ == "__main__":
    main()
