# Detailed Setup Guide

## Prerequisites

### Required
- **Claude Code**: Version 1.0.0 or later
- **Node.js**: Version 16 or later
- **npm**: Version 8 or later
- **Git**: For version control

### Optional
- **Python**: For JSON validation in scripts
- **curl**: For webhook integrations
- **jq**: For advanced metrics processing

## Installation Steps

### 1. Clone Repository
```bash
git clone <repo-url> claude-quality-pipeline
cd claude-quality-pipeline
```

### 2. Verify Claude Code
```bash
# Check Claude Code installation
claude --version

# Verify agent support
claude /agents

# Test basic functionality
claude "echo 'Hello World'" > test.txt
```

### 3. Install Dependencies
```bash
# Install sample project dependencies
cd sample-project
npm install

# Verify development tools
npx prettier --version
npx eslint --version
npm test -- --version

cd ..
```

### 4. Configure Claude Code
```bash
# Copy template configuration
cp .claude/settings.local.json.template .claude/settings.local.json

# Validate configuration
python3 -m json.tool .claude/settings.local.json
```

### 5. Test Installation
```bash
# Run comprehensive test suite
./scripts/test-pipeline.sh

# Validate individual components
./scripts/validate-agents.sh
```

## Manual Setup (Alternative)

If the automated setup fails, follow these manual steps:

### Agent Setup
```bash
# Ensure agent directory exists
mkdir -p ~/.claude/agents

# Copy agents to user directory (if needed)
cp .claude/agents/*.md ~/.claude/agents/

# Verify agents are recognized
claude /agents | grep -E "(code-quality-enforcer|review-coordinator|security-scanner)"
```

### Hook Configuration
```bash
# Create settings file manually
cat > .claude/settings.local.json << 'EOF'
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "echo '🔧 Auto-formatting...' && if [[ \"${file_path}\" =~ \\.(js|jsx|ts|tsx)$ ]]; then npx prettier --write \"${file_path}\" 2>/dev/null || true; fi"
          }
        ]
      }
    ]
  }
}
EOF

# Test hook configuration
python3 -m json.tool .claude/settings.local.json
```

## Troubleshooting

### Claude Code Issues
```bash
# Check Claude Code status
claude /doctor

# Verify permissions
ls -la ~/.claude/
chmod 755 ~/.claude/
chmod 644 ~/.claude/agents/*.md

# Reset configuration
rm ~/.claude/settings.local.json
cp .claude/settings.local.json.template ~/.claude/settings.local.json
```

### Tool Integration Issues
```bash
# Fix npm dependencies
cd sample-project
rm -rf node_modules package-lock.json
npm install

# Verify tool paths
which prettier
which eslint

# Test tools manually
npx prettier --check src/components/LoginForm.jsx
npx eslint src/components/LoginForm.jsx
```

### Hook Execution Issues
```bash
# Test hook commands manually
export file_path="sample-project/src/components/LoginForm.jsx"
export tool="Edit"

# Run individual hook commands
if [[ "${file_path}" =~ \.jsx$ ]]; then
    echo "File matches pattern"
    npx prettier --write "${file_path}"
fi
```

## Performance Optimization

### Hook Performance
- Limit hook execution to relevant files
- Use timeouts for long-running commands
- Implement parallel execution where possible

### Agent Performance
- Limit tool access to necessary subset
- Use file size limits for large files
- Implement caching for repeated operations

## Security Considerations

### File Permissions
```bash
# Secure agent files
chmod 644 ~/.claude/agents/*.md
chmod 755 ~/.claude/agents/

# Protect configuration
chmod 600 .claude/settings.local.json
```

### Hook Security
- Always quote variables in hook commands
- Validate file paths before execution
- Use whitelist approach for file patterns
- Avoid executing user-controlled data

## Next Steps

After successful setup:

1. **Test Basic Functionality**
   ```bash
   cd sample-project
   claude "Add a comment to LoginForm.jsx"
   ```

2. **Try Agent Analysis**
   ```bash
   /agent code-quality-enforcer "Analyze LoginForm.jsx"
   ```

3. **Use Review Coordinator**
   ```bash
   /agent review-coordinator "Review the authentication components"
   ```

4. **Monitor Metrics**
   ```bash
   tail -f ~/.claude/quality-metrics.log
   ```

5. **Customize for Your Project**
   - Modify `.claude/settings.local.json` for your tech stack
   - Update agent prompts for your coding standards
   - Add project-specific quality checks