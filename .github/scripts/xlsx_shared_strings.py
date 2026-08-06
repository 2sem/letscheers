#!/usr/bin/env python3
"""Restore the sharedStrings table in an xlsx written by openpyxl.

openpyxl 3.1.x writes every string cell as t="inlineStr" with the text in an
<is><t> child, and emits no xl/sharedStrings.xml at all. The app reads the
workbook with CoreXLSX, whose parseSharedStrings() throws when that part is
missing and whose stringValue(_:) only resolves t="s" cells — so a plain
load/save round-trip turns the bundled cheers.xlsx into a launch crash.

Call restore_shared_strings() after every wb.save() to put the workbook back
into the shared-string form the original Google Sheets export used.

Run standalone to repair an existing file:

    python3 .github/scripts/xlsx_shared_strings.py path/to/book.xlsx
"""

import re
import shutil
import sys
import zipfile

CELL_RE = re.compile(r'<c\b[^>]*/>|<c\b[^>]*>.*?</c>', re.DOTALL)
TEXT_RE = re.compile(r'<t\b[^>]*>(.*?)</t>', re.DOTALL)
IS_RE = re.compile(r'<is\b[^>]*>(.*?)</is>|<is\b[^>]*/>', re.DOTALL)

SHARED_PART = "xl/sharedStrings.xml"
SHARED_TYPE = ("application/vnd.openxmlformats-officedocument"
               ".spreadsheetml.sharedStrings+xml")
SHARED_REL = ("http://schemas.openxmlformats.org/officeDocument"
              "/2006/relationships/sharedStrings")


def _convert_sheet(xml: str, table: dict, order: list) -> tuple:
    refs = 0

    def replace(match):
        nonlocal refs
        cell = match.group(0)
        if 't="inlineStr"' not in cell:
            return cell

        is_match = IS_RE.search(cell)
        inner = is_match.group(1) if is_match and is_match.group(1) else ""
        raw = "".join(TEXT_RE.findall(inner))

        if raw not in table:
            table[raw] = len(order)
            order.append(raw)
        refs += 1

        head = cell[:cell.index(">") + 1].replace('t="inlineStr"', 't="s"')
        if head.endswith("/>"):
            head = head[:-2] + ">"
        return f"{head}<v>{table[raw]}</v></c>"

    return CELL_RE.sub(replace, xml), refs


def _build_shared_strings(order: list, refs: int) -> str:
    items = "".join(f'<si><t xml:space="preserve">{t}</t></si>' for t in order)
    return (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
        f'count="{refs}" uniqueCount="{len(order)}">{items}</sst>'
    )


def _patch_content_types(xml: str) -> str:
    if f"/{SHARED_PART}" in xml:
        return xml
    override = f'<Override PartName="/{SHARED_PART}" ContentType="{SHARED_TYPE}"/>'
    return xml.replace("</Types>", override + "</Types>")


def _patch_rels(xml: str) -> str:
    if "sharedStrings.xml" in xml:
        return xml
    used = {int(n) for n in re.findall(r'Id="rId(\d+)"', xml)}
    rel = (f'<Relationship Type="{SHARED_REL}" '
           f'Target="sharedStrings.xml" Id="rId{max(used, default=0) + 1}"/>')
    return xml.replace("</Relationships>", rel + "</Relationships>")


def restore_shared_strings(path: str, verbose: bool = True) -> int:
    """Rewrite inline-string cells in `path` as shared strings.

    Returns the number of converted cells; 0 means the workbook already used
    shared strings and was left untouched.
    """
    with zipfile.ZipFile(path) as src:
        names = src.namelist()
        if SHARED_PART in names:
            return 0
        parts = {name: src.read(name) for name in names}
        infos = {name: src.getinfo(name) for name in names}

    table, order, refs = {}, [], 0
    for name in names:
        if not name.startswith("xl/worksheets/sheet"):
            continue
        converted, count = _convert_sheet(parts[name].decode("utf-8"), table, order)
        parts[name] = converted.encode("utf-8")
        refs += count

    if refs == 0:
        return 0

    parts["[Content_Types].xml"] = _patch_content_types(
        parts["[Content_Types].xml"].decode("utf-8")).encode("utf-8")
    parts["xl/_rels/workbook.xml.rels"] = _patch_rels(
        parts["xl/_rels/workbook.xml.rels"].decode("utf-8")).encode("utf-8")

    tmp = path + ".tmp"
    with zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as out:
        for name in names:
            out.writestr(infos[name], parts[name])
        out.writestr(SHARED_PART, _build_shared_strings(order, refs))
    shutil.move(tmp, path)

    if verbose:
        print(f"sharedStrings restored: {refs} refs, {len(order)} unique")
    return refs


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("usage: xlsx_shared_strings.py <file.xlsx>")
    if restore_shared_strings(sys.argv[1]) == 0:
        print("already uses shared strings — nothing to do")
