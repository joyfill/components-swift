const githubLink = document.getElementById("githubLink");
const themeToggle = document.getElementById("themeToggle");
const skillsList = document.getElementById("skillsList");
const skillTitle = document.getElementById("skillTitle");
const skillDescription = document.getElementById("skillDescription");
const skillUsage = document.getElementById("skillUsage");
const referenceBar = document.getElementById("referenceBar");
const markdownContent = document.getElementById("markdownContent");

const repoInfo = getRepoInfo();
githubLink.href = repoInfo
  ? `https://github.com/${repoInfo.owner}/${repoInfo.repo}`
  : "#";

initTheme();
loadSkills();

function loadSkills() {
  fetch("skills.json")
    .then((response) => {
      if (!response.ok) {
        throw new Error("Failed to load skills index");
      }
      return response.json();
    })
    .then((skills) => {
      if (!Array.isArray(skills) || skills.length === 0) {
        throw new Error("No skills found");
      }
      const normalized = skills.map((skill) => normalizeSkill(skill));
      renderSkillList(normalized);
      selectSkill(normalized[0], normalized);
    })
    .catch(() => {
      markdownContent.textContent =
        "Unable to load the skills index. Run scripts/build_docs_index.py to regenerate docs/skills.json.";
    });
}

function normalizeSkill(skill) {
  const displayName = prettifyName(skill.name || skill.folder || "Skill");
  return {
    name: displayName,
    rawName: skill.name || displayName,
    folder: skill.folder,
    description: skill.description || "",
    references: skill.references || [],
  };
}

function renderSkillList(skills) {
  skillsList.innerHTML = "";
  skills.forEach((skill) => {
    const item = document.createElement("button");
    item.className = "skill-item";
    item.type = "button";
    item.dataset.folder = skill.folder;

    const title = document.createElement("div");
    title.className = "skill-item__title";
    title.textContent = skill.name;

    const meta = document.createElement("div");
    meta.className = "skill-item__meta";

    const badge = document.createElement("span");
    badge.className = "skill-item__badge";
    badge.textContent = `${skill.references.length} ref${skill.references.length === 1 ? "" : "s"}`;

    const folder = document.createElement("span");
    folder.textContent = skill.folder;

    meta.append(badge, folder);

    const preview = document.createElement("div");
    preview.className = "skill-item__preview";
    preview.textContent = truncateText(skill.description, 110);

    item.append(title, meta, preview);
    item.addEventListener("click", () => selectSkill(skill, skills));
    skillsList.append(item);
  });
}

function selectSkill(skill, skills) {
  setActiveSkill(skill);
  skillTitle.textContent = skill.name;
  skillDescription.textContent = skill.description;
  skillUsage.textContent = "";
  renderReferenceBar(skill, skills);
  loadMarkdown(skill, "SKILL.md");
}

function setActiveSkill(skill) {
  Array.from(skillsList.children).forEach((node) => {
    node.classList.toggle("active", node.dataset.folder === skill.folder);
  });
}

function renderReferenceBar(skill) {
  referenceBar.innerHTML = "";

  const mainButton = document.createElement("button");
  mainButton.className = "reference-pill active";
  mainButton.type = "button";
  mainButton.textContent = "SKILL.md";
  mainButton.addEventListener("click", () => {
    setActiveReference(mainButton);
    loadMarkdown(skill, "SKILL.md");
  });
  referenceBar.append(mainButton);

  if (!skill.references.length) {
    const empty = document.createElement("span");
    empty.className = "muted";
    empty.textContent = "No references";
    referenceBar.append(empty);
    return;
  }

  skill.references.forEach((ref) => {
    const refButton = document.createElement("button");
    refButton.className = "reference-pill";
    refButton.type = "button";
    refButton.textContent = ref.title || prettifyName(ref.file);
    refButton.addEventListener("click", () => {
      setActiveReference(refButton);
      loadMarkdown(skill, ref.file);
    });
    referenceBar.append(refButton);
  });
}

function setActiveReference(activeButton) {
  Array.from(referenceBar.querySelectorAll(".reference-pill")).forEach((node) => {
    node.classList.toggle("active", node === activeButton);
  });
}

