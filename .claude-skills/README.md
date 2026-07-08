# Joyfill iOS SDK - Claude Skills

This directory contains custom Claude skills for the Joyfill Swift SDK project.

## Available Skills

### 📚 onboard-ios-engineer

**Purpose:** Comprehensive onboarding guide for new iOS engineers joining the team

**When to use:**
- Onboarding new team members
- Quick reference for SDK architecture
- Learning key development patterns
- Understanding core systems (validation, formulas, conditional logic)

**How to use:**

In Claude Code, run:
```
/onboard-ios-engineer
```

Or ask Claude:
```
"Help me onboard to the Joyfill iOS SDK codebase"
```

**What it covers:**
- ✅ Prerequisites and environment setup
- ✅ Project architecture overview
- ✅ Core concepts (JoyDoc, DocumentEditor, Form hierarchy)
- ✅ 14 field types explained
- ✅ Deep dive into key systems:
  - Validation system
  - Conditional logic
  - Formula engine
  - Change API
- ✅ Common development tasks with code examples
- ✅ File organization and navigation
- ✅ Best practices and performance tips
- ✅ Troubleshooting guide
- ✅ Resources and documentation links
- ✅ First contribution workflow

**Skill length:** ~687 lines, 10 comprehensive sections

## Skill Development

### Creating New Skills

1. Create a new `.md` file in `.claude-skills/`
2. Follow the skill template format
3. Include practical examples and code snippets
4. Reference `CLAUDE.MD` for technical details
5. Test the skill with Claude Code

### Skill Template

```markdown
# Skill Title

**Skill Name:** skill-name
**Description:** Brief description
**When to use:** Use cases

---

## Content Sections

### Section 1: Introduction
...

### Section 2: Main Content
...

## Summary
...
```

### Best Practices

- ✅ Make skills self-contained and comprehensive
- ✅ Include code examples with syntax highlighting
- ✅ Use tables, lists, and visual hierarchy
- ✅ Provide troubleshooting sections
- ✅ Link to relevant source files
- ✅ Keep language clear and actionable
- ✅ Include next steps and resources

## Maintenance

Skills should be updated when:
- Major architectural changes occur
- New features are added
- Best practices evolve
- Documentation is restructured

## Related Documentation

- `CLAUDE.MD` - Complete technical reference (source of truth)
- `README.md` - User-facing project documentation
- `document-editor.md` - DocumentEditor API guide
- `change-events.md` - Event handling guide
- `validate.md` - Validation guide

## Contributing

To improve skills:
1. Update the skill `.md` file
2. Test with Claude Code
3. Commit with descriptive message
4. Update this README if adding new skills

---

**Note:** Skills are designed to work with Claude Code and leverage the comprehensive `CLAUDE.MD` documentation.
