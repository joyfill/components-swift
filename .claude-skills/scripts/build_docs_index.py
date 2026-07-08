#!/usr/bin/env python3
import json
from pathlib import Path


def parse_frontmatter(text: str) -> tuple[dict, str]:
    if not text.startswith("---"):
        return {}, text

    lines = text.splitlines()
    end_index = None
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            end_index = i
            break

    if end_index is None:
        return {}, text

    frontmatter_lines = lines[1:end_index]
    content = "\n".join(lines[end_index + 1 :])
    frontmatter = {}
    for line in frontmatter_lines:
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        frontmatter[key.strip()] = value.strip().strip('"')
    return frontmatter, content


def infer_title_from_markdown(path: Path) -> str:
    try:
        for line in path.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if line.startswith("# "):
                return line.replace("# ", "", 1).strip()
    except FileNotFoundError:
        return path.stem.replace("-", " ").title()
    return path.stem.replace("-", " ").title()


def build_index(root: Path) -> list[dict]:
    skills = []
    for skill_dir in sorted(root.iterdir()):
        if not skill_dir.is_dir():
            continue
        skill_md = skill_dir / "SKILL.md"
        if not skill_md.exists():
            continue

        frontmatter, _ = parse_frontmatter(skill_md.read_text(encoding="utf-8"))
        name = frontmatter.get("name", skill_dir.name)
        description = frontmatter.get("description", "").strip()

        references = []
        references_dir = skill_dir / "references"
        if references_dir.exists():
            for ref in sorted(references_dir.glob("*.md")):
                references.append(
                    {
                        "title": infer_title_from_markdown(ref),
                        "file": f"references/{ref.name}",
                    }
                )

        skills.append(
            {
                "name": name,
                "folder": skill_dir.name,
                "description": description,
                "references": references,
            }
        )

    return skills


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    output = root / "docs" / "skills.json"
    skills = build_index(root)
    output.write_text(json.dumps(skills, indent=2), encoding="utf-8")
    print(f"Wrote {output}")


if __name__ == "__main__":
    main()
