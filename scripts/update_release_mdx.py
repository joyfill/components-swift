#!/usr/bin/env python3
"""
Read release-notes markdown, normalize GitHub-style sections to match docs UI
(joyfill/docs ios/changelogs/RELEASE_NOTES.mdx badge pills), then insert after '> Source:'.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

RE_HEADER_BRACKET = re.compile(r"^##\s+\[([^\]]+)\]\s*$")
# Docs use ### Added / Changed / Fixed / Removed → colored <span> pills (see RELEASE_NOTES.mdx).
RE_SECTION = re.compile(
    r"^###\s+(Added|Changed|Fixed|Removed)\s*$",
    re.IGNORECASE,
)


def badge_html(kind: str, is_first: bool) -> str:
    """
    Match RELEASE_NOTES.mdx: first pill in a release has no marginTop; later pills use marginTop 16px.
    ADDED = green; CHANGED/FIXED = orange; REMOVED = red.
    """
    mt = "" if is_first else ", marginTop: '16px'"
    if kind == "added":
        c = "#10b981"
        label = "ADDED"
    elif kind == "removed":
        c = "#ef4444"
        label = "REMOVED"
    else:
        c = "#f97316"
        label = kind.upper()
    return (
        "<span style={{display: 'inline-block', padding: '4px 12px', "
        f"border: '1.5px solid {c}', borderRadius: '6px', color: '{c}', "
        f"fontWeight: '600', fontSize: '13px', marginBottom: '12px'{mt}"
        + "}}>"
        + label
        + "</span>"
    )


RE_STRIP = [
    re.compile(r"^> Source:"),
    re.compile(r"^#\s+"),  # top-level title from GitHub release UI
    # GitHub appends compare URL; omit from docs (top of page has > Source: to releases)
    re.compile(r"^\s*\*\*Full Changelog\*\*", re.IGNORECASE),
    re.compile(r"^\s*Full Changelog:\s*https?://", re.IGNORECASE),
]

# GitHub-generated section titles to remove (ASCII or typographic apostrophe).
RE_DROP_H2_BOILERPLATE = re.compile(
    r"^##\s+What[\u2019']s Changed\s*$",
    re.IGNORECASE,
)
RE_GLUE_SECTION = re.compile(
    r"^###\s+(Added|Changed|Fixed|Removed)\b\s+(.+)$",
    re.IGNORECASE,
)
RE_DROP_H2_NEW_CONTRIBUTORS = re.compile(r"^##\s+New Contributors\s*$", re.IGNORECASE)

RE_BULLET = re.compile(r"^\s*[-*]\s+(.*)$")
RE_FEAT = re.compile(r"^(feat|feature)(\([^)]*\))?!?:\s*", re.IGNORECASE)
RE_FIX = re.compile(r"^fix(\([^)]*\))?!?:\s*", re.IGNORECASE)
RE_REMOVE = re.compile(
    r"^(remove|removed|removal|deprecate)(\([^)]*\))?!?:\s*",
    re.IGNORECASE,
)

# Split one bullet that jams multiple "**Title** — …" items into separate bullets (docs use one `-` per feature).
RE_COMPOUND_BULLET_SPLIT = re.compile(
    r"(?<=[.!?])\s+(?=\*\*[^*]+\*\*\s*[—\-–])",
)
# When there is no sentence end before the next "**Title** —" (rare paste / GitHub quirk).
RE_COMPOUND_BULLET_SPLIT_FALLBACK = re.compile(
    r"(?<=[^\s])\s+(?=\*\*[^*]+\*\*\s*[—\-–])",
)
RE_BULLET_LINE = re.compile(r"^(\s*)([-*])(\s+)(.+)$")
RE_TITLE_EM_DASH = re.compile(r"\*\*[^*]+\*\*\s*[—\-–]")


def expand_glued_section_headers(lines: list[str]) -> list[str]:
    """Split '### Added  - item' on one line into heading + body (docs-style bullets)."""
    out: list[str] = []
    for line in lines:
        bare = line.rstrip("\n")
        m = RE_GLUE_SECTION.match(bare)
        if m:
            kind = m.group(1)
            rest = m.group(2).strip()
            cap = kind[:1].upper() + kind[1:].lower()
            out.append(f"### {cap}\n")
            if rest:
                out.append(rest + "\n")
            continue
        out.append(line)
    return out


def normalize_smushed_markdown(text: str) -> str:
    """
    GitHub / paste sometimes produces one line like:
    ## What's Changed ### Added  - **Item** ...
    Split so ### headings and lists parse correctly (matches joyfill/docs RELEASE_NOTES.mdx).
    """
    text = re.sub(
        r"([^\n])(###\s+(?:Added|Changed|Fixed|Removed)\b)",
        r"\1\n\n\2",
        text,
        flags=re.IGNORECASE,
    )
    text = re.sub(
        r"(##\s+What[\u2019']s Changed\s+)(###\s)",
        r"\1\n\n\2",
        text,
        flags=re.IGNORECASE,
    )
    return text


def should_strip_line(line: str) -> bool:
    s = line.rstrip("\n")
    st = s.strip()
    for rx in RE_STRIP:
        if rx.search(s):
            return True
    if RE_DROP_H2_BOILERPLATE.match(st):
        return True
    if RE_DROP_H2_NEW_CONTRIBUTORS.match(st):
        return True
    return False


def is_version_h2(line: str) -> bool:
    """Match ## 3.x.y or ## v3.x.y (and bracket form handled elsewhere)."""
    s = line.rstrip("\n")
    if RE_HEADER_BRACKET.match(s):
        return True
    if not s.startswith("## "):
        return False
    rest = s[3:].lstrip()
    if not rest:
        return False
    # ## 1.2.3
    if rest[0].isdigit():
        return True
    # ## v1.2.3
    if rest[0] in "vV" and len(rest) > 1 and rest[1].isdigit():
        return True
    return False


