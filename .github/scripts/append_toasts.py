#!/usr/bin/env python3
"""Append toasts from a JSON file into cheers.xlsx.

Local counterpart to update_toasts.py: that script is the GitHub Action entry
point and does its own `claude -p` web search, which is redundant when you are
already in a Claude Code session. Here the search is the caller's job — pass
the results in as JSON and this handles dedup, numbering, and the
sharedStrings repair that openpyxl would otherwise strip.

    python3 .github/scripts/append_toasts.py new_toasts.json

Input is the same shape update_toasts.py's search returns:

    [{"title": "건배사", "contents": "의미", "category": "분류"}]

Prints a markdown table of what it appended, ready to paste into a PR body.
"""

import json
import sys

import openpyxl

from update_toasts import (
    XLSX_PATH,
    SHEET_NAME,
    append_toast,
    bump_info_version,
    filter_new_toasts,
    normalize_text,
    read_column_map,
    read_existing_toasts,
)
from xlsx_shared_strings import restore_shared_strings


def main():
    if len(sys.argv) != 2:
        sys.exit("usage: append_toasts.py <toasts.json>")

    with open(sys.argv[1], encoding="utf-8") as f:
        incoming = json.load(f)

    wb = openpyxl.load_workbook(XLSX_PATH)
    ws = wb[SHEET_NAME]

    col_map = read_column_map(ws)
    existing, max_no = read_existing_toasts(ws, col_map)
    existing_titles = {normalize_text(t["title"]) for t in existing if normalize_text(t["title"])}

    new_toasts = filter_new_toasts(incoming, existing_titles)
    skipped = len(incoming) - len(new_toasts)

    if not new_toasts:
        print(f"No new toasts to add ({skipped} duplicates skipped)")
        return

    for toast in new_toasts:
        max_no += 1
        append_toast(ws, col_map, max_no, toast["title"], toast["contents"], toast["category"])

    old_v, new_v = bump_info_version(wb)

    wb.save(XLSX_PATH)
    restore_shared_strings(XLSX_PATH)

    if new_v:
        print(f"info version: {old_v} -> {new_v}")
    print(f"Added {len(new_toasts)} toasts ({skipped} duplicates skipped), now at no {max_no}\n")
    print("| 건배사 | 의미 | 분류 |")
    print("|--------|------|------|")
    for toast in new_toasts:
        print(f"| {toast['title']} | {toast['contents']} | {toast['category']} |")


if __name__ == "__main__":
    main()
