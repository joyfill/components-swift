# Joyfill iOS Development Agents - Usage Guide

This directory contains specialized AI agents designed for Joyfill iOS SDK development. Each agent has specific expertise and tools tailored for different aspects of the codebase.

## Quick Reference

| Agent | Use For | Model |
|-------|---------|-------|
| `swiftui` | UI components, SwiftUI views, field implementations | Sonnet |
| `formula` | Formula engine, parsing, evaluation, functions | Sonnet |
| `viewmodel` | DocumentEditor, handlers, state management | Sonnet |
| `tests` | Unit tests, XCTest, test fixtures | Sonnet |
| `models` | Codable structs, JoyDoc, data modeling | Haiku |
| `build` | SPM, builds, CI/CD, dependencies | Haiku |
| `review` | Code review, quality, memory, performance | Sonnet |
| `docs` | Documentation, doc comments, markdown | Haiku |

## Using Agents with Claude Agent SDK

### Python Example

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions, AgentDefinition

# Load agent prompts
def load_prompt(agent_name: str) -> str:
    with open(f".claude/agents/prompts/{agent_name}.md", "r") as f:
        return f.read()

async def main():
    async for message in query(
        prompt="Add a new formula function called REVERSE that reverses a string",
        options=ClaudeAgentOptions(
            allowed_tools=["Read", "Edit", "Write", "Glob", "Grep", "Task"],
            agents={
                "formula": AgentDefinition(
                    description="Works on formula parsing, evaluation, and function implementations.",
                    prompt=load_prompt("formula"),
                    tools=["Read", "Edit", "Write", "Glob", "Grep"],
                    model="sonnet"
                ),
                "tests": AgentDefinition(
                    description="Writes and runs XCTest unit tests.",
                    prompt=load_prompt("tests"),
                    tools=["Read", "Edit", "Write", "Bash", "Glob", "Grep"],
                    model="sonnet"
                )
            }
        )
    ):
        if hasattr(message, "result"):
            print(message.result)

asyncio.run(main())
```

### TypeScript Example

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";
import { readFileSync } from "fs";

const loadPrompt = (agent: string) =>
  readFileSync(`.claude/agents/prompts/${agent}.md`, "utf-8");

for await (const message of query({
  prompt: "Fix the memory leak in TableView",
  options: {
    allowedTools: ["Read", "Edit", "Write", "Glob", "Grep", "Task"],
    agents: {
      swiftui: {
        description: "Creates and modifies SwiftUI views and field components.",
        prompt: loadPrompt("swiftui"),
        tools: ["Read", "Edit", "Write", "Glob", "Grep"],
        model: "sonnet",
      },
      review: {
        description: "Reviews code for quality, memory leaks, and conventions.",
        prompt: loadPrompt("review"),
        tools: ["Read", "Glob", "Grep"],
        model: "sonnet",
      },
    },
  },
})) {
  if ("result" in message) console.log(message.result);
}
```

## Agent Combinations for Common Tasks

### 1. Implementing a New Field Type

Use: `swiftui` + `viewmodel` + `tests`

```python
agents={
    "swiftui": AgentDefinition(
        description="Creates SwiftUI field components.",
        prompt=load_prompt("swiftui"),
        tools=["Read", "Edit", "Write", "Glob", "Grep"]
    ),
    "viewmodel": AgentDefinition(
        description="Handles ViewModel and state management.",
        prompt=load_prompt("viewmodel"),
        tools=["Read", "Edit", "Write", "Glob", "Grep"]
    ),
    "tests": AgentDefinition(
        description="Writes unit tests.",
        prompt=load_prompt("tests"),
        tools=["Read", "Edit", "Write", "Bash", "Glob", "Grep"]
    )
}
```

### 2. Adding a New Formula Function

Use: `formula` + `tests`

```python
agents={
    "formula": AgentDefinition(
        description="Implements formula functions.",
        prompt=load_prompt("formula"),
        tools=["Read", "Edit", "Write", "Glob", "Grep"]
    ),
    "tests": AgentDefinition(
        description="Writes formula tests.",
        prompt=load_prompt("tests"),
        tools=["Read", "Edit", "Write", "Bash", "Glob", "Grep"]
    )
}
```