function loadMarkdown(skill, filePath) {
  const contentPath = buildContentPath(`${skill.folder}/${filePath}`);
  fetch(contentPath)
    .then((response) => {
      if (!response.ok) {
        throw new Error("Failed to load content");
      }
      return response.text();
    })
    .then((text) => {
      const parsed = parseFrontmatter(text);
      const content = stripH1(parsed.content, parsed.frontmatter.name || skill.name);
      const overview = extractOverview(content);
      updateHeader(parsed.frontmatter, overview, skill);

      if (window.marked) {
        markdownContent.innerHTML = window.marked.parse(content);
      } else {
        markdownContent.textContent = content;
      }
    })
    .catch(() => {
      markdownContent.textContent =
        "Unable to load this document. Make sure the file exists and the server can reach it.";
    });
}

function buildContentPath(path) {
  if (!repoInfo) {
    return `../${path}`;
  }
  return `https://raw.githubusercontent.com/${repoInfo.owner}/${repoInfo.repo}/main/${path}`;
}

function updateHeader(frontmatter, overview, skill) {
  if (frontmatter.name) {
    skillTitle.textContent = prettifyName(frontmatter.name);
  }
  if (frontmatter.description) {
    skillDescription.textContent = frontmatter.description;
  }
  if (overview) {
    skillUsage.textContent = `Usage: ${overview}`;
  } else if (skill.description) {
    skillUsage.textContent = `Usage: ${skill.description}`;
  }
}

function parseFrontmatter(text) {
  if (!text.startsWith("---")) {
    return { frontmatter: {}, content: text };
  }

  const lines = text.split("\n");
  let endIndex = -1;
  for (let i = 1; i < lines.length; i += 1) {
    if (lines[i].trim() === "---") {
      endIndex = i;
      break;
    }
  }

  if (endIndex === -1) {
    return { frontmatter: {}, content: text };
  }

  const yamlLines = lines.slice(1, endIndex);
  const content = lines.slice(endIndex + 1).join("\n");
  const frontmatter = {};

  yamlLines.forEach((line) => {
    const match = line.match(/^([a-zA-Z0-9_-]+):\s*(.*)$/);
    if (!match) return;
    const key = match[1];
    let value = match[2].trim();
    if (value.startsWith("\"") && value.endsWith("\"")) {
      value = value.slice(1, -1);
    }
    frontmatter[key] = value;
  });

  return { frontmatter, content };
}

function stripH1(content, title) {
  const lines = content.split("\n");
  if (!lines.length) return content;

  const firstLine = lines[0].trim();
  const normalizedTitle = (title || "").trim().toLowerCase();
  if (firstLine.startsWith("#")) {
    const heading = firstLine.replace(/^#+\s*/, "").trim().toLowerCase();
    if (!normalizedTitle || heading === normalizedTitle) {
      return lines.slice(1).join("\n").trimStart();
    }
  }
  return content;
}

function extractOverview(content) {
  const match = content.match(/##\s+Overview\s+([\s\S]*?)(\n##\s|$)/i);
  if (!match) return "";
  const body = match[1].trim();
  const paragraph = body.split("\n\n")[0];
  return paragraph.replace(/\s+/g, " ").trim();
}

function truncateText(text, maxLength) {
  if (!text) return "";
  if (text.length <= maxLength) return text;
  return `${text.slice(0, maxLength - 1).trim()}…`;
}

function prettifyName(name) {
  if (!name) return "";
  if (/[A-Z]/.test(name) && !name.includes("-")) {
    return name;
  }
  const parts = name.replace(/-/g, " ").split(" ");
  const map = {
    ios: "iOS",
    swiftui: "SwiftUI",
    swift: "Swift",
    app: "App",
    gh: "GitHub",
  };
  return parts
    .map((part) => {
      const lower = part.toLowerCase();
      if (map[lower]) return map[lower];
      return lower.charAt(0).toUpperCase() + lower.slice(1);
    })
    .join(" ");
}

function getRepoInfo() {
  const host = window.location.hostname;
  const pathParts = window.location.pathname.split("/").filter(Boolean);

  if (!host || host.indexOf(".github.io") === -1) {
    return null;
  }

  const owner = host.split(".")[0];
  const repo = pathParts[0];

  if (!owner || !repo) {
    return null;
  }

  return { owner, repo };
}

function initTheme() {
  const saved = localStorage.getItem("codex-theme");
  if (saved) {
    setTheme(saved);
  } else {
    const prefersLight = window.matchMedia("(prefers-color-scheme: light)").matches;
    setTheme(prefersLight ? "light" : "dark");
  }

  themeToggle.addEventListener("click", () => {
    const next = document.documentElement.getAttribute("data-theme") === "dark" ? "light" : "dark";
    setTheme(next);
    localStorage.setItem("codex-theme", next);
  });
}

function setTheme(theme) {
  document.documentElement.setAttribute("data-theme", theme);
}
