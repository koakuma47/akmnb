# -*- coding: utf-8 -*-
"""Language pack helper: extract translatable strings and report coverage.

Usage (from the launcher folder):
    python tools/lang_extract.py            # report coverage of lang/*.json
    python tools/lang_extract.py --list     # list every Chinese literal + status
    python tools/lang_extract.py --template en   # write lang/en.template.json
"""
from __future__ import annotations

import argparse
import glob
import io
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)
SOURCE = os.path.join(ROOT, "win1_gui.py")
LANG_DIR = os.path.join(ROOT, "lang")

CJK = re.compile(r"[\u3400-\u9fff\uf900-\ufaff]")
STRING_LITERAL = re.compile(r'"((?:[^"\\]|\\.)*)"')


def chinese_literals(path=SOURCE):
    """Every double-quoted literal that contains Chinese, in source order."""
    text = io.open(path, encoding="utf-8").read()
    found = []
    for raw in STRING_LITERAL.findall(text):
        if not CJK.search(raw):
            continue
        if raw.startswith("\\u"):
            continue
        value = raw.replace("\\\\", "\\").replace('\\"', '"')
        found.append(value)
    return found


def load_pack(code):
    path = os.path.join(LANG_DIR, code + ".json")
    if not os.path.isfile(path):
        return {}
    with io.open(path, encoding="utf-8") as handle:
        return json.load(handle)


def coverage(code):
    pack = load_pack(code)
    phrases = pack.get("phrases") or {}
    strings = pack.get("strings") or {}
    literals = chinese_literals()
    unique = sorted(set(literals))

    import win1_gui as launcher  # local import keeps the tool standalone
    launcher.load_language_packs(force=True)
    launcher.set_language(code)
    covered = []
    for item in unique:
        if launcher.translate_ui(item) != item:
            covered.append(item)
    launcher.set_language("zh")
    return {
        "code": code,
        "literals": len(literals),
        "unique": len(unique),
        "phrases": len(phrases),
        "strings": len(strings),
        "covered": len(covered),
        "percent": (100.0 * len(covered) / len(unique)) if unique else 0.0,
        "missing": [item for item in unique if item not in covered],
    }


def main(argv=None):
    parser = argparse.ArgumentParser(description="AKM language pack helper")
    parser.add_argument("--list", action="store_true", help="list every literal")
    parser.add_argument("--template", default="", help="write a template pack")
    args = parser.parse_args(list(sys.argv[1:] if argv is None else argv))

    if args.template:
        code = args.template
        pack = load_pack(code)
        phrases = pack.get("phrases") or {}
        template = {item: phrases.get(item, "") for item in sorted(set(chinese_literals()))}
        path = os.path.join(LANG_DIR, code + ".template.json")
        io.open(path, "w", encoding="utf-8", newline="\n").write(
            json.dumps(template, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
        )
        print("template written:", path)
        return 0

    packs = sorted(
        os.path.splitext(os.path.basename(p))[0]
        for p in glob.glob(os.path.join(LANG_DIR, "*.json"))
        if ".template." not in p
    )
    for code in packs:
        info = coverage(code)
        print(
            "{0:<4} phrases={1:<4} covered={2:<4}/{3:<4} {4:5.1f}%".format(
                info["code"],
                info["phrases"],
                info["covered"],
                info["unique"],
                info["percent"],
            )
        )
    if args.list:
        info = coverage("en")
        for item in info["missing"]:
            print("  -", item)
    return 0


if __name__ == "__main__":
    sys.exit(main())
