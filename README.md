# Claude Code Quality Pipeline - Simple Reference Implementation

A working example of an intelligent and automated **Code Quality Pipeline** using Claude Code hooks and agents.

- [What this demonstrates](#what-this-demonstrates)
- [Pipeline flow](#pipeline-flow)
- [Results you'll see](#results-youll-see)
- [Quickstart](#quickstart)
- [Directory structure](#directory-structure)
- [Getting started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Testing](#testing)
  - [Usage Examples](#usage-examples)
- [Agents](#agents)
- [Customization](#customization)

## Pipeline flow

1. **Code Change** → Triggers automated hooks
2. **Format & Lint** → Prettier and ESLint fix style issues  
3. **Security Analysis** → AI agent runs quick background scan
4. **Quality Review** → AI agent performs rapid quality check
5. **Testing** → Jest runs related tests
6. **Documentation Check** → AI agent validates doc requirements
7. **Completion** → Shows how to access detailed analysis

## Results you'll see

- ✅ Automatic code formatting and linting on every edit
- ✅ Quick background security and quality checks
- ✅ Automated testing of related code
- ✅ Documentation validation
- ✅ Access to detailed agent analysis on-demand

## Directory structure

```
claude-code-quality-pipeline/
├── README.md                          # This guide
├── .claude/
│   ├── agents/                        # 3 focused AI agents
│   │   ├── security-agent.md          # Security vulnerability detection
│   │   ├── quality-agent.md           # Code quality analysis
│   │   └── docs-agent.md              # Documentation maintenance
│   └── settings.local.json            # 5-step hook configuration
├── sample-project/                    # Test React application
├── scripts/
│   ├── setup.sh                       # Simple setup script
│   └── test-pipeline.sh               # Validation testing
└── examples/                          # Usage examples
```

## Getting started

### Prerequisites

- Claude Code installed and configured
- Node.js 16+ and npm
- Basic command-line experience

### Installation

```bash
./scripts/setup.sh
```

### Testing

```bash
./scripts/test-pipeline.sh
```

### Usage examples

**Basic development**:

```bash
cd sample-project
claude "Fix the security issues in LoginForm.jsx"
# Watch automated pipeline run
```

**Manual agent analysis**:

```bash
# Security analysis
/agent security-agent "Deep security scan of authentication module"

# Quality review  
/agent quality-agent "Comprehensive analysis of LoginForm component"

# Documentation check
/agent docs-agent "Update docs for new validation features"
```

**Pipeline in action**:

When you edit a file, you'll see:

```
🔧 Step 1/5: Formatting & Linting...
✅ Formatted & linted successfully

🛡️ Step 2/5: Security Analysis...  
✅ Security analysis complete

📊 Step 3/5: Quality Review...
✅ Quality review complete

🧪 Step 4/5: Testing...
✅ Tests passed

📖 Step 5/5: Documentation...
✅ Documentation checked

✅ Quality pipeline complete! Use agents for deeper analysis:
/agent security-agent, /agent quality-agent, /agent docs-agent
```

## Agents

### Security agent (`/agent security-agent`)

- **Purpose**: Detect common security vulnerabilities
- **Speed**: 60 seconds analysis
- **Checks**: SQL injection, XSS, hardcoded secrets, auth bypasses, input validation
- **Output**: Specific security issues with code fixes

### Quality agent (`/agent quality-agent`)  

- **Purpose**: Analyze code quality and maintainability
- **Speed**: 60 seconds analysis
- **Checks**: Code complexity, error handling, performance, best practices
- **Output**: Prioritized quality improvements with examples

### Documentation agent (`/agent docs-agent`)

- **Purpose**: Keep documentation current with code changes
- **Speed**: 30 seconds analysis  
- **Checks**: New APIs, README updates, code comments, examples
- **Output**: Specific documentation tasks with content

## Customization

### Adding new agents

1. Create `.claude/agents/my-agent.md` following existing patterns
2. Define focused expertise and 60-90 second analysis time
3. Test with `/agent my-agent "test prompt"`

### Modifying hook steps

Edit `.claude/settings.local.json` to:

- Add new steps to the pipeline
- Modify timeouts or commands
- Change agent invocations
- Add file type support

### Language support 

Currently optimized for JavaScript/TypeScript. To add other languages:

1. Update formatting commands in hooks
2. Add language-specific patterns to agents  
3. Update setup script tool detection