def drop_noise_h2(line: str) -> bool:
    """Drop stray ## lines that are not version headers (e.g. old awk ## [^0-9\\[] rule)."""
    s = line.rstrip("\n")
    if not s.startswith("## "):
        return False
    if is_version_h2(line):
        return False
    return True


def has_section_headings(lines: list[str]) -> bool:
    for line in lines:
        if RE_SECTION.match(line.strip()):
            return True
    return False


def classify_bullet(text: str) -> str:
    t = text.strip()
    if RE_REMOVE.match(t):
        return "removed"
    if RE_FIX.match(t):
        return "fixed"
    if RE_FEAT.match(t):
        return "added"
    return "changed"


def _split_bullet_body(body: str) -> list[str]:
    parts = RE_COMPOUND_BULLET_SPLIT.split(body)
    parts = [p.strip() for p in parts if p.strip()]
    if len(parts) > 1:
        return parts
    if len(RE_TITLE_EM_DASH.findall(body)) < 2:
        return [body]
    parts = RE_COMPOUND_BULLET_SPLIT_FALLBACK.split(body)
    parts = [p.strip() for p in parts if p.strip()]
    return parts if len(parts) > 1 else [body]


def split_compound_bullets(lines: list[str]) -> list[str]:
    """
    Turn '- **A** — x. **B** — y' into two list items (matches hand-edited docs; see rc14).
    Skips fenced code blocks. Does not split **Full Changelog**: (no em dash after title).
    """
    in_fence = False
    out: list[str] = []
    for line in lines:
        raw = line.rstrip("\n")
        if raw.strip().startswith("```"):
            in_fence = not in_fence
            out.append(line if line.endswith("\n") else line + "\n")
            continue
        if in_fence:
            out.append(line if line.endswith("\n") else line + "\n")
            continue
        m = RE_BULLET_LINE.match(raw)
        if not m:
            out.append(line if line.endswith("\n") else line + "\n")
            continue
        indent, mark, sp, body = m.groups()
        parts = _split_bullet_body(body)
        if len(parts) <= 1:
            out.append(line if line.endswith("\n") else line + "\n")
            continue
        for piece in parts:
            out.append(f"{indent}{mark}{sp}{piece}\n")
    return out