### 3. Code Review Before PR

Use: `review` + `build`

```python
agents={
    "review": AgentDefinition(
        description="Reviews code quality and conventions.",
        prompt=load_prompt("review"),
        tools=["Read", "Glob", "Grep"]  # Read-only!
    ),
    "build": AgentDefinition(
        description="Runs builds and tests.",
        prompt=load_prompt("build"),
        tools=["Bash", "Read", "Glob", "Grep"]
    )
}
```

### 4. Updating Data Models

Use: `models` + `tests` + `docs`

```python
agents={
    "models": AgentDefinition(
        description="Works on Codable data models.",
        prompt=load_prompt("models"),
        tools=["Read", "Edit", "Write", "Glob", "Grep"],
        model="haiku"  # Simpler tasks
    ),
    "tests": AgentDefinition(
        description="Writes model tests.",
        prompt=load_prompt("tests"),
        tools=["Read", "Edit", "Write", "Bash", "Glob", "Grep"]
    ),
    "docs": AgentDefinition(
        description="Documents the models.",
        prompt=load_prompt("docs"),
        tools=["Read", "Edit", "Write", "Glob"],
        model="haiku"
    )
}
```

## Tool Access by Agent

| Agent | Read | Edit | Write | Bash | Glob | Grep |
|-------|:----:|:----:|:-----:|:----:|:----:|:----:|
| swiftui | ✓ | ✓ | ✓ | - | ✓ | ✓ |
| formula | ✓ | ✓ | ✓ | - | ✓ | ✓ |
| viewmodel | ✓ | ✓ | ✓ | - | ✓ | ✓ |
| tests | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| models | ✓ | ✓ | ✓ | - | ✓ | ✓ |
| build | ✓ | - | - | ✓ | ✓ | ✓ |
| review | ✓ | - | - | - | ✓ | ✓ |
| docs | ✓ | ✓ | ✓ | - | ✓ | - |

## File Structure

```
.claude/agents/
├── ios-agents.json          # Main configuration file
├── USAGE.md                 # This file
└── prompts/
    ├── swiftui.md          # SwiftUI Components Agent
    ├── formula.md          # Formula Engine Agent
    ├── viewmodel.md        # ViewModel Logic Agent
    ├── tests.md            # Unit Test Agent
    ├── models.md           # Data Model Agent
    ├── build.md            # Build & CI Agent
    ├── review.md           # Code Review Agent
    └── docs.md             # Documentation Agent
```

## Customizing Agents

### Adding a New Agent

1. Create a new prompt file in `prompts/`:
   ```bash
   touch .claude/agents/prompts/my-agent.md
   ```

2. Add the agent definition to `ios-agents.json`:
   ```json
   "my-agent": {
     "name": "My Agent",
     "description": "What this agent does. When to use it.",
     "promptFile": "prompts/my-agent.md",
     "tools": ["Read", "Edit", "Write"],
     "model": "sonnet"
   }
   ```

### Modifying an Agent

Edit the corresponding prompt file in `prompts/`. The prompt should include:
- Expertise areas
- Key file paths
- Project conventions
- Code examples
- When the agent should be invoked

## Best Practices

1. **Choose the right agent** - Use the agent that matches the task domain
2. **Combine agents** - Use multiple agents for complex tasks
3. **Limit tools** - Only give agents the tools they need
4. **Use haiku for simple tasks** - Saves cost and latency
5. **Read-only for review** - Never give the review agent write access
6. **Run tests after changes** - Always use the tests agent after modifications

## Example Workflows

### Bug Fix Workflow
1. `review` agent analyzes the issue (read-only)
2. Appropriate agent (`swiftui`, `formula`, etc.) implements the fix
3. `tests` agent writes/runs tests
4. `build` agent verifies the build passes

### Feature Development Workflow
1. `models` agent updates data structures if needed
2. `viewmodel` agent implements business logic
3. `swiftui` agent creates UI components
4. `tests` agent writes comprehensive tests
5. `docs` agent documents the new feature
6. `review` agent performs final quality check
