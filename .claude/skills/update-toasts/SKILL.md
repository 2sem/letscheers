---
name: update-toasts
description: Add new Korean 건배사 to the bundled cheers.xlsx locally — reveal the encrypted workbook, search for new toasts, append them with dedup, restore sharedStrings, re-encrypt, and open a data PR. Use when asked to add toasts, update toast data, or run a toast update outside the monthly GitHub Action.
---

# Update toast data locally

The monthly GitHub Action (`.github/workflows/update-toast-data.yml`) runs
`update_toasts.py`, which shells out to `claude -p` for the web search. In a
Claude Code session that subprocess is redundant — do the search yourself and
feed the results to `append_toasts.py`.

## Before starting

`cheers.xlsx` is git-secret encrypted and the decrypted copy is gitignored, so
the working tree may hold a stale file. Always reveal first.

GPG needs a TTY that this session's shell does not provide, so **the user must
run the reveal themselves**. Ask them to run:

```
! git secret reveal -f
```

Do not try to run it yourself — it fails with
`gpg: cannot open '/dev/tty': Device not configured`.

## Steps

1. **Branch.** If on `main`, create a `data/toast-update-YYYY-MM-DD` branch.
   Never work on a `a.b.c` release branch.

2. **Reveal** the workbook (see above), then confirm it is current:

   ```bash
   python3 -c "
   import openpyxl
   ws = openpyxl.load_workbook('Projects/App/Resources/Excel/cheers.xlsx').active
   rows = list(ws.iter_rows(values_only=True))
   print(f'{len(rows) - 1} toasts, last: {rows[-1][:2]}')"
   ```

3. **Read the existing categories** so new toasts land in ones the app already
   shows — the category column drives the collection view, and an unknown value
   creates an orphan section.

4. **Search the web** for 건배사 popular since the last data update. Get the
   date from `git log -1 --format=%ci Projects/App/Resources/Excel/cheers.xlsx.secret`.
   Aim for ~10 spread across the existing categories.

5. **Write the results** to a JSON file in the scratchpad:

   ```json
   [{"title": "건배사", "contents": "의미", "category": "분류"}]
   ```

6. **Append:**

   ```bash
   python3 .github/scripts/append_toasts.py <path-to-json>
   ```

   This dedupes against the sheet and within the batch, numbers the new rows,
   saves, and restores the sharedStrings table. It prints a markdown table of
   what landed — use that for the PR body.

7. **Re-encrypt and commit:**

   ```bash
   git secret hide
   git add .gitsecret/paths/mapping.cfg Projects/App/Resources/Excel/cheers.xlsx.secret
   ```

8. **Open a PR** with the printed table as the body.

## Why the sharedStrings step matters

openpyxl 3.1.x writes every string as `t="inlineStr"` and emits no
`xl/sharedStrings.xml`. The app parses the workbook with CoreXLSX, and
`LCExcelController.swift:60` calls `try! document.parseSharedStrings()`, which
traps when that part is missing — a launch crash, not a degraded list. Any code
path that saves this workbook with openpyxl **must** call
`restore_shared_strings()` afterward. `append_toasts.py` and `update_toasts.py`
both already do.

To repair a workbook that already lost the part:

```bash
python3 .github/scripts/xlsx_shared_strings.py Projects/App/Resources/Excel/cheers.xlsx
```

It is idempotent — a no-op on a workbook that already uses shared strings.

## Known gap

Dedup compares titles after `strip()` only, so internal spacing still slips
through: `아프지말자` and `아프지 말자` are treated as different toasts. Check
new titles against existing ones space-insensitively before appending.