def normalize_bullets_to_sections(lines: list[str]) -> list[str]:
    """When no ### Added/Changed/Fixed, group bullets using conventional-commit hints."""
    if has_section_headings(lines):
        return lines

    preamble: list[str] = []
    bullets: list[tuple[str, str]] = []
    for line in lines:
        m = RE_BULLET.match(line)
        if m:
            kind = classify_bullet(m.group(1))
            bullets.append((kind, line.rstrip("\n")))
        else:
            preamble.append(line)

    if not bullets:
        return lines

    groups: dict[str, list[str]] = {
        "added": [],
        "changed": [],
        "fixed": [],
        "removed": [],
    }
    for kind, bl in bullets:
        groups[kind].append(bl)

    out = list(preamble)
    for key, heading in [
        ("added", "### Added"),
        ("changed", "### Changed"),
        ("fixed", "### Fixed"),
        ("removed", "### Removed"),
    ]:
        if not groups[key]:
            continue
        out.append(heading + "\n")
        out.extend(item + "\n" for item in groups[key])
        out.append("\n")
    return out


def apply_styles(lines: list[str]) -> list[str]:
    """Map ### Added / Changed / Fixed / Removed to badge HTML (first pill: no marginTop)."""
    out: list[str] = []
    badge_index = 0
    for line in lines:
        s = line.rstrip("\n")
        m = RE_SECTION.match(s.strip())
        if m:
            which = m.group(1).lower()
            if badge_index > 0 and out and out[-1].strip():
                out.append("\n")
            out.append(badge_html(which, is_first=(badge_index == 0)) + "\n")
            out.append("\n")
            badge_index += 1
            continue
        out.append(line if line.endswith("\n") else line + "\n")
    return out


def preprocess_lines(raw_lines: list[str]) -> list[str]:
    """Strip noise, unwrap ## [x] headers, emit version H2 with blank line (awk parity)."""
    out: list[str] = []
    for line in raw_lines:
        if should_strip_line(line):
            continue
        s = line.rstrip("\n")

        m = RE_HEADER_BRACKET.match(s)
        if m:
            out.append(f"## {m.group(1).strip()}\n")
            out.append("\n")
            continue

        if s.startswith("## "):
            if drop_noise_h2(line):
                continue
            if is_version_h2(line):
                out.append(s + "\n")
                out.append("\n")
                continue
            # Unknown ## — keep (defensive)
            out.append(s + "\n")
            continue

        out.append(line if line.endswith("\n") else line + "\n")
    return out


def transform_source(raw: str) -> str:
    raw = normalize_smushed_markdown(raw)
    raw_lines = raw.splitlines(keepends=True)
    raw_lines = expand_glued_section_headers(raw_lines)
    lines = preprocess_lines(raw_lines)
    lines = normalize_bullets_to_sections(lines)
    lines = split_compound_bullets(lines)
    lines = apply_styles(lines)
    return "".join(lines).rstrip() + "\n"


def inject_after_source(target_text: str, new_block: str) -> str:
    lines = target_text.splitlines(keepends=True)
    for i, line in enumerate(lines):
        if line.startswith("> Source:"):
            before = lines[: i + 1]
            after = lines[i + 1 :]
            block = new_block if new_block.endswith("\n") else new_block + "\n"
            return "".join(before) + "\n" + block + "\n" + "".join(after)
    raise SystemExit("Error: no '> Source:' marker found in target MDX.")


def main() -> None:
    if len(sys.argv) != 3:
        print(
            "Usage: update_release_mdx.py <changelog_source.md> <target.mdx>",
            file=sys.stderr,
        )
        sys.exit(1)
    source_path = Path(sys.argv[1])
    target_path = Path(sys.argv[2])
    if not source_path.is_file():
        print(f"Error: source file not found: {source_path}", file=sys.stderr)
        sys.exit(1)
    if not target_path.is_file():
        print(f"Error: target file not found: {target_path}", file=sys.stderr)
        sys.exit(1)

    new_entry = transform_source(source_path.read_text(encoding="utf-8"))
    target_text = target_path.read_text(encoding="utf-8")
    out = inject_after_source(target_text, new_entry)
    target_path.write_text(out, encoding="utf-8")
    print("Successfully inserted new release notes after the Source line.")


if __name__ == "__main__":
    main()
